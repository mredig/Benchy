import Foundation

@discardableResult
public func benchmark(label: String, iterations: Int = 1000, printOutput: Bool = true, block: (Int, String) -> Void) -> TimeInterval {
	let duration = measureDuration {
		for i in 1...iterations {
			autoreleasepool {
				block(i, label)
			}
		}
	}

	if printOutput {
		print("Test '\(label)' with \(iterations) iterations took \(duration) seconds\n")
	}
	return duration
}


public func measureDuration(block: () -> Void) -> TimeInterval {
	let start = Date()

	block()

	let end = Date()

	let duration = end.timeIntervalSince(start)

	return duration
}
