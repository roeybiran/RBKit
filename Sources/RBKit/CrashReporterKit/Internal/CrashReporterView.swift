import AppKit
import Foundation
import SwiftUI

struct CrashReporterView: View {

  @Bindable var viewModel: CrashReporterViewModel

  var body: some View {
    Form {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(nsImage: NSImage(named: NSImage.cautionName)!)
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
          VStack(alignment: .leading, spacing: 6) {
            Text("\(Bundle.main.appName) Quit Unexpectedly")
              .font(.headline)
            Text(String.CRASH_REPORT_WINDOW_PROMPT)
          }
        }

        VStack(alignment: .leading) {
          Text("Problem Details and System Configuration")
            .font(.subheadline)
          TextEditor(text: .constant(viewModel.report.contents))
            .border(.separator)
            .monospaced()
            .textSelection(.enabled)
        }
      }
      HStack {
        Button("Close") {
          viewModel.close()
        }
        Spacer()
        Button("Reveal in Finder") {
          viewModel.revealInFinder()
        }
        Button {
          viewModel.copyToClipboard()
        } label: {
          ZStack {
            HStack(spacing: 4) {
              Image(systemName: viewModel.copyButtonIcon)
              Text(viewModel.copyButtonText)
            }
            .opacity(viewModel.copiedLabelOpacity)
            .accessibilityHidden(viewModel.isCopiedLabelAccessibilityHidden)

            Text("Copy to Clipboard")
              .opacity(viewModel.defaultLabelOpacity)
              .accessibilityHidden(viewModel.isDefaultLabelAccessibilityHidden)
          }
          .animation(.easeInOut(duration: 0.2), value: viewModel.showCopied)
        }
        .disabled(viewModel.isCopyButtonDisabled)
        Button("Email Report") {
          viewModel.emailReport()
        }
      }
    }
  }
}

#Preview {
  CrashReporterView(
    viewModel: CrashReporterViewModel(
      report: CrashReport(
        url: .init(string: "https://example.com")!,
        date: .now,
        contents: "Example crash report contents",
      ),
      email: String.EMAIL,
    )
  )
  .padding()
  .frame(width: 1000, height: 800)
}
