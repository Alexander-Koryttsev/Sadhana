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
    let resignActive = PublishSubject<Bool/*isNext*/>()
    let becomeActive = PublishSubject<Bool/*isNext*/>()

    let disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
