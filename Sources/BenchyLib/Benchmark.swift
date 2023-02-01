import Foundation

public struct Benchmark<TestParent: BenchyCollection> {
	public init(label: String, iterations: Int, printOutput: Bool = true, block: @escaping (Int, String) -> Void, autotrack: Bool = false) {
		self.label = label
		self.iterations = iterations
		self.printOutput = printOutput
		self.block = block

		if autotrack {
			TestParent.addBenchmark(self)
		}
	}

	public let label: String
	public let iterations: Int
	public let printOutput: Bool
	public let block: (Int, String) -> Void

	public func runBenchmark() throws -> ResultStats {
		var times: [TimeInterval] = []
		let duration = measureDuration {
			for i in 1...iterations {
				autoreleasepool {
					let time = measureDuration {
						block(i, label)
					}
					times.append(time)
					if printOutput {
						print("'\(label)' iteration \(i) took \(time) seconds")
					}
				}
			}
		}

		if printOutput {
			print("Test '\(label)' with \(iterations) iterations took \(duration) seconds\n")
		}

		let avg = times.reduce(0, +) / Double(times.count)

		let stats = ResultStats(
			label: label,
			average: avg,
			max: times.max() ?? 0,
			min: times.min() ?? 0,
			median: times[times.count / 2])

		return stats
	}
}
