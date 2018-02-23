//
//  FormFactory.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/10/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//



class FormFactory {
    static func cell(for viewModel:FormFieldVM) -> FormCell {
        switch viewModel.type {
            case .text(_): return TextFieldFormCell(viewModel as! VariableFieldVM<String>)
            case .time: return TimeKeyboardFormCell(viewModel as! VariableFieldVM<Time?>)
            case .date(_): return DatePickerFormCell(viewModel as! VariableFieldVM<Date?>)
            case .switcher: return BoolFormCell(viewModel as! VariableFieldVM<Bool>)
            case .container: return CountContainerCell(viewModel as! FieldsContainerVM)
            case .action(let type):
                let cell = FormCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.text = viewModel.key
                cell.textLabel?.textColor = type == ActionType.destructive ? .red : .sdTangerine
                return cell

            case .profileInfo:
                let cell = SettingAvatarCell()
                let profileVM = viewModel as! SettingInfo
                cell.nameLabel.text = profileVM.key
                cell.avatarView.avatarURL = profileVM.imageURL
                cell.selectionStyle = .none
                return cell

            case .picker: return PickerFormCell(viewModel as! PickerFieldVM)
            case .count: break;
        }
        fatalError()
    }
}
