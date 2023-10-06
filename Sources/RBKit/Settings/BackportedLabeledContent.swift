import SwiftUI

public struct BackportedLabeledContent<Label, Content>: View where Label: View, Content: View {
  private let content: Content
  private let label: Label

  public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label ) {
    self.content = content()
    self.label = label()
  }

  public var body: some View {
    if #available(macOS 13.0, *) {
      LabeledContent {
        content
      } label: {
        label
      }
    } else {
      HStack {
        VStack(alignment: .leading) {
          label
        }
        Spacer()
        Group {
          content
        }
      }
    }
  }
}

struct BackportedLabeledContent_Previews: PreviewProvider {
    static var previews: some View {
      BackportedLabeledContent {
        Button("Open") {
          print("hello")
        }
      } label: {
        Text("Example Settings Label")
        Text("Example Settings Explanation Text")
      }
    }
}
