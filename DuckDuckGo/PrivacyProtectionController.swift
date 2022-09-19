//
//  PrivacyProtectionController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import BrowserServicesKit
import WebKit
import PrivacyDashboard

protocol PrivacyProtectionDelegate: AnyObject {

    func omniBarTextTapped()

    func reload(scripts: Bool)

    func getCurrentWebsiteInfo() -> BrokenSiteInfo
}

class PrivacyProtectionController: ThemableNavigationController {

    weak var privacyProtectionDelegate: PrivacyProtectionDelegate?

    weak var omniDelegate: OmniBarDelegate!
    weak var siteRating: SiteRating?
    weak var privacyInfo: PrivacyInfo?
    
    weak var privacyDashboard: NewPrivacyDashboardViewController?
    
    var omniBarText: String?
    var errorText: String?
  
    private var storageCache = AppDependencyProvider.shared.storageCache.current
    private var privacyConfig = ContentBlocking.privacyConfigurationManager.privacyConfig

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        navigationBar.isHidden = AppWidthObserver.shared.isLargeWidth
        
        popoverPresentationController?.backgroundColor = UIColor.nearlyWhite

        if let errorText = errorText {
            showError(withText: errorText)
        } else if siteRating == nil {
            showError(withText: UserText.unknownErrorOccurred)
        } else {
            showInitialScreen()
        }

    }

    private func showError(withText errorText: String) {
//        guard let controller = storyboard?.instantiateViewController(identifier: "Error", creator: { coder in
//            PrivacyProtectionErrorController(coder: coder, configuration: self.privacyConfig)
//        }) else { return }
//        controller.errorText = errorText
//        pushViewController(controller, animated: true)
    }

    private func showInitialScreen() {
        let controller = NewPrivacyDashboardViewController(privacyInfo: privacyInfo)
        
        privacyDashboard = controller
         
        pushViewController(controller, animated: true)
        updateViewControllers()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.isEmpty {
            viewController.title = siteRating?.domain
        } else {
            topViewController?.title = " "
        }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        viewController.navigationItem.rightBarButtonItem = doneButton
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let controller = super.popViewController(animated: animated)
        if viewControllers.count == 1 {
            viewControllers[0].title = siteRating?.domain
        }
        return controller
    }

    func updateSiteRating(_ siteRating: SiteRating?) {
        self.siteRating = siteRating
        updateViewControllers()
    }
    
    func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        self.privacyInfo = privacyInfo
        privacyDashboard?.updatePrivacyInfo(privacyInfo)
    }

    func updateViewControllers() {
        guard let siteRating = siteRating else { return }

        viewControllers.forEach {
            guard let infoDisplaying = $0 as? PrivacyProtectionInfoDisplaying else { return }
            infoDisplaying.using(siteRating: siteRating, config: privacyConfig)
        }
    }

    @objc func done() {
        dismiss(animated: true)
    }

}

extension PrivacyProtectionController: UIPopoverPresentationControllerDelegate { }
