//
//  RegistrationVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/4/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//




import EasyPeasy

class RegistrationVC: BaseTableVC<RegistrationVM> {

    class Footer : UIView {
        let label = UILabel()

        init() {
            label.textAlignment = .center
            label.textColor = .sdSteel
            label.font = .systemFont(ofSize: 12)
            label.numberOfLines = 2
            super.init(frame:CGRect())
            addSubview(label)
            label.easy.layout([Left(<=15), Right(<=15), Top(8), Bottom(<=10), CenterX()])
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    struct Section  {
        let cells : [UITableViewCell]
        let footer : Footer?
    }

    var sections = [Section]()
    let registerCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let footer = Footer()
    let blocker = UIView()
    var message : String? {
        set {
            footer.label.text = newValue
        }
        get {
            return footer.label.text;
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
        base.defaultErrorMessagingEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive
        setUpRegisterCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if base.firstAppearing {
            DispatchQueue.main.async {
               self.sections.first!.cells.first!.becomeFirstResponder()
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

        //Cells setup
        var passwordSection : RegistrationVC.Section?

        var allCells = [FormCell]()
        for section in viewModel.sections {
            var sectionCells = [FormCell]()
            for field in section.fields {
                let cell = FormFactory.cell(for: field)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                sectionCells.append(cell)
                allCells.append(cell)
                
            }

            let uiFooter : Footer?
            if let footerDriver = section.footer {
                let uiFooterLocal = Footer()
                footerDriver.drive(uiFooterLocal.label.rx.text).disposed(by: disposeBag)
                uiFooter = uiFooterLocal
            }
            else {
                uiFooter = nil
            }
            
            let uiSection = Section(cells:sectionCells, footer:uiFooter)
            if case FormFieldType.text(.password) = section.fields.first!.type {
                passwordSection = uiSection
            }

            sections.append(uiSection)
        }
        
        sections.append(Section(cells: [ registerCell ], footer:footer))
        
        let passwordCells = passwordSection!.cells as! [TextFieldFormCell]
        
        let didEndEditingPassword = Driver.combineLatest (
            passwordCells.first!.textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ()),
            passwordCells.last!.textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ())) {
                                                    _,_  in return
        }

        let beginValidationPassword = Driver.merge(didEndEditingPassword, viewModel.register.asDriver(onErrorJustReturn: ()))
        
        Driver.combineLatest(beginValidationPassword, viewModel.passwordValid) { _, valid in
            passwordCells.forEach({ (cell) in
                cell.set(valid: valid)
            })
            passwordSection!.footer?.label.textColor = .red
        }.drive().disposed(by: disposeBag)

        FormHelper.bind(cells: allCells, disposeBag: viewModel.disposeBag)

        if let last = allCells.last as? Responsible {
            last.goNext.bind(to: viewModel.register).disposed(by: disposeBag)
        }
        
        //Registration Actions
        viewModel.canRegister.drive(onNext: { [unowned self] (can) in
            self.registerCell.textLabel?.textColor = can ? .sdTangerine : .sdSilver
            self.registerCell.selectionStyle = can ? .gray : .none
        }).disposed(by: disposeBag)

        viewModel.register.asDriver(onErrorJustReturn: ()).drive(onNext: { [unowned self] in
            self.message = nil
            self.tableView.endEditing(true)
        }).disposed(by: disposeBag)

        //Activity Indicator
        viewModel.activityIndicator.asDriver()
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.activityIndicator.asDriver()
            .drive(registerCell.textLabel!.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.activityIndicator.asDriver().debounce(0.25)
            .drive(onNext:{ [unowned self] running in
                UIView.transition(with: self.blocker, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.blocker.isHidden = !running
                }, completion: nil)
            })
            .disposed(by: disposeBag)

        //Error handling
        Driver.merge(viewModel.errorMessages, viewModel.messagesUI).do(onNext:{ _ in
            let deadlineTime = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.tableView.scrollRectToVisible(self.tableView.rectForFooter(inSection: 1), animated: true)
            }
        }).drive(footer.label.rx.text).disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footer != nil ? 34 : 10
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var shouldDeselectNow = true

        if indexPath.section == sections.count - 1 {
            viewModel.register.onNext(())
        }
        else {
            let field = viewModel.sections[indexPath.section].fields[indexPath.row]
            if let action = field.action {
                shouldDeselectNow = !action()
            }
        }

        if shouldDeselectNow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
