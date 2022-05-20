//
//  AutofillLoginListViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Foundation
import BrowserServicesKit
import UIKit
import Combine

enum AutofillLoginListSectionType {
    case enableAutofill
    case credentials(title: String, items: [AutofillLoginListItemViewModel])
}

struct AutofillLoginListSection: Identifiable {
    enum SectionType {
        case credentials
        case enableAutofill
    }
    
    let id = UUID()
    let title: String
    var items: [AutofillLoginListItemViewModel]
}

final class AutofillLoginListViewModel: ObservableObject {
    enum ViewState {
        case authLocked
        case empty
        case showItems
    }
    
    private(set) var sections = [AutofillLoginListSectionType]()
    private(set) var indexes = [String]()
    private var cancellables: Set<AnyCancellable> = []

    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    
    private let authenticator = AutofillLoginListAuthenticator()
    
    var isAutofillEnabled: Bool {
        get {
            appSettings.autofill
        }
        
        set {
            appSettings.autofill = newValue
        }
    }
    private var appSettings: AppSettings
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        
        updateData()
        setupCancellables()
    }
    
 
    func delete(at indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case .credentials(_, let items):
            let item = items[indexPath.row]
            delete(item.account)
            update()
        default:
            break
        }
    }
    
    func lockUI() {
        authenticator.logOut()
    }
    
    func authenticate() {
        if viewState != .authLocked {
            return
        }
        
        authenticator.authenticate { error in
            if let error = error {
                print("ERROR \(error)")
            }
        }
    }
    
    private func setupCancellables() {
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }
    
    private func updateViewState() {
        if authenticator.state == .loggedOut {
            self.viewState = .authLocked
        } else {
            self.viewState = self.sections.count > 1 ? .showItems : .empty
        }
    }
    
    func rowsInSection(_ section: Int) -> Int {
        switch self.sections[section] {
        case .enableAutofill:
            return 1
        case .credentials(_, let items):
            return items.count
        }
    }
    
    private func delete(_ account: SecureVaultModels.WebsiteAccount) {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared),
              let accountID = account.id else { return }
        
        do {
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountID)
        } catch {
#warning("Pixel?")
        }
    }
    
    func updateData() {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else { return }
        
        sections.removeAll()
        indexes.removeAll()
        
        sections.append(.enableAutofill)
        
#warning("REFACTOR THIS")
        if let accounts = try? secureVault.accounts() {
            var sections = [String: [AutofillLoginListItemViewModel]]()
            
            for account in accounts {
                print("ACCOUNT \(account.name) \(account.domain)")
                
                if let first = account.name.first?.lowercased() {
                    if sections[first] != nil {
                        sections[first]?.append(AutofillLoginListItemViewModel(account: account))
                    } else {
                        let newSection = [AutofillLoginListItemViewModel(account: account)]
                        sections[first] = newSection
                    }
                }
            }
            
            for (key, var value) in sections {
                value.sort { leftItem, rightItem in
                    leftItem.title.lowercased() < rightItem.title.lowercased()
                }
                
                self.sections.append(.credentials(title: key, items: value))
                indexes.append(key.uppercased())
            }
            
            self.sections.sort(by: { leftSection, rightSection in
                if case .credentials(let left, _) = leftSection,
                   case .credentials(let right, _) = rightSection {
                    return left < right
                }
                return false
            })
            
            self.indexes.sort(by: { lhs, rhs in
                lhs < rhs
            })
            
            updateViewState()
        }
    }
}
