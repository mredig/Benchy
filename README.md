# Benchy

A convenient way to benchmark and compare code. You can use the executable to just run some code, or integrate into an existing project.

### Usage

1. add SPM package/import the library to your code/download and run the exe/whatever  
1. Create a Benchy instance:

	```swift
	var benchy = Benchy()
	```

1. Create a comparator to collect a few benchmarks to compare:

	```swift
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
	```

1. Add your comparator(s) to the benchy instance, then run the benchmarks:

	```swift
	try benchy.addBenchyTest(DateVsCFAbsoluteTimeGetCurrent.self)

	try benchy.runBenchmarks()
	```
	
1. Analyze your results

	```swift
	benchy.displayResults(decimalCount: 10)
	```
	
	```
	╔══════════════════════════════════╤══════════════╤══════════════╤══════════════╤══════════════╤══════════════╗
	║ Label                            │ Avg          │ Max          │ Min          │ Delta        │ Median       ║
	╟──────────────────────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────╢
	║ CFTimeAbsoluteGetCurrent testing │ 0.0000000366 │ 0.0004259348 │ 0.0000000000 │ 0.0004259348 │ 0.0000000000 ║
	╟──────────────────────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────╢
	║ Date testing                     │ 0.0000000389 │ 0.0007300377 │ 0.0000000000 │ 0.0007300377 │ 0.0000000000 ║
	╚══════════════════════════════════╧══════════════╧══════════════╧══════════════╧══════════════╧══════════════╝
	```
	
1. ?????
1. PROFIT!


### Contributing/General Goals
I initially wrote this because I wasn't aware of XCTest's `measure` method. However, after having used that for a little bit, I found it a little lacking. I feel like controlling iteration count and things like that are obtuse and confusing, but most limiting is that you can only run one `measure` block per test. That makes comparing different code complicated. 

So while this isn't going to completely replace XCTest's `measure` method (I have no intention to measure anything other than time efficiency), I would like to get a nice suite of tools going.

I want to add a protocol that will allow for storing historical runs to compare performance over time and notify if there are significant decrements in performance. Being a protocol, it would allow for users to use whatever storage method they want, be it a local flat file, a remote server, or anything in between.

At this moment, I don't have any other grand ideas for improvement, but I'm definitely open to contributions. The historical records one is one such suggestion. :)
