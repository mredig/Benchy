//
//  File.swift
//  
//
//  Created by Michael Redig on 5/1/23.
//

import Foundation
import BenchyLib


enum DateVsCFAbsoluteTimeGetCurrent: BenchyCollection {
	static var benchmarks: [ChildBenchmark] = []

	static var dates: [Date] = []
	static var times: [TimeInterval] = []

	static func setupBenchmarks() throws {
		let iterations = 99999999
		let dateBench = ChildBenchmark(
			label: "Date testing",
			iterations: iterations) { i, label in
				dates.append(Date())
			}
		benchmarks.append(dateBench)

		let cftimeBench = ChildBenchmark(
			label: "CFTimeAbsoluteGetCurrent testing",
			iterations: iterations) { i, label in
				times.append(CFAbsoluteTimeGetCurrent())
			}
		benchmarks.append(cftimeBench)
	}
}
