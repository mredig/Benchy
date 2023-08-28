//
//  File.swift
//  
//
//  Created by Michael Redig on 5/1/23.
//

import Foundation
import BenchyLib


enum DateVsCFAbsoluteTimeGetCurrent: BenchyComparator {
	static var benchmarks: [ChildBenchmark] = []
	static var iterations: Int = 999999

	static var dates: [Date] = []
	static var times: [TimeInterval] = []

	static func setupBenchmarks() throws {
		ChildBenchmark(
			label: "Date testing") { i, label in
				dates.append(Date())
			}

		ChildBenchmark(
			label: "CFTimeAbsoluteGetCurrent testing") { i, label in
				times.append(CFAbsoluteTimeGetCurrent())
			}
	}
}
