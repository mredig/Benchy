import Foundation

public enum DefaultBenchyComparator: BenchyComparator {
	public static var benchmarks: [ChildBenchmark] = []
	public static var iterations: Int = 1

	public static func setupBenchmarks() throws {}
}
