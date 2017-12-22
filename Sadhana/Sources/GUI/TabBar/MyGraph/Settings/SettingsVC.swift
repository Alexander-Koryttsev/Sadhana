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

        if let info = field as? SettingInfo {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingAvatarCell.reuseID) as? SettingAvatarCell ?? SettingAvatarCell()
            cell.nameLabel.text = info.key
            cell.avatarView.avatarURL = info.imageURL
            cell.selectionStyle = .none
            return cell
        }

        if let action = field as? SettingAction {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Action") ?? UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Action")
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = action.key
            cell.textLabel?.textColor = action.destructive ? .red : .sdTangerine
            return cell
        }

        if let boolField = field as? VariableFieldVM<Bool> {
            let cell = BoolFormCell(boolField)
            return cell
        }

        fatalError("unknown setting field \(field)")
    }

    // MARK: - Table Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let field = self.field(at: indexPath)
        if let action = field as? SettingAction {
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
