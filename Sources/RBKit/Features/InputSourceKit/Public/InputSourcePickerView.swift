import Dependencies
import SwiftUI

@MainActor
public struct InputSourcePickerView: View {

  // MARK: Lifecycle

  public init(label: String = "Preferred input source") {
    self.label = label
  }

  // MARK: Public

  public var body: some View {
    Picker(label, selection: Binding(
      get: { preferredInputSourceID },
      set: { sourceID in
        preferredInputSourceID = sourceID
        let selectedSource = sources.first { $0.id == sourceID }
        inputSourceServiceClient.setPreferredInputSource(selectedSource)
      },
    )) {
      InputSourcePickerOptionView(inputSource: nil)
      ForEach(sources) { source in
        InputSourcePickerOptionView(inputSource: source)
      }
    }
    .help("The previously active input source will be restored when \(Bundle.main.appName) deactivates.")
    .task {
      for await latestSources in inputSourceServiceClient.start() {
        sources = latestSources
        preferredInputSourceID = inputSourceServiceClient.getPreferredInputSource()?.id
      }
    }
  }

  // MARK: Internal

  let label: String

  // MARK: Private

  @State private var sources = [InputSource]()
  @State private var preferredInputSourceID: InputSource.ID?

  @Dependency(\.inputSourceServiceClient) private var inputSourceServiceClient
}

#Preview {
  InputSourcePickerView()
}
