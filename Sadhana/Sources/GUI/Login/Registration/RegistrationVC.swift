//
//  RegistrationVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/4/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa

import EasyPeasy

class RegistrationVC: BaseTableVC<RegistrationVM> {
    enum Section : Int {
        case fields = 0
        case registerButton
        case count
    }

    var cells = [FormCell]()
    let registerCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let footer = UITableViewHeaderFooterView()
    let blocker = UIView()
    var message : String? {
        set {
            footer.textLabel!.text = newValue
            tableView.beginUpdates()
            tableView.endUpdates()
            let deadlineTime = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.tableView.scrollRectToVisible(self.tableView.rectForFooter(inSection: 1), animated: true)
            }
        }
        get {
            return footer.textLabel!.text;
        }
    }

    override var title: String? {
        get {
            return "registration".localized
        }
        set {}
    }

    init(_ viewModel: VM) {
        super.init(viewModel, style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive
        setUpRegisterCell()
        footer.textLabel!.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if base.firstAppearing {
            DispatchQueue.main.async {
               self.cells.first!.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if base.firstAppearing {
            blocker.isHidden = true
            blocker.backgroundColor = UIColor(white: 0, alpha: 0.1)
            tableView.window!.addSubview(blocker)
            blocker.easy.layout(Edges())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.endEditing(true)
    }
    
    func setUpRegisterCell() {
        registerCell.textLabel?.textAlignment = .center
        registerCell.textLabel?.text = "register".localized
        
        activityIndicator.hidesWhenStopped = true
        registerCell.contentView.addSubview(activityIndicator)
        activityIndicator.easy.layout(Center())
    }

    override func bindViewModel() {
        super.bindViewModel()

        var passwordCells = [TextFieldFormCell]()
        for field in viewModel.fields {
            let cell = FormFactory.cell(for: field)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            cells.append(cell)
            if case FormFieldType.text(.password) = field.type {
                passwordCells.append(cell as! TextFieldFormCell)
            }
        }

        Driver.combineLatest(passwordCells.first!.textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ()),
                             passwordCells.last!.textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ()),
                             viewModel.passwordValid) { (_,_, valid) -> Void in
                                passwordCells.forEach({ (cell) in
                                    cell.set(valid: valid)
                                })
        }.drive().disposed(by: disposeBag)

        FormHelper.bind(cells: cells, disposeBag: viewModel.disposeBag)

        if let last = cells.last as? Responsible {
            last.goNext.bind(to: viewModel.register).disposed(by: disposeBag)
        }

        viewModel.canRegister.drive(onNext: { [unowned self] (can) in
            self.registerCell.textLabel?.textColor = can ? .sdTangerine : .sdSilver
            self.registerCell.selectionStyle = can ? .gray : .none
        }).disposed(by: disposeBag)

        viewModel.activityIndicator.asDriver()
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.activityIndicator.asDriver()
            .drive(registerCell.textLabel!.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.activityIndicator.asDriver()
            .map { (running) in return !running }
            .drive(blocker.rx.isHidden)
            .disposed(by: disposeBag)


        Driver.merge(viewModel.errorMessages, viewModel.messagesUI).drive(onNext:{ [unowned self] message in
            self.message = message
        }).disposed(by: disposeBag)

        viewModel.register.asDriver(onErrorJustReturn: ()).drive(onNext: { [unowned self] in
            self.message = nil
            self.tableView.endEditing(true)
        }).disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.fields.rawValue: return cells.count
            case Section.registerButton.rawValue: return 1
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue:indexPath.section)! {
            case .fields:  return cells[indexPath.row]
            case .registerButton: return registerCell
            case .count: break
        }
        fatalError()
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return message
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return footer
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        footer.textLabel!.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var shouldDeselectNow = true
        switch Section(rawValue:indexPath.section)! {
            case .fields:
                let field = viewModel.fields[indexPath.row]
                if let pickerField = field as? PickerFieldVM,
                    let action = pickerField.action {
                    shouldDeselectNow = !action()
                }
                break
            case .registerButton:
                viewModel.register.onNext(())
                break
            case .count: break
        }

        if shouldDeselectNow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
