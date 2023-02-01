//
//  SyncRecoveryPDFView.swift
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
import DuckUI

struct SyncRecoveryPDFView: View {

    @Environment(\.presentationMode) var presentation

    let showRecoveryPDFAction: () -> Void

    var body: some View {
        VStack {
            Image("SyncDownloadRecoveryCode")
                .padding(.bottom, 20)

            Text("Save Recovery PDF?")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 24)

            Text(UserText.syncRecoveryPDFMessage)
                .lineLimit(nil)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                showRecoveryPDFAction()
            } label: {
                Text("Save Recovery PDF")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Text("Now Now")
            }
            .buttonStyle(SecondaryButtonStyle())
        }

    }

}
