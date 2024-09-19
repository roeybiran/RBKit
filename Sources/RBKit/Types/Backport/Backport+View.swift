import SwiftUI

extension View {
  public var backport: Backport<Self> { Backport(self) }
}
