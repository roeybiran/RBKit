import Dependencies
import Testing

@testable import RBKit

// MARK: - MigrateToRBAgentWindowV2Tests

@MainActor
struct MigrateToRBAgentWindowV2Tests {

  @Test
  func `migrateToRBAgentWindowV2 should migrate preferredScreen withKeyboardFocus to integer 0`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        switch key {
        case "preferredScreen": return "withKeyboardFocus"
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { value, key in
        #expect(value == 0)
        #expect(key == String.DEFAULTS_KEY_PREFERRED_SCREEN)
        setIntCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "preferredScreen")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setIntCalled)
    #expect(removeObjectCalled)
  }

  @Test
  func `migrateToRBAgentWindowV2 should migrate preferredScreen withMouseCursor to integer 1`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        switch key {
        case "preferredScreen": return "withMouseCursor"
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { value, key in
        #expect(value == 1)
        #expect(key == String.DEFAULTS_KEY_PREFERRED_SCREEN)
        setIntCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "preferredScreen")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setIntCalled)
    #expect(removeObjectCalled)
  }

  @Test
  func `migrateToRBAgentWindowV2 should migrate preferredScreen withMenuBar to integer 2`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        switch key {
        case "preferredScreen": return "withMenuBar"
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { value, key in
        #expect(value == 2)
        #expect(key == String.DEFAULTS_KEY_PREFERRED_SCREEN)
        setIntCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "preferredScreen")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setIntCalled)
    #expect(removeObjectCalled)
  }

  @Test
  func `migrateToRBAgentWindowV2 should migrate unknown preferredScreen value to integer 0`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        switch key {
        case "preferredScreen": return "unknownValue"
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { value, key in
        #expect(value == 0) // Should default to withKeyboardFocus
        #expect(key == String.DEFAULTS_KEY_PREFERRED_SCREEN)
        setIntCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "preferredScreen")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setIntCalled)
    #expect(removeObjectCalled)
  }

  @Test
  func `migrateToRBAgentWindowV2 should migrate windowOriginCoordinates to separate double values`() {
    nonisolated(unsafe) var setDoubleCallCount = 0
    nonisolated(unsafe) var removeObjectCalled = false
    nonisolated(unsafe) var xFractionSet = false
    nonisolated(unsafe) var yFractionSet = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return ["x": 0.75, "y": 0.25]
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return ["x": 0.75, "y": 0.25]
        }
        return nil
      }
      d.userDefaultsClient.setDouble = { value, key in
        setDoubleCallCount += 1
        if key == String.DEFAULTS_KEY_WINDOW_ORIGIN_X_FRACTION {
          #expect(value == 0.75)
          xFractionSet = true
        } else if key == String.DEFAULTS_KEY_WINDOW_ORIGIN_Y_FRACTION {
          #expect(value == 0.25)
          yFractionSet = true
        } else {
          Issue.record("Unexpected key: \(key)")
        }
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "windowOriginCoordinates")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setDoubleCallCount == 2)
    #expect(xFractionSet)
    #expect(yFractionSet)
    #expect(removeObjectCalled)
  }

  @Test
  func `migrateToRBAgentWindowV2 should migrate both preferredScreen and windowOriginCoordinates`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var setDoubleCallCount = 0
    nonisolated(unsafe) var removeObjectCallCount = 0
    nonisolated(unsafe) var xFractionSet = false
    nonisolated(unsafe) var yFractionSet = false

    withDependencies { d in
      d.userDefaultsClient.string = { key in
        switch key {
        case "preferredScreen": return "withMenuBar"
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return ["x": 0.3, "y": 0.7]
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return ["x": 0.3, "y": 0.7]
        }
        return nil
      }
      d.userDefaultsClient.setInt = { value, key in
        #expect(value == 2) // withMenuBar
        #expect(key == String.DEFAULTS_KEY_PREFERRED_SCREEN)
        setIntCalled = true
      }
      d.userDefaultsClient.setDouble = { value, key in
        setDoubleCallCount += 1
        if key == String.DEFAULTS_KEY_WINDOW_ORIGIN_X_FRACTION {
          #expect(value == 0.3)
          xFractionSet = true
        } else if key == String.DEFAULTS_KEY_WINDOW_ORIGIN_Y_FRACTION {
          #expect(value == 0.7)
          yFractionSet = true
        } else {
          Issue.record("Unexpected key: \(key)")
        }
      }
      d.userDefaultsClient.removeObject = { key in
        removeObjectCallCount += 1
        #expect(key == "preferredScreen" || key == "windowOriginCoordinates")
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    #expect(setIntCalled)
    #expect(setDoubleCallCount == 2)
    #expect(xFractionSet)
    #expect(yFractionSet)
    #expect(removeObjectCallCount == 2)
  }

  @Test
  func `migrateToRBAgentWindowV2 should handle missing x value in windowOriginCoordinates`() {
    nonisolated(unsafe) var setDoubleCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return ["y": 0.5] // Missing x value
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return ["y": 0.5] // Exists as dictionary but missing x
        }
        return nil
      }
      d.userDefaultsClient.setDouble = { _, _ in
        setDoubleCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "windowOriginCoordinates")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    // Should not migrate values if x or y values are missing, but should still remove the key
    #expect(setDoubleCalled == false)
    #expect(removeObjectCalled == true)
  }

  @Test
  func `migrateToRBAgentWindowV2 should handle missing y value in windowOriginCoordinates`() {
    nonisolated(unsafe) var setDoubleCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return ["x": 0.5] // Missing y value
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return ["x": 0.5] // Exists as dictionary but missing y
        }
        return nil
      }
      d.userDefaultsClient.setDouble = { _, _ in
        setDoubleCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "windowOriginCoordinates")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    // Should not migrate values if x or y values are missing, but should still remove the key
    #expect(setDoubleCalled == false)
    #expect(removeObjectCalled == true)
  }

  @Test
  func `migrateToRBAgentWindowV2 should handle non-double values in windowOriginCoordinates`() {
    nonisolated(unsafe) var setDoubleCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return ["x": "0.5", "y": 0.5] // x is string, not double
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return ["x": "0.5", "y": 0.5] // Exists as dictionary but x is wrong type
        }
        return nil
      }
      d.userDefaultsClient.setDouble = { _, _ in
        setDoubleCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "windowOriginCoordinates")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    // Should not migrate values if they cannot be cast to Double, but should still remove the key
    #expect(setDoubleCalled == false)
    #expect(removeObjectCalled == true)
  }

  @Test
  func `migrateToRBAgentWindowV2 should handle windowOriginCoordinates with non-dictionary value`() {
    nonisolated(unsafe) var setDoubleCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { key in
        switch key {
        case "windowOriginCoordinates": return nil // Key exists but not as dictionary
        default:
          Issue.record("Unexpected key: \(key)")
          return nil
        }
      }
      // Mock that the key exists with some other type
      d.userDefaultsClient.object = { key in
        if key == "windowOriginCoordinates" {
          return "some string value" // Non-dictionary type
        }
        return nil
      }
      d.userDefaultsClient.setDouble = { _, _ in
        setDoubleCalled = true
      }
      d.userDefaultsClient.removeObject = { key in
        #expect(key == "windowOriginCoordinates")
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    // Should not migrate if key exists but is not a dictionary, but should still remove the key
    #expect(setDoubleCalled == false)
    #expect(removeObjectCalled == true)
  }

  @Test
  func `migrateToRBAgentWindowV2 should not migrate when no legacy data exists`() {
    nonisolated(unsafe) var setIntCalled = false
    nonisolated(unsafe) var setDoubleCalled = false
    nonisolated(unsafe) var removeObjectCalled = false

    withDependencies { d in
      d.userDefaultsClient.string = { _ in nil }
      d.userDefaultsClient.dictionary = { _ in nil }
      d.userDefaultsClient.object = { _ in nil }
      d.userDefaultsClient.setInt = { _, _ in
        setIntCalled = true
      }
      d.userDefaultsClient.setDouble = { _, _ in
        setDoubleCalled = true
      }
      d.userDefaultsClient.removeObject = { _ in
        removeObjectCalled = true
      }
    } operation: {
      migrateToRBAgentWindowV2()
    }

    // Should not perform any migration operations
    #expect(setIntCalled == false)
    #expect(setDoubleCalled == false)
    #expect(removeObjectCalled == false)
  }
}
