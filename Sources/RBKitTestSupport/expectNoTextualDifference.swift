import Foundation
import Testing

public func expectNoTextualDifference<T: Equatable>(
  _ expression1: T,
  _ expression2: T,
  showDiffInFileMerge: Bool
) async {
  let areEqual = expression1 == expression2
  if areEqual { return }

  #expect(areEqual)

  var output1 = ""
  var output2 = ""

  dump(expression1, to: &output1)
  dump(expression2, to: &output2)

  guard showDiffInFileMerge else { return }

  let baseURL = FileManager.default.temporaryDirectory
  let path1 = baseURL.appendingPathComponent("left").appendingPathExtension("txt").path
  let path2 = baseURL.appendingPathComponent("right").appendingPathExtension("txt").path

  try? output1.write(toFile: path1, atomically: true, encoding: .utf8)
  try? output2.write(toFile: path2, atomically: true, encoding: .utf8)

  let task = Process()
  task.executableURL = URL(fileURLWithPath: "/usr/bin/opendiff")
  task.arguments = [path1, path2]
  try? task.run()
}
