import Foundation

public struct PrintSettings: OptionSet {
	public var rawValue: UInt8 = 0

	/// If `.iteration` is included, how often should iterations be printed to the console? Default: `100`
	public var iterationFrequency = 100

	/// Print out the total duration of all iterations of this benchmark. Does not compensate for printing updates to the
	/// console, so if you have `.iteration` set, it is best to keep the frequency minimal to maintain accuracy.
	public static let finalTotalTime = PrintSettings(rawValue: 1 << 1)
	/// Every `iterationFrequency` iterations, prints out the iteration number and the duration of said iteration.
	public static let iteration = PrintSettings(rawValue: 1 << 2)
	/// Prints to the console when this benchmark is starting up.
	public static let startMetaData = PrintSettings(rawValue: 1 << 3)
	/// Prints to the console when this benchmark is finished.
	public static let endMetaData = PrintSettings(rawValue: 1 << 4)
	/// A convenient combination of `.startMetaData` and `.endMetaData`.
	public static let metaData: PrintSettings = [.startMetaData, .endMetaData]
	/// A convenient combination of every possible flag.
	public static let all: PrintSettings = [.metaData, .iteration, .finalTotalTime]

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}
}

public struct Benchmark<TestParent: BenchyComparator> {
	public let label: String
	public var iterations: Int { TestParent.iterations }
	public let printOutput: PrintSettings
	public let block: (Int, String) -> Void

	@discardableResult
	public init(
		label: String,
		printOutput: PrintSettings = [.finalTotalTime, .metaData],
		block: @escaping (Int, String) -> Void,
		autotrack: Bool = true) {
			self.label = label
			self.printOutput = printOutput
			self.block = block

			if autotrack {
				TestParent.addBenchmark(self)
			}
		}

	public func runBenchmark() throws -> ResultStats {
		if printOutput.contains(.startMetaData) {
			print("Starting '\(label)' with \(iterations) iterations.")
		}
		defer {
			if printOutput.contains(.endMetaData) {
				print("Finished '\(label)' with \(iterations) iterations.")
			}
			
			if printOutput.isEmpty == false {
				print("\n")
			}
		}
		var times: [TimeInterval] = []
		if 
			TestParent.self == DefaultBenchyComparator.self,
			TestParent.iterations == 1 {

			print("🧡🧡🧡 Warning! Only 1 iteration on DefaultBenchyComparator! 🧡🧡🧡 ")
		}
		let duration = measureDuration {
			for i in 1...iterations {
				autoreleasepool {
					let time = measureDuration {
						block(i, label)
					}
					times.append(time)
					if printOutput.contains(.iteration), i.isMultiple(of: printOutput.iterationFrequency) {
						print("'\(label)' iteration \(i) took \(time) seconds")
					}
				}
			}
		}

		if printOutput.contains(.finalTotalTime) {
			print("Test '\(label)' with \(iterations) iterations took \(duration) seconds.")
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
