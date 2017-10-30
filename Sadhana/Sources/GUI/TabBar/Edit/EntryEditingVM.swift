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
    private var fieldsInternal = [FormField]()
    var fields : [FormField] { get {
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
            self.field(for: .japa7_30, type:Int16.self),
            self.field(for: .japa10, type:Int16.self),
            self.field(for: .japa18, type:Int16.self),
            self.field(for: .japa24, type:Int16.self),
        ]
        let japaContainer = FieldsContainer(EntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
        fieldsInternal.append(japaContainer)

        add(timeField: .reading, optional: false)
        add(field: .kirtan, type:Bool.self)
        add(field: .service, type:Bool.self)
        add(field: .yoga, type:Bool.self)
        add(field: .lections, type:Bool.self)

        if self.date != Date().trimmedTime {
            add(timeField: .bedTime, optional: true)
        }
    }

    private func add<T>(field: EntryFieldKey, type:T.Type) {
        if Local.defaults.isFieldEnabled(field) {
            fieldsInternal.append(self.field(for:field, type: T.self))
        }
    }

    private func add(timeField: EntryFieldKey, optional:Bool) {
        if Local.defaults.isFieldEnabled(timeField) {

            let variable = Variable(entry.timeOptionalValue(forKey: timeField))
            variable.asDriver().skip(2).drive(onNext: { [unowned entry] (next) in
                if entry.managedObjectContext == nil { return }
                entry.set(time: next ?? (optional ? nil : Time(rawValue: "0")), forKey: timeField)
                entry.dateUpdated = Date()
            }).disposed(by: disposeBag)

            fieldsInternal.append(VariableField<Time?>(variable, for: timeField.rawValue))
        }
    }

    private func field<T>(for key: EntryFieldKey, type:T.Type) -> VariableField<T> {
        let variable = Variable(entry.value(forKey: key.rawValue) as! T)
        variable.asDriver().skip(1).drive(onNext: { [unowned entry] (next) in
            entry.setValue(next is NSNull ? nil : next, forKey: key.rawValue)
            entry.dateUpdated = Date()
        }).disposed(by: disposeBag)

        return VariableField<T>(variable, for: key.rawValue)
    }
}

protocol FormField {
    var key : String { get }
}

class VariableField<T> : FormField {
    let key : String
    let variable : Variable<T>
    init(_ variable : Variable<T>, for key : String) {
        self.variable = variable
        self.key = key
    }
}

class FieldsContainer<T> : FormField {
    let key: String
    let fields: [VariableField<T>]
    let colors: [UIColor]?
    init(_ key: String, _ fields: [VariableField<T>], colors: [UIColor]? = nil) {
        self.key = key
        self.fields = fields
        self.colors = colors
    }
}

