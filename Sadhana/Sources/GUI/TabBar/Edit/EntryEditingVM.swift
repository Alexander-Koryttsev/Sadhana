//
//  EntryEditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class EntryEditingVM: BaseVM {

    let date : Date
    private var fieldsInternal = [FormFieldVM]()
    var fields : [FormFieldVM] { get {
            return fieldsInternal
        }
    }
    private let entry : ManagedEntry

    init(date: Date, context: NSManagedObjectContext) {
        self.date = date.trimmedTime

        if let localEntry = context.fetch(entryFor: self.date) {
            entry = localEntry
        }
        else {
            entry = context.create(ManagedEntry.self)
            entry.userID = Local.defaults.userID!
            entry.date = self.date
            entry.month = self.date.trimmedDayAndTime
            entry.dateCreated = Date()
            entry.dateUpdated = entry.dateCreated
        }

        super.init()

        add(timeField: .wakeUpTime, optional: true)

        let japaFields = [
            self.field(forKey: .japa7_30),
            self.field(forKey: .japa10),
            self.field(forKey: .japa18),
            self.field(forKey: .japa24),
        ]
        let japaContainer = FieldsContainerVM(EntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
        fieldsInternal.append(japaContainer)

        add(timeField: .reading, optional: false)
        add(field: .kirtan)
        add(field: .service)
        add(field: .yoga)
        add(field: .lections)

        if self.date != Date().trimmedTime {
            add(timeField: .bedTime, optional: true)
        }
    }

    private func field(forKey: EntryFieldKey) -> ManagedFieldVM {
        return ManagedFieldVM(forKey.rawValue, entry:entry)
    }

    private func timeField(forKey: EntryFieldKey, optional: Bool) -> TimeFieldVM {
        return TimeFieldVM(forKey, entry:entry, optional: optional)
    }

    private func add(field: EntryFieldKey) {
        if Local.defaults.isFieldEnabled(field) {
            fieldsInternal.append(self.field(forKey:field))
        }
    }

    private func add(timeField: EntryFieldKey, optional: Bool) {
        if Local.defaults.isFieldEnabled(timeField) {
            fieldsInternal.append(self.timeField(forKey:timeField, optional: optional))
        }
    }
}

protocol FormFieldVM {
    var key : String { get }
}

protocol VariableFieldVM : FormFieldVM {
    var variable : Variable<Any?> { get }
}

class ManagedFieldVM : VariableFieldVM {
    let key : String
    let variable : Variable<Any?>
    private let entry : ManagedUpdatable
    let disposeBag = DisposeBag()
    init(_ key: String, entry: ManagedUpdatable) {
        self.key = key
        variable = Variable(entry.value(forKey: key))
        self.entry = entry
        variable.asDriver().skip(1).drive(onNext: { (next) in
            entry.setValue(next is NSNull ? nil : next, forKey: key)
            entry.dateUpdated = Date()
        }).disposed(by: disposeBag)
    }
}

class FieldsContainerVM : FormFieldVM {
    let key: String
    let fields: [ManagedFieldVM]
    let colors: [UIColor]?
    init(_ key: String, _ fields: [ManagedFieldVM], colors: [UIColor]? = nil) {
        self.key = key
        self.fields = fields
        self.colors = colors
    }
}

class TimeFieldVM: FormFieldVM {
    let key : String
    let variable : Variable<Time?>
    private let entry : ManagedUpdatable
    let disposeBag = DisposeBag()
    let optional : Bool
    init(_ key: FieldKey, entry: ManagedUpdatable, optional: Bool) {
        self.key = key.rawValue
        self.optional = optional
        variable = Variable(entry.timeOptionalValue(forKey: key))
        self.entry = entry
        variable.asDriver().skip(2).drive(onNext: { (next) in
            if entry.managedObjectContext == nil { return }
            entry.set(time:(next ?? (optional ? nil : Time(rawValue: 0))), forKey: key)
            entry.dateUpdated = Date()
        }).disposed(by: disposeBag)
    }
}

/*
 add(field: .wakeUpTime  , value: entry.wakeUpTime)
 add(field: .japa        , value: entry.japaCount7_30, entry.japaCount10, entry.japaCount18, entry.japaCount24))
 add(field: .reading     , value: entry.reading)
 add(field: .kirtan      , value: entry.kirtan)
 add(field: .service     , value: entry.service)
 add(field: .yoga        , value: entry.exercise)
 add(field: .lections    , value: entry.lections)
 add(field: .bedTime     , value: entry.bedTime)
 */

