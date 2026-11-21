@preconcurrency import Carbon
import Dependencies
import Foundation
@preconcurrency @testable import RBKit

@MainActor
func makeService(
  textInputSourcesClient: TextInputSourcesClientMock,
  distributedNotificationCenterClient: DistributedNotificationCenterClient = .testValue,
) -> InputSourceService<TextInputSourcesClientMock> {
  withDependencies {
    $0.distributedNotificationCenterClient = distributedNotificationCenterClient
  } operation: {
    InputSourceService(textInputSourcesClient: textInputSourcesClient)
  }
}

func makeTextInputSourcesClientMock(sources: [InputSource], currentSourceID: String?) -> (
  client: TextInputSourcesClientMock,
  sourceRefByID: [String: TextInputSourceMock],
) {
  let sourceRefByID: [String: TextInputSourceMock] = Dictionary(uniqueKeysWithValues: sources.map { source in
    (source.id, TextInputSourceMock())
  })

  nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
    uniqueKeysWithValues: sources.compactMap { source in
      guard let sourceRef = sourceRefByID[source.id] else { return nil }

      let properties: [CFString: AnyObject] = [
        kTISPropertyInputSourceID: source.id as NSString,
        kTISPropertyLocalizedName: source.name as NSString,
      ]

      return (ObjectIdentifier(sourceRef), properties)
    }
  )

  let client = TextInputSourcesClientMock()
  client.TISCreateInputSourceListHandler = { _, _ in
    Unmanaged.passRetained(Array(sourceRefByID.values) as CFArray)
  }
  client.TISCopyCurrentKeyboardInputSourceHandler = {
    if let currentSourceID, let sourceRef = sourceRefByID[currentSourceID] {
      return Unmanaged.passRetained(sourceRef)
    }

    return nil
  }
  client.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
    if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
      UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
    } else {
      nil
    }
  }

  return (client, sourceRefByID)
}
