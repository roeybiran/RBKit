import Foundation
@testable import RBKit

extension CrashReport {
  static func mock() -> Self {
    CrashReport(
      url: .init(string: "https://example.com")!,
      date: .now,
      contents: """
        Incididunt amet adipisicing enim sunt eu nisi mollit proident incididunt nisi cupidatat deserunt. Exercitation ad consequat id id pariatur occaecat ad esse consequat. Elit sunt ad reprehenderit id ad tempor ullamco tempor esse adipisicing dolore sunt incididunt dolore. Pariatur ullamco ut voluptate magna reprehenderit aute et incididunt id duis ut do minim pariatur.

        Enim elit in id esse. Eu dolor non consequat aliqua culpa fugiat minim deserunt nulla commodo sint anim labore. Deserunt excepteur exercitation do. Incididunt in excepteur nulla magna eu cupidatat est id.

        Veniam sit aliqua amet. Est aliquip sit nisi ullamco ea aliqua magna occaecat sit exercitation occaecat. Sint minim tempor consequat reprehenderit eiusmod sit proident officia tempor aute nulla et officia amet Lorem. Ipsum elit commodo deserunt velit officia adipisicing. Ea nostrud elit ex ad occaecat consequat sit sunt consectetur labore qui voluptate veniam nisi fugiat. Veniam Lorem dolor labore velit incididunt ipsum aliquip laborum reprehenderit aliqua excepteur esse. Commodo cupidatat voluptate dolore commodo aliquip irure labore velit. Adipisicing commodo irure Lorem amet voluptate excepteur ut.
        """,
    )
  }
}
