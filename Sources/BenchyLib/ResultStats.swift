import Foundation

public struct ResultStats {
	let label: String
	let average: TimeInterval
	let max: TimeInterval
	let min: TimeInterval
	let median: TimeInterval

	var range: Range<TimeInterval> { min..<max }

}
