//
//  AutofillLoginListTableViewController.swift
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

import UIKit

@available(iOS 14.0, *)
class AutofillLoginListTableViewController: UITableViewController {
    private let viewModel = AutofillLoginListViewModel()
    
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = "Autofill Logins"
        tableView.rowHeight = 60
        tableView.registerCell(ofType: AutofillListItemTableViewCell.self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let item = viewModel.sections[indexPath.section].items[indexPath.row]
            let detailsController = AutofillLoginDetailsViewController(account: item.account)
            detailsController.delegate = self
            navigationController?.pushViewController(detailsController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillListItemTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel.sections[indexPath.section].items[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }
}

#warning("move to its own file")
extension UITableView {
    func dequeueCell<CellType: UITableViewCell>(ofType: CellType.Type, for indexPath: IndexPath) -> CellType {
        
        let reuseIdentifier = "\(CellType.self)"
        let someCell = self.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = someCell as? CellType else {
            fatalError("Could not dequeue cell of type \(CellType.self)")
        }
        return cell
    }
    
    func registerCell<CellType: UITableViewCell>(ofType: CellType.Type) {
        let reuseIdentifier = "\(CellType.self)"
        self.register(CellType.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

@available(iOS 14.0, *)
extension AutofillLoginListTableViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController) {
        viewModel.update()
        tableView.reloadData()
    }
}
