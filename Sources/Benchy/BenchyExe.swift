import Foundation
import BenchyLib

@main
struct BenchyExe {
	static func main() async throws {
//		try Benchy.addBenchyTest(NSDictionaryBufferToData.self)
//		try Benchy.addBenchyTest(NSArrayBufferToData.self)
		var benchy = Benchy()
		try benchy.addBenchyTest(DateVsCFAbsoluteTimeGetCurrent.self)

		try benchy.runBenchmarks()

		benchy.displayResults(decimalCount: 10)
	}
}
