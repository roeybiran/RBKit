import Dependencies
import DependenciesMacros
import Foundation

// MARK: - SysctlClient

@DependencyClient
struct SysctlClient: Sendable {
  var run: @Sendable (
    _: UnsafeMutablePointer<Int32>?,
    _: u_int,
    _: UnsafeMutableRawPointer?,
    _ oldlenp: UnsafeMutablePointer<Int>?,
    _: UnsafeMutableRawPointer?,
    _ newlen: Int
  ) -> Int32 = { _, _, _, _, _, _ in -1 }

  func isZombie(pid: pid_t) -> Bool {
    var kinfo = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
    var size = MemoryLayout<kinfo_proc>.stride

    _ = run(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
    _ = withUnsafePointer(to: &kinfo.kp_proc.p_comm) {
      String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
    }
    return kinfo.kp_proc.p_stat == SZOMB
  }
}

// MARK: DependencyKey

extension SysctlClient: DependencyKey {
  static let liveValue = Self(run: sysctl)

  static let testValue = Self()

  #if DEBUG
  static let nonZombie = SysctlClient(run: { _, _, _, _, _, _ in 0 })
  #endif
}

extension DependencyValues {
  var sysctlClient: SysctlClient {
    get { self[SysctlClient.self] }
    set { self[SysctlClient.self] = newValue }
  }
}
