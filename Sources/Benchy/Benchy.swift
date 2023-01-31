import Foundation
import BenchyLib

@main
struct Benchy {
	static func main() async throws {
		try NSDictionaryBufferToData.runBenchmarks()
	}
}
