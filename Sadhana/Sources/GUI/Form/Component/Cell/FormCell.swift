//
//  FormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/20/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//




import EasyPeasy

class FormCell : UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isFilled : Bool {
        return false
    }
    
    var height : CGFloat {
        return 44
    }
    
    func reloadData() {
        
    }
}

protocol Validable {
    func set(valid:Bool)
}

extension Validable where Self : FormCell {
    func set(valid:Bool) {
        backgroundColor = valid ? .white : UIColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
    }
}

class ResponsibleFormCell: FormCell, Responsible {
    let goBack = PublishSubject<Void>()
    let goNext = PublishSubject<Void>()
    let becomeActive = PublishSubject<Void>()

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

protocol Responsible {
    var goBack : PublishSubject<Void> { get }
    var goNext : PublishSubject<Void> { get }
    var becomeActive : PublishSubject<Void> { get }
}

protocol ResponsibleContainer : Responsible {
    var responsible : Responsible { get }
}

extension ResponsibleContainer {
    var goBack : PublishSubject<Void> {
        return responsible.goBack
    }

    var goNext : PublishSubject<Void> {
        return responsible.goNext
    }

    var becomeActive : PublishSubject<Void> {
        return responsible.becomeActive
    }
}

protocol ResponsibleChain : Responsible {
    var responsibles : [Responsible] { get }
}

extension ResponsibleChain {
    var goBack : PublishSubject<Void> {
        return responsibles.first!.goBack
    }

    var goNext : PublishSubject<Void> {
        return responsibles.last!.goNext
    }

    var becomeActive : PublishSubject<Void> {
        return responsibles.first!.becomeActive
    }
}
