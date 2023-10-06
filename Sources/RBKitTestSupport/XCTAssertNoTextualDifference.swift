import XCTest

public func XCTAssertNoTextualDifference<T>(
	_ expression1: T,
	_ expression2: T,
	showDiff: Bool = false,
  file: StaticString = #file,
	line: UInt = #line)
{
	var output1 = ""
	var output2 = ""

	dump(expression1, to: &output1)
	dump(expression2, to: &output2)

	XCTAssertEqual(output1, output2, file: file, line: line)

	if showDiff, output1 != output2 {
		showInFileMerge(output1, output2)
	}
}

public func showInFileMerge(_ output1: String, _ output2: String) {
	let baseURL = FileManager.default.temporaryDirectory
	let path1 = baseURL.appendingPathComponent("1").appendingPathExtension("txt").path
	let path2 = baseURL.appendingPathComponent("2").appendingPathExtension("txt").path
	output1.write(toFile: path1)
	output2.write(toFile: path2)
	runShellScript(args: "/usr/bin/opendiff", path1, path2)
}

extension String {
	fileprivate func write(toFile path: String) {
		try? write(toFile: path, atomically: true, encoding: .utf8)
	}
}

private func runShellScript(args: String...) {
	DispatchQueue.global().async {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: args[0])
		task.arguments = Array(args[1...])
		try? task.run()
	}
}
