import Foundation
import BenchyLib

enum NSDictionaryBufferToData: BenchyComparator {
	static var benchmarks: [Benchmark<NSDictionaryBufferToData>] = []
	static var iterations: Int = 5

	static private let dicts: (nsDict: NSDictionary, swiftAnyHashDict: [AnyHashable: NSNumber], swiftDict: [String: NSNumber]) = {
		let fileURL = URL(filePath: "/Users/mredig/Swap/rawframe.plist")

		let data = try! Data(contentsOf: fileURL)

		let nsDict = try! PropertyListSerialization.propertyList(from: data, format: nil) as! NSDictionary
		let swiftAnyHashDict = nsDict as! [AnyHashable: NSNumber]
		let swiftDict = nsDict as! [String: NSNumber]
		return (nsDict, swiftAnyHashDict, swiftDict)
	}()

	static func setupBenchmarks() throws {

		let (nsDict, swiftAnyHashDict, swiftDict) = dicts

		ChildBenchmark(
			label: "Int to String swift string key dict") { i, label in
				var buffer = Data()
				for i in 0..<swiftDict.count {
					buffer.append(swiftDict["\(i)"]!.uint8Value)
				}
			}


		ChildBenchmark(
			label: "Int to String swift anyhash key dict") { i, label in
				var buffer = Data()
				for i in 0..<swiftAnyHashDict.count {
					buffer.append(swiftAnyHashDict["\(i)"]!.uint8Value)
				}
			}


		ChildBenchmark(
			label: "Int to String nsdict") { i, label in
				var buffer = Data()
				for i in 0..<nsDict.count {
					buffer.append((nsDict["\(i)"] as! NSNumber).uint8Value)
				}
			}

		ChildBenchmark(
			label: "Int to String swift string:UInt8") { i, label in
				var optDict: [String: UInt8]!
				let mapDuration = measureDuration {
					optDict = swiftDict.mapValues(\.uint8Value)
				}
				print("mapping iteration \(i) took \(mapDuration) seconds")
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<optDict.count {
						buffer.append(optDict["\(i)"]!)
					}
				}
				print("buffering iteration \(i) took \(duration) seconds")
			}


		ChildBenchmark(
			label: "Int to String swift string:UInt8 datamapped") { i, label in
				var optDict: [String: UInt8]!
				let mapDuration = measureDuration {
					optDict = swiftDict.mapValues(\.uint8Value)
				}
				print("mapping iteration \(i) took \(mapDuration) seconds")
				let duration = measureDuration {
					var buffer = Data(count: optDict.count)
					for i in 0..<optDict.count {
						buffer[i] = optDict["\(i)"]!
					}
				}
				print("buffering iteration \(i) took \(duration) seconds")
			}
	}
}
