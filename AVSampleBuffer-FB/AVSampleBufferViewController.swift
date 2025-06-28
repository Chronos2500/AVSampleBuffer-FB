import AVFoundation
import SwiftUI
import UIKit

// MARK: - UIViewController
class AVSampleBufferViewController: UIViewController {
    private var displayLayer: AVSampleBufferDisplayLayer!

    var preventsCapture: Bool

    init(preventsCapture: Bool) {
        self.preventsCapture = preventsCapture
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplayLayer()
        displayBlackFrame()
    }

    private func setupDisplayLayer() {
        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.frame = view.bounds
        displayLayer.videoGravity = .resizeAspectFill

        displayLayer.preventsCapture = self.preventsCapture

        view.layer.addSublayer(displayLayer)
    }

    private func displayBlackFrame() {
        guard let pixelBuffer = createBlackPixelBuffer(width: 1, height: 1)
        else { return }
        guard let sampleBuffer = createSampleBuffer(from: pixelBuffer) else {
            return
        }

        if #available(iOS 17.0, *) {
            displayLayer.sampleBufferRenderer.enqueue(sampleBuffer)
        } else {
            // iOS 16以下では従来の方法
            displayLayer.enqueue(sampleBuffer)
        }
    }

    private func createBlackPixelBuffer(width: Int, height: Int)
        -> CVPixelBuffer?
    {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_32BGRA,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        let baseAddress = CVPixelBufferGetBaseAddress(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let bufferSize = bytesPerRow * height

        memset(baseAddress, 0, bufferSize)

        if let pixels = baseAddress?.assumingMemoryBound(to: UInt8.self) {
            for i in stride(from: 3, to: bufferSize, by: 4) {
                pixels[i] = 255
            }
        }

        return buffer
    }

    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer)
        -> CMSampleBuffer?
    {
        var sampleBuffer: CMSampleBuffer?
        var formatDescription: CMVideoFormatDescription?

        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )

        guard status == noErr, let formatDesc = formatDescription else {
            return nil
        }

        var timingInfo = CMSampleTimingInfo()
        timingInfo.duration = CMTime.invalid
        timingInfo.presentationTimeStamp = CMTime.zero
        timingInfo.decodeTimeStamp = CMTime.invalid

        let sampleStatus = CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDesc,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        guard sampleStatus == noErr else {
            return nil
        }

        return sampleBuffer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayLayer?.frame = view.bounds
    }
}
