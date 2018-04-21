//
//  EntryEditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import CoreData

class EntryEditingVM: BaseTableVM {

    let date : LocalDate
    let enabled : Bool
    private var fieldsInternal = [FormFieldVM]()
    var fields : [FormFieldVM] {
        return fieldsInternal
    }
    private let entry : ManagedEntry
    private lazy var yesterdayEntry = {
        return self.entry.managedObjectContext!.fetchOrCreateEntry(for: self.date.yesterday, userID: Local.defaults.userID!)
    }()

    override var numberOfSections: Int {
        return 1
    }

    override func numberOfRows(in section: Int) -> Int {
        return fields.count
    }

    init(date: LocalDate, context: NSManagedObjectContext, enabled: Bool) {
        self.date = date
        self.enabled = enabled
        entry = context.fetchOrCreateEntry(for: self.date, userID:Local.defaults.userID!)
        super.init()

        if enabled {
            let user = Main.service.currentUser!
            if user.bedTimeEnabled,
               Local.defaults.showBedTimeForYesterday {
                let field = DataFormFieldVM<Time?>(title: "bedTimeYesterday".localized,
                                                       type: .time,
                                                       variable: KeyPathVariable(yesterdayEntry, \ManagedEntry.bedTime))
                fieldsInternal.append(field)
            }

            if user.wakeUpTimeEnabled {
                let field = DataFormFieldVM<Time?>(title: EntryFieldKey.wakeUpTime.rawValue.localized,
                                                       type: .time,
                                                       variable: KeyPathVariable(entry, \ManagedEntry.wakeUpTime))
                fieldsInternal.append(field)
            }

            let japaFields = [
                DataFormFieldVM<Int16>(title: EntryFieldKey.japa7_30.rawValue.localized,
                                        type: .count(digitsLimit:2),
                                           variable: KeyPathVariable(entry, \ManagedEntry.japaCount7_30)),
                DataFormFieldVM<Int16>(title: EntryFieldKey.japa10.rawValue.localized,
                                           type: .count(digitsLimit:2),
                                           variable: KeyPathVariable(entry, \ManagedEntry.japaCount10)),
                DataFormFieldVM<Int16>(title: EntryFieldKey.japa18.rawValue.localized,
                                           type: .count(digitsLimit:2),
                                           variable: KeyPathVariable(entry, \ManagedEntry.japaCount18)),
                DataFormFieldVM<Int16>(title: EntryFieldKey.japa24.rawValue.localized,
                                           type: .count(digitsLimit:2),
                                           variable: KeyPathVariable(entry, \ManagedEntry.japaCount24)),
            ]
            let japaContainer = FieldsContainerVM(EntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
            fieldsInternal.append(japaContainer)

            if Local.defaults.readingOnlyInMinutes {
                let reading = DataFormFieldVM<Int16>(title: "minutes".localized,
                                                     type: .count(digitsLimit:4),
                                                         variable: KeyPathVariable(entry, \ManagedEntry.readingInMinutes))
                let readingContainer = FieldsContainerVM(EntryFieldKey.reading.rawValue.localized, [reading], colors: [.black])

                fieldsInternal.append(readingContainer)
            }
            else {
                let reading = DataFormFieldVM<Time?>(title: EntryFieldKey.reading.rawValue.localized,
                                                         type: .time,
                                                         variable: KeyPathVariable(entry, \ManagedEntry.readingTimeOptional))
                fieldsInternal.append(reading)
            }

            fieldsInternal.append(
                DataFormFieldVM<Bool>(title: EntryFieldKey.kirtan.rawValue.localized,
                                           type: .switcher,
                                           variable: KeyPathVariable(entry, \ManagedEntry.kirtan))
            )

            if user.serviceEnabled {
                fieldsInternal.append(
                    DataFormFieldVM<Bool>(title: EntryFieldKey.service.rawValue.localized,
                                              type: .switcher,
                                              variable: KeyPathVariable(entry, \ManagedEntry.service))
                )
            }
            if user.exerciseEnabled {
                fieldsInternal.append(
                    DataFormFieldVM<Bool>(title: EntryFieldKey.yoga.rawValue.localized,
                                              type: .switcher,
                                              variable: KeyPathVariable(entry, \ManagedEntry.yoga))
                )
            }
            if user.lectionsEnabled {
                fieldsInternal.append(
                    DataFormFieldVM<Bool>(title: EntryFieldKey.lections.rawValue.localized,
                                              type: .switcher,
                                              variable: KeyPathVariable(entry, \ManagedEntry.lections))
                )
            }
            if user.bedTimeEnabled,
                !Local.defaults.showBedTimeForYesterday {
                fieldsInternal.append(
                    DataFormFieldVM<Time?>(title: EntryFieldKey.bedTime.rawValue.localized,
                                              type: .time,
                                              variable: KeyPathVariable(entry, \ManagedEntry.bedTime))
                )
            }
        }
    }
}

enum FormFieldType {
    case text(TextFieldType)
    case count(digitsLimit:Int)
    case time
    case date(min:Date?, default:Date?, max:Date?)
    case switcher
    case container
    case action(ActionType)
    case profileInfo
    case picker
}

enum TextFieldType {
    case basic
    case name(NameType)
    case email
    case password
}

enum NameType {
    case first
    case last
    case spiritual
}

enum ActionType {
    case basic
    case destructive
    case detail
}

protocol FormFieldVM {
    var title : String { get }
    var type : FormFieldType { get }
    var action : (() -> Bool)? { get }
}

extension FormFieldVM {
    var isValid : Bool {
        return true
    }
}

struct DataFormFieldVM<T> : FormFieldVM {
    let title : String
    let type : FormFieldType
    var variable : Variable<T>
    var action : (() -> Bool)?
    var valid : Driver<Bool>?
    var beginValidation : Driver<Void>?
    var isValid = true
    var enabled = true

    init(title: String,
         type: FormFieldType,
         variable: Variable<T>,
         action: (() -> Bool)? = nil,
         valid : Driver<Bool>? = nil,
         validSelector: ((T) -> Bool)? = nil,
         beginValidation: Driver<Void>? = nil,
         enabled : Bool? = true) {

        self.title = title
        self.type = type
        self.variable = variable
        self.action = action
        self.valid = valid
        if valid == nil,
            let selector = validSelector {
            self.valid = variable.map(selector).asDriver(onErrorJustReturn: false).distinctUntilChanged()
        }
        self.beginValidation = beginValidation
        
        if let enabled = enabled {
            self.enabled = enabled
        }
    }
}

protocol Fillable {
    var isFilled : Bool { get }
}

class FieldsContainerVM : FormFieldVM, Fillable {
    let title: String
    let fields: [FormFieldVM]
    let colors: [UIColor]?
    let type = FormFieldType.container
    let action : (() -> Bool)? = nil
    var isFilled: Bool {
        var filled = true
        for item in fields {
            if let item = item as? Fillable {
                filled = item.isFilled && filled
            }
        }
        return filled
    }
    init(_ key: String, _ fields: [FormFieldVM], colors: [UIColor]? = nil) {
        self.title = key
        self.fields = fields
        self.colors = colors
    }
}

