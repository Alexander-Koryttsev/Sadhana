//
//  BaseSettingsVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/28/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import EasyPeasy

class BaseSettingsVC : BaseTableVC <BaseSettingsVM> {
    
    var sections = [[FormCell]]()

    init(_ viewModel:VM) {
        super.init(viewModel, style: .grouped)
    }

    override func bindViewModel() {
        super.bindViewModel()
        viewModel.updates.subscribe(onNext: { [unowned self] (_) in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }).disposed(by: disposeBag)
        
        viewModel.sections.forEach { (section) in
            var cells = [FormCell]()
            section.items.forEach({ (fieldVM) in
                let cell = FormFactory.cell(for: fieldVM)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                cells.append(cell)
            })
            sections.append(cells)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .interactive
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    override func reloadData() {
        sections.forEach { (section) in
            section.forEach({ (cell) in
                cell.reloadData()
            })
        }
    }

    func field(at indexPath: IndexPath) -> FormFieldVM {
        return viewModel.sections[indexPath.section].items[indexPath.row]
    }

    // MARK: - Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = viewModel.sections[section]

        var height = CGFloat(0)
        if section.shown {
            height += 30

            if section.headerTitle.count > 0 {
                height += 14
            }
        }

        return height
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        let section = viewModel.sections[sectionIndex]
        var title : String

        if section.shown,
            section.headerTitle.count > 0 {
            title = section.headerTitle
        }
        else {
            title = " "
        }
        
        return title
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.tableView(tableView, titleForHeaderInSection: section)!
        if (title.trimmingCharacters(in: .whitespaces).count > 0) {
            return Header(title)
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = viewModel.sections[section]

        var height = CGFloat(0)
        if section.shown {
            if section.footerTitle.count > 0 {
                height += Footer.height(for: section.footerTitle)
            }
        }

        return height
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection sectionIndex: Int) -> String? {
        let section = viewModel.sections[sectionIndex]
        var title : String

        if section.shown,
            section.footerTitle.count > 0 {
            title = section.footerTitle
        }
        else {
            title = " "
        }

        return title
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let title = self.tableView(tableView, titleForFooterInSection: section)!
        if (title.trimmingCharacters(in: .whitespaces).count > 0) {
            return Footer(title)
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = viewModel.sections[indexPath.section]
        if !section.shown {
            return 0
        }
        let field = self.field(at:indexPath)
        if field is SettingInfo {
            return 80
        }
        return 44;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section][indexPath.row]
    }

    // MARK: - Table Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let field = self.field(at: indexPath)
        if let action = field.action {
            if action() {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var title:String? {
        get { return viewModel.title }
        set {}
    }

    class Header : UIView {
        let label = UILabel()

        init (_ title: String) {
            super.init(frame: CGRect())
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = .sdSteel
            label.text = title.uppercased()
            addSubview(label)
            label.easy.layout([
                Bottom(8),
                Left(16),
                Right(16)
                ])
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class Footer : UIView {
        let label = UILabel()

        init (_ title: String) {
            super.init(frame: CGRect())
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = .sdSteel
            label.text = title
            label.numberOfLines = 0
            addSubview(label)
            label.easy.layout( Top(8),
                Bottom(8),
                Left(16),
                Right(16)
                )
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        static func height(for title: String) -> CGFloat {
            return title.height(withConstrainedWidth: ScreenWidth - 32, font: .systemFont(ofSize: 13)) + 16
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
