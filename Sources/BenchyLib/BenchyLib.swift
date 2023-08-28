import Foundation
import Table

public enum Benchy {
	private static var benchyCollection: [any BenchyCollection.Type] = []

	internal static var results: [String: ResultStats] = [:]


	public static func addBenchyTest(_ benchmark: any BenchyCollection.Type) throws {
		guard
			benchyCollection.contains(where: { $0.id == benchmark.id }) == false
		else { throw BenchyError.alreadyAddedCollection }

		benchyCollection.append(benchmark)
		try benchmark.setupBenchmarks()
	}

	public static func runBenchmarks() throws {
		for collection in benchyCollection {
			let results = try collection.runCollections()
			for result in results {
				self.results[result.label] = result
			}
		}

		benchyCollection.removeAll()
	}

	public static func displayResults() {
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

	enum BenchyError: Error {
		case alreadyAddedCollection
	}
}

public func measureDuration(block: () -> Void) -> TimeInterval {
	let start = CFAbsoluteTimeGetCurrent()

	block()

	let end = CFAbsoluteTimeGetCurrent()

	let duration = end - start

	return duration
}
