//
//  EmailAddressPromptView.swift
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
import DesignResourcesKit

struct EmailAddressPromptView: View {

    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: EmailAddressPromptViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
    }

    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }

        return ZStack {
            AutofillViews.CloseButtonHeader(action: viewModel.closeButtonPressed)
                .offset(x: AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) ? Const.Size.closeButtonOffsetPortrait
                        : Const.Size.closeButtonOffset)
                .zIndex(1)

            VStack {
                Spacer()
                    .frame(height: Const.Size.topPadding)
                AutofillViews.Headline(title: UserText.emailAliasPromptTitle)
                Spacer()
                    .frame(height: Const.Size.headlineTopPadding)

                VStack {
                    if let userEmail = viewModel.userEmail {
                        EmailAddressRow(title: userEmail,
                                        subtitle: UserText.emailAliasPromptUseUserAddressSubtitle) {
                            viewModel.selectUserEmailPressed()
                        }
                    }
                    EmailAddressRow(title: UserText.emailAliasPromptGeneratePrivateAddress,
                                    subtitle: UserText.emailAliasPromptGeneratePrivateAddressSubtitle) {
                        viewModel.selectGeneratedEmailPressed()
                    }
                }
                .frame(minWidth: 288.0)
                .frame(maxWidth: AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) ? 288.0 : .infinity)
                .padding(.horizontal, AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) ? 0.0 : 72.0)
                .padding(.bottom, 36.0)
            }
            .background(GeometryReader { proxy -> Color in
                DispatchQueue.main.async { viewModel.contentHeight = proxy.size.height }
                return Color.clear
            })
            .useScrollView(shouldUseScrollView(), minHeight: frame.height)

        }
        .padding(.horizontal, AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) ? Const.Size.closeButtonOffsetPortrait
                 : Const.Size.closeButtonOffset)
    }

    private func shouldUseScrollView() -> Bool {
        var useScrollView: Bool = false

        if #available(iOS 16.0, *) {
            useScrollView = AutofillViews.contentHeightExceedsScreenHeight(viewModel.contentHeight)
        } else {
            useScrollView = viewModel.contentHeight > frame.height + Const.Size.ios15scrollOffset
        }

        return useScrollView
    }
}

private struct EmailAddressRow: View {

    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                Image.logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: Const.Size.logoImage, height: Const.Size.logoImage)
                    .padding(.horizontal, 16.0)
                VStack(alignment: .leading, spacing: 3.0) {
                    Text(title)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .daxFootnoteRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 11.0)
                Spacer()
            }

        }

        .background(Color(designSystemColor: .container))
        .cornerRadius(8.0)
    }

}

// MARK: - Constants

private enum Const {

    enum Size {
        static let closeButtonOffset: CGFloat = 48.0
        static let closeButtonOffsetPortrait: CGFloat = 44.0
        static let topPadding: CGFloat = 56.0
        static let headlineTopPadding: CGFloat = 24.0
        static let ios15scrollOffset: CGFloat = 80.0
        static let contentSpacerHeight: CGFloat = 24.0
        static let contentSpacerHeightLandscape: CGFloat = 30.0
        static let ctaVerticalSpacing: CGFloat = 8.0
        static let bottomPadding: CGFloat = 12.0
        static let bottomPaddingIPad: CGFloat = 24.0
        static let logoImage: CGFloat = 24.0
    }
}

private extension Image {
    static let logo = Image("Logo")
}

struct DuckAddressPromptView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = EmailAddressPromptViewModel(userEmail: "dax@duck.com")
        EmailAddressPromptView(viewModel: viewModel)
    }
}
