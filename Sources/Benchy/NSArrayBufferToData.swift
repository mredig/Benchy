import Foundation
import BenchyLib

enum NSArrayBufferToData: BenchyTest {
	static func runBenchmarks() throws {

		let fileURL = URL(filePath: "/Users/mredig/Swap/array.out")

		let data = try Data(contentsOf: fileURL)

		let nsArray = try PropertyListSerialization.propertyList(from: data, format: nil) as! NSArray
		let swiftArray = nsArray as! [NSNumber]

		let iterations = 20

		benchmark(label: "NSNumber NSArray buffer", iterations: iterations) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<nsArray.count {
						buffer.append((nsArray[i] as! NSNumber).uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "NSNumber SwiftArray for-count buffer", iterations: iterations) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for i in 0..<swiftArray.count {
						buffer.append(swiftArray[i].uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}

		benchmark(label: "NSNumber SwiftArray for-in buffer", iterations: iterations) { i, label in
			measureDuration {
				let duration = measureDuration {
					var buffer = Data()
					for byte in swiftArray {
						buffer.append(byte.uint8Value)
					}
				}
				print("'\(label)' iteration \(i) took \(duration) seconds")
			}
		}


	}
}
