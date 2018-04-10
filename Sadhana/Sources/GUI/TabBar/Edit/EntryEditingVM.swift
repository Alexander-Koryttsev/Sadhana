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

    override var numberOfSections: Int {
        return 1
    }

    override func numberOfRows(in section: Int) -> Int {
        return fields.count
    }

    init(date: LocalDate, context: NSManagedObjectContext, enabled: Bool) {
        self.date = date
        self.enabled = enabled

        if let localEntry = context.fetchEntry(for: date, userID:Local.defaults.userID!) {
            entry = localEntry
        }
        else {
            entry = context.create(ManagedEntry.self)
            entry.userID = Local.defaults.userID!
            entry.date = date.date
            entry.month = date.trimDay.date
            entry.dateCreated = Date()
            entry.dateUpdated = entry.dateCreated
        }

        super.init()

        if enabled {
            add(timeField: .wakeUpTime, optional: true)

        let japaFields = [
            self.field(for: .japa7_30, type:Int16.self, fieldType:.count),
            self.field(for: .japa10, type:Int16.self, fieldType:.count),
            self.field(for: .japa18, type:Int16.self, fieldType:.count),
            self.field(for: .japa24, type:Int16.self, fieldType:.count),
        ]
        let japaContainer = FieldsContainerVM(EntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
        fieldsInternal.append(japaContainer)

        add(timeField: .reading, optional: false)
        add(field: .kirtan, type:Bool.self, fieldType:.switcher)
        add(field: .service, type:Bool.self, fieldType:.switcher)
        add(field: .yoga, type:Bool.self, fieldType:.switcher)
        add(field: .lections, type:Bool.self, fieldType:.switcher)

            if !self.date.isToday {
                add(timeField: .bedTime, optional: true)
            }
        }
    }

    private func add<T>(field: EntryFieldKey, type:T.Type, fieldType:FormFieldType) {
        //if Local.defaults.isFieldEnabled(field) {
            fieldsInternal.append(self.field(for:field, type: T.self, fieldType:fieldType))
        //}
    }

    private func add(timeField: EntryFieldKey, optional:Bool) {
       // if Local.defaults.isFieldEnabled(timeField) {

            let variable = Variable(entry.timeOptionalValue(forKey: timeField))
            variable.asDriver().skip(2).drive(onNext: { [unowned entry] (next) in
                if entry.managedObjectContext == nil { return }
                entry.set(time: next ?? (optional ? nil : Time(rawValue: "0")), forKey: timeField)
                entry.dateUpdated = Date()
            }).disposed(by: disposeBag)

        fieldsInternal.append(VariableFieldVM<Time?>(variable, for: timeField.rawValue, type:.time))
       // }
    }

    private func field<T>(for key: EntryFieldKey, type:T.Type, fieldType: FormFieldType) -> VariableFieldVM<T> {
        let variable = Variable(entry.value(forKey: key.rawValue) as! T)
        variable.asDriver().skip(1).drive(onNext: { [unowned entry] (next) in
            entry.setValue(next is NSNull ? nil : next, forKey: key.rawValue)
            entry.dateUpdated = Date()
        }).disposed(by: disposeBag)

        return VariableFieldVM<T>(variable, for: key.rawValue, type: fieldType)
    }
}

enum FormFieldType {
    case text(TextFieldType)
    case count
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
}

protocol FormFieldVM {
    var key : String { get }
    var type : FormFieldType { get }
}

protocol Fillable {
    var isFilled : Bool { get }
}

//TODO: remove this class:)
class VariableFieldVM<T> : FormFieldVM, Fillable {
    let key : String
    let variable : Variable<T>
    let type : FormFieldType
    var valid : Driver<Bool>?
    var beginValidation : Driver<Void>?
    var isFilled: Bool {
        if let value = variable.value as? String {
            return value.count > 0
        }
        if let value = variable.value as? Int16 {
            return value > 0
        }
    
        return false
    }
    init(_ variable : Variable<T>, for key : String, type: FormFieldType, validSelector: ((T) -> Bool)? = nil) {
        self.variable = variable
        self.key = key
        self.type = type

        if let selector = validSelector {
            valid = variable.asDriver().map(selector).distinctUntilChanged()
        }
    }
}

class PickerFieldVM: VariableFieldVM<Titled?> {
    var action : (() -> Bool)?
    init(_ variable : Variable<Titled?>, for key : String, validSelector: ((Titled?) -> Bool)? = nil) {
        super.init(variable, for: key, type: .picker, validSelector: validSelector)
    }
}

class KeyPathFieldVM<Object, Value> : VariableFieldVM<Value> {
    typealias KP = ReferenceWritableKeyPath <Object, Value>
    private var object : Object
    let keyPath : KP
    let disposeBag = DisposeBag()

    init(_ object : Object, _ keyPath : KP, for key : String, type: FormFieldType, validSelector: ((Value) -> Bool)? = nil) {
        self.object = object
        self.keyPath = keyPath

        let aVariable = Variable(object[keyPath: keyPath])

        aVariable.asDriver().drive(onNext: { (value) in
           object[keyPath: keyPath] = value
        }).disposed(by: disposeBag)

        super.init(aVariable, for: key, type: type, validSelector: validSelector)
    }
}

class FieldsContainerVM : FormFieldVM, Fillable {
    let key: String
    let fields: [FormFieldVM]
    let colors: [UIColor]?
    let type = FormFieldType.container
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
        self.key = key
        self.fields = fields
        self.colors = colors
    }
}

