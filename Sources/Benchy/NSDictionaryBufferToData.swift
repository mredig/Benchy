import Foundation
import BenchyLib

enum NSDictionaryBufferToData: BenchyTest {
	static func runBenchmarks() throws {

		let fileURL = URL(filePath: "/Users/mredig/Swap/rawframe.plist")

		let data = try Data(contentsOf: fileURL)

		let nsDict = try PropertyListSerialization.propertyList(from: data, format: nil) as! NSDictionary
		let swiftAnyHashDict = nsDict as! [AnyHashable: NSNumber]
		let swiftDict = nsDict as! [String: NSNumber]

		benchmark(label: "Int to String swift string key dict", iterations: 5) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<swiftDict.count {
						buffer.append(swiftDict["\(i)"]!.uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "Int to String swift anyhash key dict", iterations: 5) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<swiftAnyHashDict.count {
						buffer.append(swiftAnyHashDict["\(i)"]!.uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "Int to String nsdict", iterations: 5) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<nsDict.count {
						buffer.append((nsDict["\(i)"] as! NSNumber).uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "Int to String swift string:UInt8", iterations: 5) { i, label in
			measureDuration {
				var optDict: [String: UInt8]!
				let mapDuration = measureDuration {
					optDict = swiftDict.mapValues(\.uint8Value)
				}
				print("mapping took \(mapDuration) seconds")
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<optDict.count {
						buffer.append(optDict["\(i)"]!)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "Int to String swift string:UInt8 datamapped", iterations: 5) { i, label in
			measureDuration {
				var optDict: [String: UInt8]!
				let mapDuration = measureDuration {
					optDict = swiftDict.mapValues(\.uint8Value)
				}
				print("mapping took \(mapDuration) seconds")
				let duration = measureDuration {
					var buffer = Data(count: optDict.count)
					for i in 0..<optDict.count {
						buffer[i] = optDict["\(i)"]!
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}
	}
}
