import ApplicationServices
import Foundation

import Dependencies
import DependenciesMacros

// MARK: - ProcessesClient

@DependencyClient
struct ProcessesClient: Sendable {
  var getProcessInformation: @Sendable (
    _ psn: UnsafeMutablePointer<ProcessSerialNumber>,
    _ info: UnsafeMutablePointer<ProcessInfoRec>
  ) -> OSErr = { _, _ in 0 }
  var getProcessForPID: @Sendable (_ pid: pid_t, _ psn: UnsafeMutablePointer<ProcessSerialNumber>) -> OSStatus = { _, _ in 0 }
}

// MARK: DependencyKey

extension ProcessesClient: DependencyKey {
  static let liveValue = Self(
    getProcessInformation: GetProcessInformation,
    getProcessForPID: GetProcessForPID,
  )

  static let testValue = Self()
}

extension DependencyValues {
  var processesClient: ProcessesClient {
    get { self[ProcessesClient.self] }
    set { self[ProcessesClient.self] = newValue }
  }
}

/// see Processes.h
/// https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/api-wrappers/PrivateApis.swift#L228
@_silgen_name("GetProcessInformation") @discardableResult
func GetProcessInformation(_ psn: UnsafeMutablePointer<ProcessSerialNumber>, _ info: UnsafeMutablePointer<ProcessInfoRec>)
  -> OSErr

/// https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/api-wrappers/PrivateApis.swift#L232
@_silgen_name("GetProcessForPID") @discardableResult
func GetProcessForPID(_ pid: pid_t, _ psn: UnsafeMutablePointer<ProcessSerialNumber>) -> OSStatus

#if DEBUG
extension ProcessesClient {
  static let nonXPC = ProcessesClient(
    getProcessInformation: { _, info in
      info.pointee.processType = NSHFSTypeCodeFromFileType("'APPL'")
      return .zero
    },
    getProcessForPID: { _, _ in noErr },
  )
}
#endif
