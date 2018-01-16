//
//  FormHelper.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit


class FormHelper {
    static func bind(cells: [FormCell], endEditingAction:Block? = nil, disposeBag: DisposeBag) {
        var firstResponsible : Responsible?
        var previousResponsible : Responsible?
        for cell in cells {
            if let responsible = cell as? Responsible {
                if let previousResponsible = previousResponsible {
                    previousResponsible.goNext.bind(to: responsible.becomeActive).disposed(by: disposeBag)
                    responsible.goBack.bind(to: previousResponsible.becomeActive).disposed(by: disposeBag)
                }

                if let responsible = responsible as? ResponsibleChain {
                    previousResponsible = responsible.responsibles.last!
                }
                else {
                    previousResponsible = responsible
                }

                if firstResponsible == nil {
                    firstResponsible = responsible
                }
            }
        }

        if let endEditingAction = endEditingAction {
            if let firstResponsible = firstResponsible {
                firstResponsible.goBack.subscribe(onNext:{ () in
                    endEditingAction()
                }).disposed(by: disposeBag)
            }

            if let lastResponsibleCell = previousResponsible {
                lastResponsibleCell.goNext.subscribe(onNext:{ () in
                    endEditingAction()
                }).disposed(by: disposeBag)
            }
        }
    }
}
