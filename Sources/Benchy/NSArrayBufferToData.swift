import Foundation
import BenchyLib

enum NSArrayBufferToData: BenchyComparator {
	static var benchmarks: [Benchmark<NSArrayBufferToData>] = []
	static var iterations: Int = 20

	static var arrays: (nsArray: NSArray, swiftArray: [NSNumber]) = {
		let fileURL = URL(filePath: "/Users/mredig/Swap/array.out")

		let data = try! Data(contentsOf: fileURL)

		let nsArray = try! PropertyListSerialization.propertyList(from: data, format: nil) as! NSArray
		let swiftArray = nsArray as! [NSNumber]
		return (nsArray, swiftArray)
	}()

	static func setupBenchmarks() throws {

		let (nsArray, swiftArray) = arrays

		ChildBenchmark(
			label: "NSNumber NSArray buffer",
			printOutput: .all) { i, label in
				var buffer = Data()
				for i in 0..<nsArray.count {
					buffer.append((nsArray[i] as! NSNumber).uint8Value)
				}
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray for-count buffer",
			printOutput: .all) { i, label in
				var buffer = Data()
				for i in 0..<swiftArray.count {
					buffer.append(swiftArray[i].uint8Value)
				}
			}


		ChildBenchmark(
			label: "NSNumber SwiftArray for-in buffer",
			printOutput: .all) { i, label in
				var buffer = Data()
				for byte in swiftArray {
					buffer.append(byte.uint8Value)
				}
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray for-count buffer Data Mapped",
			printOutput: .all) { i, label in
				var buffer = Data(count: swiftArray.count)
				for i in swiftArray.startIndex..<swiftArray.endIndex {
					buffer[i] = swiftArray[i].uint8Value
				}
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray for-in enumerated buffer Data Mapped",
			printOutput: .all) { i, label in
				var buffer = Data(count: swiftArray.count)
				for (index, byte) in swiftArray.enumerated() {
					buffer[index] = byte.uint8Value
				}
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray for-in enumerated raw unsafe buffer Data Mapped",
			printOutput: .all) { i, label in
				let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: swiftArray.count)
				defer { buffer.deallocate() }

//				var buffer = Data(count: swiftArray.count)
				for (index, byte) in swiftArray.enumerated() {
					buffer[index] = byte.uint8Value
				}

				let data = Data(buffer: buffer)
				print(data)
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray for-in enumerated raw unsafe pointer Data Mapped",
			printOutput: .all) { i, label in
//				let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: swiftArray.count)
				let pointer = UnsafeMutableRawPointer.allocate(byteCount: swiftArray.count, alignment: 8)
//				defer { pointer.deallocate() }

//				var buffer = Data(count: swiftArray.count)
				for (index, byte) in swiftArray.enumerated() {
//					buffer[index] = byte.uint8Value
					pointer.storeBytes(of: byte.uint8Value, toByteOffset: index, as: UInt8.self)
				}

//				let data = Data(buffer: buffer)
				let data = Data(bytesNoCopy: pointer, count: swiftArray.count, deallocator: .custom({ pointer, dno in
					pointer.deallocate()
				}))
				print(data)
			}

		let processorCount = ProcessInfo.processInfo.activeProcessorCount
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = processorCount

		ChildBenchmark(
			label: "NSNumber SwiftArray raw buffer Data Mapped Multithreaded Operation",
			printOutput: .all) { i, label in

				var ranges: [Range<Int>] = []
				var previousEnd = 0
				let delta = swiftArray.count / (processorCount * 4)
				for checkpoint in stride(from: delta, through: swiftArray.endIndex, by: delta) {
					defer { previousEnd = checkpoint }
					let range = previousEnd..<min(checkpoint, swiftArray.endIndex)
					ranges.append(range)
				}
				if ranges.last!.upperBound < swiftArray.endIndex {
					ranges.append(previousEnd..<swiftArray.endIndex)
				}

				let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: swiftArray.count)
				defer { buffer.deallocate() }

				let tasks = ranges
					.map { range in
						BlockOperation {
							for i in range {
								buffer[i] = swiftArray[i].uint8Value
							}
						}
					}

				queue.addOperations(tasks, waitUntilFinished: true)

				let data = Data(buffer: buffer)
				print(data)
			}

		ChildBenchmark(
			label: "NSNumber SwiftArray raw buffer Data Mapped Multithreaded DGroup",
			printOutput: .all) { i, label in

				var ranges: [Range<Int>] = []
				var previousEnd = 0
				let delta = swiftArray.count / (processorCount * 4)
				for checkpoint in stride(from: delta, through: swiftArray.endIndex, by: delta) {
					defer { previousEnd = checkpoint }
					let range = previousEnd..<min(checkpoint, swiftArray.endIndex)
					ranges.append(range)
				}
				if ranges.last!.upperBound < swiftArray.endIndex {
					ranges.append(previousEnd..<swiftArray.endIndex)
				}

				let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: swiftArray.count)
				defer { buffer.deallocate() }

				DispatchQueue.concurrentPerform(iterations: ranges.count) { iteration in
					let range = ranges[iteration]
					for index in range {
						buffer[index] = swiftArray[index].uint8Value
					}
				}

				let data = Data(buffer: buffer)
				print(data)
			}

		let dispatchGroup = DispatchGroup()
		let dispatchQueue = DispatchQueue(label: "Dataing", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit)

		ChildBenchmark(
			label: "NSNumber SwiftArray raw buffer Data Mapped Multithreaded DispatchItems",
			printOutput: .all) { i, label in

				var ranges: [Range<Int>] = []
				var previousEnd = 0
				let delta = swiftArray.count / (processorCount * 4)
				for checkpoint in stride(from: delta, through: swiftArray.endIndex, by: delta) {
					defer { previousEnd = checkpoint }
					let range = previousEnd..<min(checkpoint, swiftArray.endIndex)
					ranges.append(range)
				}
				if ranges.last!.upperBound < swiftArray.endIndex {
					ranges.append(previousEnd..<swiftArray.endIndex)
				}

				let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: swiftArray.count)
				defer { buffer.deallocate() }

				let workItems = ranges
					.map { range in
						DispatchWorkItem(
							qos: .userInitiated) {
								print("Starting range: \(range)")
								for index in range {
									buffer[index] = swiftArray[index].uint8Value
								}
								print("Finished range: \(range)")
							}
					}

				for workItem in workItems {
					dispatchQueue.async(group: dispatchGroup, execute: workItem)
				}

				for workItem in workItems {
					workItem.wait()
				}

				let data = Data(buffer: buffer)
				print(data)
			}
	}
}
