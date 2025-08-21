//import CoreFoundation
//
//protocol CFRunLoopClient {
//  associatedtype RunLoop = AnyObject & Hashable
//  associatedtype RunLoopSource = AnyObject & Hashable
//
//  func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode)
//  func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode)
//}
//
//struct CFRunLoopClientLive: CFRunLoopClient {
//  func addSource(runLoop: CFRunLoop, source: CFRunLoopSource, mode: CFRunLoopMode) {
//    CFRunLoopAddSource(runLoop, source, mode)
//  }
//
//  func removeSource(runLoop: CFRunLoop, source: CFRunLoopSource, mode: CFRunLoopMode) {
//    CFRunLoopRemoveSource(runLoop, source, mode)
//  }
//}
//
//
