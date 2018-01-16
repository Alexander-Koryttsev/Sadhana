//
//  SettingsVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import AlamofireImage
import Crashlytics

class SettingsVC : BaseTableVC <SettingsVM> {

    init(_ viewModel:VM) {
        super.init(viewModel, style: .grouped)
    }

    override func bindViewModel() {
        super.bindViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available (iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Answers.logContentView(withName: "Settings", contentType: nil, contentId: nil, customAttributes: nil)
    }

    func field(at indexPath: IndexPath) -> FormFieldVM {
        return viewModel.sections[indexPath.section].items[indexPath.row]
    }

    // MARK: - Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = self.field(at: indexPath)

        return FormFactory.cell(for: field) //TODO: implement reuse
    }

    // MARK: - Table Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let field = self.field(at: indexPath)
        if let action = field as? FormAction {
            action.action()
            if !action.presenter {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = self.field(at: indexPath)
        if field is SettingInfo {
            return 80
        }
        return 44;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var title:String? {
        get { return "settings".localized }
        set {}
    }
}
