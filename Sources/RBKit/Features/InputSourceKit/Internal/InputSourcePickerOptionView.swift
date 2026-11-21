import SwiftUI

struct InputSourcePickerOptionView: View {

  // MARK: Private

  let inputSource: InputSource?

  // MARK: Internal

  var body: some View {
    Group {
      if let inputSource {
        Text(inputSource.name)
      } else {
        Text("None")
      }
    }
    .tag(inputSource?.id as InputSource.ID?)
  }

}
