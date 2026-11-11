import Dependencies
import Testing
@testable import OnboardingKit

struct OnboardingClientTests {
  @Test
  func `getIsOnboarded() with .didOnboard == false, should return false`() async {
    await confirmation { c in
      withDependencies { d in
        d.userDefaultsClient.bool = { key in
          #expect(key == .DID_ONBOARD)
          c()
          return false
        }
      } operation: {
        let sut = OnboardingClient.liveValue
        #expect(!sut.getIsOnboarded())
      }
    }
  }

  @Test
  func `getIsOnboarded() with .didOnboard == true, should return true`() async {
    await confirmation { c in
      withDependencies { d in
        d.userDefaultsClient.bool = { key in
          #expect(key == .DID_ONBOARD)
          c()
          return true
        }
      } operation: {
        let sut = OnboardingClient.liveValue
        #expect(sut.getIsOnboarded())
      }
    }
  }

  @Test
  func `setIsOnboarded() with valid call, should set .didOnboard == true`() async {
    await confirmation { c in
      withDependencies { d in
        d.userDefaultsClient.setBool = { @Sendable value, key in
          #expect(value)
          #expect(key == .DID_ONBOARD)
          c()
        }
      } operation: {
        let sut = OnboardingClient.liveValue
        sut.setIsOnboarded()
      }
    }
  }
}
