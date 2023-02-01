import Foundation
import BenchyLib

@main
struct BenchyExe {
	static func main() async throws {
//		Benchy.addBenchyTest(NSDictionaryBufferToData.self)
		try Benchy.addBenchyTest(NSArrayBufferToData.self)

		try Benchy.runBenchmarks()

		Benchy.displayResults()
	}
}
