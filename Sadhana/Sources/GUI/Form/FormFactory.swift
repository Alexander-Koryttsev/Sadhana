//
//  FormFactory.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/10/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//


class FormFactory {
    static func cell(for viewModel:FormFieldVM) -> FormCell {
        if let boolModel = viewModel as? DataFormFieldVM<Bool> {
            return BoolFormCell(boolModel)
        }

        if let textModel = viewModel as? DataFormFieldVM<String> {
            return TextFieldFormCell(textModel)
        }

        switch viewModel.type {
            case .time: return TimeKeyboardFormCell(viewModel as! DataFormFieldVM<Time?>)
            case .date(_): return DatePickerFormCell(viewModel as! DataFormFieldVM<Date?>)
            case .container: return CountContainerCell(viewModel as! FieldsContainerVM)
            case .action(let type):
                let cell = FormCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = viewModel.title
                cell.textLabel?.textAlignment = .center
                switch type {
                    case .basic:
                        cell.textLabel?.textColor = .sdTangerine
                        break
                    case .destructive:
                        cell.textLabel?.textColor = .red
                        cell.textLabel?.textAlignment = type == .detail ? .left : .center
                        break
                    case .detail:
                        cell.textLabel?.textColor = .black
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textAlignment = .left
                        break
                }
                return cell

            case .profileInfo:
                return SettingAvatarCell(viewModel as! SettingInfo)

            case .picker: return PickerFormCell(viewModel as! DataFormFieldVM<Titled?>)
            case .count(_): break;
            default: break;
        }
        fatalError("can't find cell for \(viewModel)")
    }
}
