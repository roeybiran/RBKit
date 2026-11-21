import Cocoa
import ServiceManagement

@MainActor
struct Dependencies {
  static var live = Self(
    register: SMAppService.mainApp.register, // throws kSMErrorAlreadyRegistered or kSMErrorLaunchDeniedByUser
    unregister: SMAppService.mainApp.unregister, // throws kSMErrorJobNotFound
    getStatus: { SMAppService.mainApp.status },
    openURL: NSWorkspace.shared.open,
  )

  static var failing = Self(
    register: { fatalError("Dependencies.failing.register is unimplemented") },
    unregister: { fatalError("Dependencies.failing.unregister is unimplemented") },
    getStatus: { fatalError("Dependencies.failing.getStatus is unimplemented") },
    openURL: { _ in fatalError("Dependencies.failing.openURL is unimplemented") },
  )

  var register: () throws -> Void
  var unregister: () throws -> Void
  var getStatus: () -> SMAppService.Status
  var openURL: (_ url: URL) -> Bool

}
