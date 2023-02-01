//
//  SyncQRCodeView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

struct SyncQRCodeView: View {

    @ObservedObject var model: ShowQRCodeViewModel

    @ViewBuilder
    func progressView() -> some View {
        if model.code == nil {
            ZStack {
                SwiftUI.ProgressView()
            }.frame(width: 200, height: 200)
        }
    }

    @ViewBuilder
    func qrCodeSection() -> some View {
        if let code = model.code {
            VStack(spacing: 20) {
                QRCode(string: code)
                    .padding()

                Button {
                    model.share()
                } label: {
                    Label("Share Code", image: "SyncShare")
                }
                .buttonStyle(SyncLabelButtonStyle())
                .padding(.bottom, 20)
                .sheet(isPresented: $model.shareSheetVisible) {
                    ShareSheetView(activityItems: [ model.code ?? "" ])
                }
            }
        }
    }

    @ViewBuilder
    func instructions() -> some View {

        if model.code != nil {
            Text("Go to Settings > Sync in the **DuckDuckGo App** on a different device and scan the image above to connect instantly.")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
        }

    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                ZStack {
                    progressView()
                    qrCodeSection()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.white.opacity(0.09)))

                instructions()

                Spacer()

            }
            .padding(.horizontal, 20)
            .frame(maxWidth: SyncUIConstants.maxWidth, alignment: .center)
        }
        .navigationTitle("QR Code")
        .modifier(SyncBackButtonModifier())
    }

}

private struct QRCode: View {

    let context = CIContext()

    let string: String

    var body: some View {
        Image(uiImage: generateQRCode(from: string))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 200)
    }

    func generateQRCode(from text: String) -> UIImage {
        var qrImage = UIImage(systemName: "xmark.circle") ?? UIImage()
        let data = Data(text.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 20, y: 20)
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let image = context.createCGImage(
                outputImage,
                from: outputImage.extent) {
                qrImage = UIImage(cgImage: image)
            }
        }
        return qrImage
    }

}

private extension CIFilter {

    static func qrCodeGenerator() -> CIFilter {
        CIFilter(name: "CIQRCodeGenerator", parameters: [
            "inputCorrectionLevel": "H"
        ])!
    }

}

private struct ShareSheetView: UIViewControllerRepresentable {

    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        let size = uiViewController.preferredContentSize
        uiViewController.preferredContentSize = CGSize(width: size.width, height: size.height / 2)
    }
}
