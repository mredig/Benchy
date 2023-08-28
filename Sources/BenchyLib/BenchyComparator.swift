import Foundation

/**
A `BenchyComparator` is a collection of benchmarks that are intended to be compared against each other. For example,
comparing the speed of initializing `Date` vs getting a value from `CFAbsoluteTimeGetCurrent` - one benchmark would
initialize a lot of `Date`s, another would store the result of `CFAbsoluteTimeGetCurrent` the same number of times,
then when running the benchmarks, these two benchmarks would be compared within the same table.
 */
public protocol BenchyComparator {
	static var benchmarks: [ChildBenchmark] { get set }
	static var iterations: Int { get }
	typealias ChildBenchmark = Benchmark<Self>

	/**
	 This method offers a place to create and add your benchmarks to the `BenchyComparator`. A fleshed out implementation
	 is not a requirement, as you may simply create and add benchmarks yourself via `addBenchmark`, `addBenchmarks`, or
	 using the `ChildBenchmark`'s `autoTrack` default value of `true` in the initializer
	 */
	static func setupBenchmarks() throws
}

public extension BenchyComparator {
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

	static func addBenchmark(withLabel label: String, iterations: Int, printOutput: PrintSettings, block: @escaping (Int, String) -> Void) {
		addBenchmark(Benchmark<Self>(
			label: label,
			printOutput: printOutput,
			block: block))
	}

	static func cleanup() {
		benchmarks.removeAll()
	}
}
