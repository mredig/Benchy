import Foundation
import BenchyLib

enum NSArrayBufferToData: BenchyCollection {
	static var benchmarks: [Benchmark<NSArrayBufferToData>] = []

	static var arrays: (nsArray: NSArray, swiftArray: [NSNumber]) = {
		let fileURL = URL(filePath: "/Users/mredig/Swap/array.out")

		let data = try! Data(contentsOf: fileURL)

		let nsArray = try! PropertyListSerialization.propertyList(from: data, format: nil) as! NSArray
		let swiftArray = nsArray as! [NSNumber]
		return (nsArray, swiftArray)
	}()

	static func setupBenchmarks() throws {

		let (nsArray, swiftArray) = arrays

		let iterations = 20

		let nsarrayBuffer = ChildBenchmark(
			label: "NSNumber NSArray buffer",
			iterations: iterations) { i, label in
				var buffer = Data()
				for i in 0..<nsArray.count {
					buffer.append((nsArray[i] as! NSNumber).uint8Value)
				}
			}

		let swiftArrayForCount = ChildBenchmark(
			label: "NSNumber SwiftArray for-count buffer",
			iterations: iterations) { i, label in
				var buffer = Data()
				for i in 0..<swiftArray.count {
					buffer.append(swiftArray[i].uint8Value)
				}
			}


		let swiftArrayForIn = ChildBenchmark(
			label: "NSNumber SwiftArray for-in buffer",
			iterations: iterations)  { i, label in
				var buffer = Data()
				for byte in swiftArray {
					buffer.append(byte.uint8Value)
				}
			}

		let swiftArrayForCountDataMapped = ChildBenchmark(
			label: "NSNumber SwiftArray for-count buffer Data Mapped",
			iterations: iterations) { i, label in
				var buffer = Data(count: swiftArray.count)
				for i in swiftArray.startIndex..<swiftArray.endIndex {
					buffer[i] = swiftArray[i].uint8Value
				}
			}

		let swiftArrayForInEnumeratedBufferDataMapped = ChildBenchmark(
			label: "NSNumber SwiftArray for-in enumerated buffer Data Mapped",
			iterations: iterations) { i, label in
				var buffer = Data(count: swiftArray.count)
//					for i in swiftArray.startIndex..<swiftArray.endIndex {
//						buffer[i] = swiftArray[i].uint8Value
//					}
				for (index, byte) in swiftArray.enumerated() {
					buffer[index] = byte.uint8Value
				}
			}

		addBenchmarks([
			nsarrayBuffer,
			swiftArrayForCount,
			swiftArrayForIn,
			swiftArrayForCountDataMapped,
			swiftArrayForInEnumeratedBufferDataMapped,
		])

	}
}
