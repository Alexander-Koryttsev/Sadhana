//
//  DatePickerCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/11/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//



import EasyPeasy


class DatePickerFormCell: ResponsibleFormCell, UITextFieldDelegate, Validable {
    let viewModel : DataFormFieldVM<Date?>

    let textField = UITextField()
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: Screen.bounds.width, height: 44))

    let datePicker = UIDatePicker()
    var active : Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.active ? .sdPaleGrey : .white
            }
            if active && !textField.isFirstResponder {
                _ = textField.becomeFirstResponder()
            }
        }
    }

    init(_ viewModel: DataFormFieldVM<Date?>) {
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: nil)

        textLabel?.text = viewModel.title.localized
        textLabel!.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)

        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "login-arrow").upMirrored, style: .plain, target: nil, action: nil)
        backItem.rx.tap.bind(to: goBack).disposed(by: disposeBag)

        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let nextItem = UIBarButtonItem(image: #imageLiteral(resourceName: "login-arrow"), style: .plain, target: nil, action: nil)
        nextItem.rx.tap.bind(to: goNext).disposed(by: disposeBag)

        toolbar.items = [ backItem, spaceItem, nextItem ]
        toolbar.tintColor = .sdTangerine

        viewModel.variable.map { (date) in
            return date?.dateShort ?? ""
            }.bind(to:textField.rx.text).disposed(by: disposeBag)

        textField.textAlignment = .right
        textField.tintColor = .clear
        textField.textColor = .sdSteel
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        textField.isEnabled = viewModel.enabled
        contentView.addSubview(textField)
        textField.easy.layout([
            Top(),
            Height(height).with(.medium),
            Bottom(),
            Width(*0.6).like(contentView),
            Right(16)
        ])

        datePicker.timeZone = TimeZone.zero()
        datePicker.datePickerMode = .date
        switch viewModel.type {
            case .date(let min, let defaultDate, let max):
                datePicker.minimumDate = min
                if let defaultDate = defaultDate {
                    datePicker.date = defaultDate
                }
                datePicker.maximumDate = max
                break
            default: break
        }

        if let date = viewModel.variable.value {
            datePicker.date = date
        }
        datePicker.rx.date.skip(1).bind(to: viewModel.variable).disposed(by: disposeBag)

        accessoryView = UIView()

        becomeActive.debounce(1, scheduler: MainScheduler.instance).subscribe(onNext:activate).disposed(by: disposeBag)

        let didEndEditing = textField.rx.controlEvent(.editingDidEnd)
        didEndEditing.asDriver().drive(onNext:deactivate).disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidBegin).asDriver().drive(onNext:activate).disposed(by: disposeBag)
        
        if let validDriver = viewModel.valid {
            var beginValidation = textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ())
            if let viewModelBeginValidation = viewModel.beginValidation {
                beginValidation = Driver.merge(beginValidation, viewModelBeginValidation)
            }
            
            Driver.combineLatest(beginValidation, validDriver, resultSelector: { [unowned self] (_, valid) -> Void in
                self.set(valid:valid)
            }).drive().disposed(by: disposeBag)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            activate()
        }
    }

    func deactivate() {
        active = false
    }

    func activate() {
        active = true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}


