//
//  SettingsVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import AlamofireImage
import Crashlytics

class RootSettingsVC : BaseSettingsVC {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Answers.logContentView(withName: "Settings", contentType: nil, contentId: nil, customAttributes: nil)
    }
}
