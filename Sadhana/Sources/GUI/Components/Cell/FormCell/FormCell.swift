//
//  FormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/20/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyPeasy

class FormCell : UITableViewCell {

    func height() -> CGFloat {
        return 44
    }
}

class ResponsibleCell: FormCell {
    let goBack = PublishSubject<Void>()
    let becomeActive = PublishSubject<Void>()
    let resignActive = PublishSubject<Void>()

    let disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        becomeActive.subscribe(onNext: { [weak self] () in
            self?.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            _ = becomeFirstResponder()
        }
    }
}
