import SwiftUI

struct VCRepresentable: UIViewControllerRepresentable {
    let preventsCapture: Bool

    func makeUIViewController(context: Context) -> AVSampleBufferViewController {
        let vc = AVSampleBufferViewController(
            preventsCapture: preventsCapture
        )
        return vc
    }

    func updateUIViewController(_ vc: UIViewControllerType, context: Context) {
    }
}
