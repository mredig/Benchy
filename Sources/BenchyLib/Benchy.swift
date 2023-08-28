import Foundation
import Table

public struct Benchy {
	private var benchyComparatorCollection: [any BenchyComparator.Type] = []

	internal var results: [String: ResultStats] = [:]

	public init(benchyComparatorCollection: [any BenchyComparator.Type] = [], results: [String : ResultStats] = [:]) {
		self.benchyComparatorCollection = benchyComparatorCollection
		self.results = results
	}

	public mutating func addBenchyTest(_ benchmark: any BenchyComparator.Type) throws {
		guard
			benchyComparatorCollection.contains(where: { $0.id == benchmark.id }) == false
		else { throw BenchyError.alreadyAddedCollection }

		benchyComparatorCollection.append(benchmark)
		try benchmark.setupBenchmarks()
	}

	public mutating func runBenchmarks(cleanup: Bool = true) throws {
		for comparator in benchyComparatorCollection {
			let results = try comparator.runCollections()
			for result in results {
				self.results[result.label] = result
			}
			if cleanup {
				comparator.cleanup()
			}
		}

		if cleanup {
			benchyComparatorCollection.removeAll()
		}
	}

	public mutating func displayResults(decimalCount: Int = 4, cleanup: Bool = false) {
		let sorted = results.sorted(by: {
			$0.value.average < $1.value.average
		})

		var tableData: [[String]] = [
			["Label", "Avg", "Max", "Min", "Delta", "Median"],
		]

		let numberFormatter = NumberFormatter()
		numberFormatter.minimumFractionDigits = decimalCount
		numberFormatter.maximumFractionDigits = decimalCount

		for (label, stats) in sorted {
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
			if cleanup {
				results.removeAll()
			}
		} catch {
			print("Error creating table: \(error)")
		}
	}

	enum BenchyError: Error {
		case alreadyAddedCollection
	}
}

@inlinable
public func measureDuration(block: () -> Void) -> TimeInterval {
	let start = CFAbsoluteTimeGetCurrent()

	block()

	let end = CFAbsoluteTimeGetCurrent()

	let duration = end - start

	return duration
}
