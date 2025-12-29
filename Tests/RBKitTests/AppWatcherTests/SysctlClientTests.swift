import Dependencies
import Foundation
import Testing
@testable import RBKit

@Suite
struct `SysctlClient Tests` {
  @Test
  func `With process is zombie, isZombie returns true`() async throws {
    let client = SysctlClient(
      run: { _, _, oldp, _, _, _ in
        guard let kinfo = oldp?.assumingMemoryBound(to: kinfo_proc.self) else { return -1 }
        kinfo.pointee.kp_proc.p_stat = CChar(SZOMB)
        return 0
      }
    )

    #expect(client.isZombie(pid: 123) == true)
  }

  @Test
  func `With process is not zombie, isZombie returns false`() async throws {
    let client = SysctlClient(
      run: { _, _, oldp, _, _, _ in
        guard let kinfo = oldp?.assumingMemoryBound(to: kinfo_proc.self) else { return -1 }
        kinfo.pointee.kp_proc.p_stat = CChar(SRUN)
        return 0
      }
    )

    #expect(client.isZombie(pid: 123) == false)
  }

  @Test
  func `isZombie should call dependency once and with correct parameters`() async throws {
    nonisolated(unsafe) var callCount = 0
    
    let client = SysctlClient(
      run: { mib, count, oldp, oldlenp, _, _ in
        callCount += 1
        let capturedMib = Array(UnsafeBufferPointer(start: mib, count: Int(count)))
        let capturedSize = oldlenp?.pointee
        let capturedCount = count
        #expect(capturedMib == [CTL_KERN, KERN_PROC, KERN_PROC_PID, 123])
        #expect(capturedSize == MemoryLayout<kinfo_proc>.stride)
        #expect(capturedCount == 4)
        guard let kinfo = oldp?.assumingMemoryBound(to: kinfo_proc.self) else { return -1 }
        kinfo.pointee.kp_proc.p_stat = CChar(SRUN)
        return 0
      }
    )

    _ = client.isZombie(pid: 123)
    
    #expect(callCount == 1)
  }
}
