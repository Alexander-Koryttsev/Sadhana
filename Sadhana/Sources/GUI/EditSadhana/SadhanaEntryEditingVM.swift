//
//  SadhanaEntryEditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

enum SadhanaEntryFieldKey : String {
    case wakeUpTime = "wakeUpTime"
    case japa = "japa_rounds"
    case japa7_30 = "japaCount7_30"
    case japa10 = "japaCount10"
    case japa18 = "japaCount18"
    case japa24 = "japaCount24"
    case reading = "reading"
    case kirtan = "kirtan"
    case service = "service"
    case yoga = "exercise"
    case lections = "lections"
    case bedTime = "bedTime"
}

class SadhanaEntryEditingVM: BaseVM {

    let date : Date
    private var fieldsInternal = [FormFieldVM]()
    var fields : [FormFieldVM] { get {
            return fieldsInternal
        }
    }
    private let entry : LocalSadhanaEntry

    init(date: Date, context: NSManagedObjectContext) {
        self.date = date.dayDate

        if let localEntry = context.fetchSadhanaEntry(date: self.date) {
            entry = localEntry
        }
        else {
            entry = context.create(LocalSadhanaEntry.self)
            entry.userID = Local.defaults.userID!
            entry.date = self.date
            entry.dateCreated = Date()
            entry.dateUpdated = Date() //TODO: move to the 'save' event
        }

        super.init()

        add(field: .wakeUpTime)

        let japaFields = [
            self.field(forKey: .japa7_30),
            self.field(forKey: .japa10),
            self.field(forKey: .japa18),
            self.field(forKey: .japa24),
        ]
        let japaContainer = FieldsContainerVM(SadhanaEntryFieldKey.japa.rawValue, japaFields, colors: [.sdSunflowerYellow, .sdTangerine, .sdNeonRed, .sdBrightBlue])
        fieldsInternal.append(japaContainer)

        add(field: .reading)
        add(field: .kirtan)
        add(field: .service)
        add(field: .yoga)
        add(field: .lections)
        add(field: .bedTime)

    }

    private func field(forKey: SadhanaEntryFieldKey) -> ManagedFieldVM {
        return ManagedFieldVM(forKey.rawValue, entry:entry)
    }

    private func add(field: SadhanaEntryFieldKey) {
        if Local.defaults.isFieldEnabled(field) {
            fieldsInternal.append(self.field(forKey:field))
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

class FieldsContainerVM : FormFieldVM {
    let key: String
    let fields: [VariableFieldVM]
    let colors: [UIColor]?
    init(_ key: String, _ fields: [VariableFieldVM], colors: [UIColor]? = nil) {
        self.key = key
        self.fields = fields
        self.colors = colors
    }
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

