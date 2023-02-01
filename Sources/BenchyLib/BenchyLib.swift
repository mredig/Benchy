import Foundation
import Table

public struct ResultStats {
	let average: TimeInterval
	let max: TimeInterval
	let min: TimeInterval
	let median: TimeInterval

	var range: Range<TimeInterval> { min..<max }

}
private var results: [String: ResultStats] = [:]

@discardableResult
public func benchmark(label: String, iterations: Int = 1000, printOutput: Bool = true, block: (Int, String) -> TimeInterval) -> TimeInterval {
	var times: [TimeInterval] = []
	let duration = measureDuration {
		for i in 1...iterations {
			autoreleasepool {
				let time = block(i, label)
				times.append(time)
			}
		}
	}

	if printOutput {
		print("Test '\(label)' with \(iterations) iterations took \(duration) seconds\n")
	}

	let avg = times.reduce(0, +) / Double(times.count)

	let stats = ResultStats(
		average: avg,
		max: times.max() ?? 0,
		min: times.min() ?? 0,
		median: times[times.count / 2])
	results[label] = stats

	return duration
}


public func measureDuration(block: () -> Void) -> TimeInterval {
	let start = Date()

	block()

	let end = Date()

	let duration = end.timeIntervalSince(start)

	return duration
}

public func displayResults() {
	let sorted = results.sorted(by: {
		$0.value.average < $1.value.average
	})

	var tableData: [[String]] = [
		["Label", "Avg", "Max", "Min", "Delta", "Median"],
	]

	let numberFormatter = NumberFormatter()
	numberFormatter.minimumFractionDigits = 4
	numberFormatter.maximumFractionDigits = 4

	for (label, stats) in sorted {
//		print("\(label) took an average of \(stats.average) taking at most \(stats.max) and \(stats.min) at its fastest. There was a \(stats.max - stats.min) delta between the extremities. The median time was \(stats.median)")
		tableData.append([
			label,
			numberFormatter.string(from: stats.average as NSNumber) ?? "nan",
			numberFormatter.string(from: stats.max as NSNumber) ?? "nan",
			numberFormatter.string(from: stats.min as NSNumber) ?? "nan",
			numberFormatter.string(from: (stats.max - stats.min) as NSNumber) ?? "nan",
			numberFormatter.string(from: stats.median as NSNumber) ?? "nan",
		])
	}

	do {
		let table = try Table(data: tableData).table()
		print(table)
	} catch {
		print("Error creating table: \(error)")
	}
}

public protocol BenchyTest {
	static func runBenchmarks() throws
}
