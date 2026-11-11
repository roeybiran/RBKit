# RBKit

Utilities for developing Mac apps with Swift.

## Development setup

After cloning:

```sh
git config core.hooksPath .githooks
```

## Contents

Everything lives in the single `RBKit` module:

- **AXKit** (`Sources/RBKit/AXKit`): a type-safe wrapper around `AXUIElement.h`.
- **OutlineViewDiffable**: a diffable data source for `NSOutlineView`.
- **CrashReporterKit**, **InputSourceKit**, **LoginItemKit**, **RBAgentWindow**, **SettingsKit**, **RBUILib**: app building blocks.
- Feature clients (AppWatcher, EventTapManager, HotKeyManager, FuzzyKit, FrecencyKit, PathWatcher, …), extensions and views.

`RBKitTestSupport` provides shared test helpers and mocks.

### Opt-in libraries

These are separate products. Importing `RBKit` never compiles or links them or their dependencies:

| Product | Adds |
|---|---|
| `HotKeyRecorder` | ComposableArchitecture |
| `PermissionsKit` | ComposableArchitecture |
| `OnboardingKit` | ComposableArchitecture, PermissionsKit, RBAnalytics |
| `RBAnalytics` | TelemetryDeck |
| `SparkleExtras` | Sparkle |

The `RBKitDemo` app (`RBKitDemo/RBKitDemo.xcodeproj`) has a page for each area.

## AXKit

### Testability

Because `AXUIElement.h` uses opaque CF types, testing is nearly impossible without resorting to mocks. The AX client is generic mainly for this purpose, and RBKit ships a complete mock implementation (`AXClientMock`, `UIElementMock`, `ObserverMock`).

#### Usage

In your app, you'll typically create a generic class that wraps over `AXClientProtocol`. That class should return native Swift types relevant to your domain. For example:

```swift
import RBKit

struct MenuItem {
  let title: String
}

class MenuService<AXClient: AXClientProtocol> {
  let client: Client

  init(client: Client) {
    self.client = client
  }

  func getMenuItems(for application: pid_t) throws -> [MenuItem] {
    let appElement = client.application(pid: application)
    let menuBar = try client.attributeValue(element: appElement, for: client.menuBar)
    // ... convert to MenuItem array
    return []
  }
}
```

In production, you'll use `AXClientLive`:

```swift
let service = MenuService(client: AXClientLive())
```

#### Testing with mocks

When testing your class, inject `AXClientMock` and override the `var _closures` (not the methods). The mock exposes configurable closures for every protocol method:

```swift
import RBKit
import Testing

@Test
func getMenuItems_shouldReturnMenuItems() throws {
  let mock = AXClientMock()
  let mockElement = UIElementMock(id: "menu-bar")
  
  // Override the closure, not the method
  mock._application = { pid in UIElementMock(id: "app-\(pid)") }
  mock._attributeValue = { element, attribute, value in
    value.pointee = mockElement
    return .success
  }
  
  let sut = MenuService(client: mock)
  let items = try sut.getMenuItems(for: 12345)
  // Assert on items...
}
```

**Important**: Always override the `var _closures` (like `_application`, `_attributeValue`, etc.), not the protocol methods themselves. The mock methods delegate to these closures, allowing you to control behavior in tests.

### References

- [/System/Library/Accessibility/AccessibilityDefinitions.plist](/System/Library/Accessibility/AccessibilityDefinitions.plist) (a snapshot is in `Resources/AXKit/`; see `Scripts/generate_accessibility_types.sh`)

### Acknowledgements

- [AXSwift](https://github.com/tmandry/AXSwift)
