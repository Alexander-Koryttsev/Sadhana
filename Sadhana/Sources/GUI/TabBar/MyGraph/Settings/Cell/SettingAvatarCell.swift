//
//  SettingAvatarCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 11/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import EasyPeasy

class SettingAvatarCell: FormCell {

    let avatarView = UIImageView()
    let nameLabel = UILabel()
    static let reuseID = "SettingAvatarCell"

    init() {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: SettingAvatarCell.reuseID)

        contentView.addSubview(avatarView)
        avatarView.easy.layout([
            Left(14),
            Top(10),
            Bottom(10),
            Width().like(avatarView, .height)
        ])

        contentView.addSubview(nameLabel)
        nameLabel.easy.layout([
            Left(14).to(avatarView),
            CenterY(),
            Right(<=14)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
