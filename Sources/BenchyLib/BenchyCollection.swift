import Foundation

public protocol BenchyCollection {
	static var benchmarks: [ChildBenchmark] { get set }
	typealias ChildBenchmark = Benchmark<Self>

	static func setupBenchmarks() throws
}

public extension BenchyCollection {
	static var id: String { "\(type(of: Self.self))" }

	static func runCollections() throws -> [ResultStats] {
		var stats: [ResultStats] = []
		for benchmark in benchmarks {
			stats.append(try benchmark.runBenchmark())
		}
		return stats
	}

	static func addBenchmark(_ benchmark: ChildBenchmark) {
		guard
			benchmarks.contains(where: { $0.label == benchmark.label }) == false
		else {
			print("Already have a benchmark labelled with \(benchmark.label). Skipping.")
			return
		}

		benchmarks.append(benchmark)
	}

	static func addBenchmarks(_ benchmarks: [ChildBenchmark]) {
		for benchmark in benchmarks {
			addBenchmark(benchmark)
		}
	}

	static func addBenchmark(withLabel label: String, iterations: Int, printOutput: Bool, block: @escaping (Int, String) -> Void) {
		addBenchmark(Benchmark<Self>(
			label: label,
			iterations: iterations,
			printOutput: printOutput,
			block: block))
	}
}
