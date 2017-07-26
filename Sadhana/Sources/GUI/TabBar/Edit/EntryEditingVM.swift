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
    private let entry : LocalSadhanaEntry

    init(date: Date, context: NSManagedObjectContext) {
        self.date = date.trimmedTime

        if let localEntry = context.fetchSadhanaEntry(date: self.date) {
            entry = localEntry
        }
        else {
            entry = context.create(LocalSadhanaEntry.self)
            entry.userID = Local.defaults.userID!
            entry.date = self.date
            entry.month = self.date.trimmedDayAndTime
            entry.dateCreated = Date()
            entry.dateUpdated = Date() //TODO: move to the 'save' event
        }

        super.init()

        add(timeField: .wakeUpTime, optional: true)

        let japaFields = [
            self.field(forKey: .japa7_30),
            self.field(forKey: .japa10),
            self.field(forKey: .japa18),
            self.field(forKey: .japa24),
        ]
        let japaContainer = FieldsContainerVM(SadhanaEntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
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

    private func field(forKey: SadhanaEntryFieldKey) -> ManagedFieldVM {
        return ManagedFieldVM(forKey.rawValue, entry:entry)
    }

    private func timeField(forKey: SadhanaEntryFieldKey, optional: Bool) -> TimeFieldVM {
        return TimeFieldVM(forKey, entry:entry, optional: optional)
    }

    private func add(field: SadhanaEntryFieldKey) {
        if Local.defaults.isFieldEnabled(field) {
            fieldsInternal.append(self.field(forKey:field))
        }
    }

    private func add(timeField: SadhanaEntryFieldKey, optional: Bool) {
        if Local.defaults.isFieldEnabled(timeField) {
            fieldsInternal.append(self.timeField(forKey:timeField, optional: optional))
        }
    }
}

protocol FormFieldVM {
    var key : String { get }
}

protocol VariableFieldVM: FormFieldVM {
    var variable : Variable<Any?> { get }
    var disposeBag : DisposeBag { get }
}

class ManagedFieldVM : VariableFieldVM {
    let key : String
    let variable : Variable<Any?>
    private let entry : NSManagedObject
    let disposeBag = DisposeBag()
    init(_ key: String, entry: NSManagedObject) {
        self.key = key
        variable = Variable(entry.value(forKey: key))
        self.entry = entry
        variable.asDriver().skip(1).drive(onNext: { (next) in
            if next is NSNull {
                entry.setValue(nil, forKey: key)
            }
            else {
                entry.setValue(next, forKey: key)
            }
        }).disposed(by: disposeBag)
    }
}

class FieldsContainerVM : FormFieldVM {
    let key: String
    let fields: [VariableFieldVM]
    let colors: [UIColor]?
    init(_ key: String, _ fields: [ManagedFieldVM], colors: [UIColor]? = nil) {
        self.key = key
        self.fields = fields
        self.colors = colors
    }
}

class TimeFieldVM: VariableFieldVM {
    let key : String
    let variable : Variable<Any?>
    private let entry : LocalSadhanaEntry
    let disposeBag = DisposeBag()
    let optional : Bool
    init(_ key: SadhanaEntryFieldKey, entry: LocalSadhanaEntry, optional: Bool) {
        self.key = key.rawValue
        self.optional = optional
        variable = Variable(entry.timeOptionalValue(forKey: key))
        self.entry = entry
        variable.asDriver().skip(1).drive(onNext: { (next) in
            if optional {
                entry.set(time: next as? Time, forKey: key)
            }
            else {
                entry.set(time:(next as? Time ?? Time(rawValue: 0)), forKey: key)
            }
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

