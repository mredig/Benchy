import Foundation
import BenchyLib

@main
struct BenchyExe {
	static func main() async throws {
//		try Benchy.addBenchyTest(NSDictionaryBufferToData.self)
//		try Benchy.addBenchyTest(NSArrayBufferToData.self)
		try Benchy.addBenchyTest(DateVsCFAbsoluteTimeGetCurrent.self)

		try Benchy.runBenchmarks()

		Benchy.displayResults(decimalCount: 10)
	}
}
