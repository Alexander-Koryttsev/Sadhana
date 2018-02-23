//
//  Alert.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 12/18/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



class Alert {
    var title : String?
    var message : String?
    var style = iPhone ? UIAlertControllerStyle.actionSheet : UIAlertControllerStyle.alert
    private var actions = [Action]()
    private var completions = [Block]()

    var uiAlertController : UIAlertController {
        get {
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            for action in actions {
                alert.addAction(action.uiAlertAction(completions: completions))
            }
            return alert
        }
    }

    func add(action title: String, style: UIAlertActionStyle? = .default, handler: Block?) {
        actions.append(Action(title: title, style: style!, handler: handler))
    }

    func addCancelAction() {
        add(action:"cancel".localized, style: .cancel, handler: nil)
    }

    func add(completion: @escaping Block) {
        completions.append(completion)
    }

    struct Action {
        var title : String
        var style = UIAlertActionStyle.default
        var handler : Block?

        func uiAlertAction(completions:[Block]) -> UIAlertAction {
            return UIAlertAction(title: title, style: style, handler: { (_) in
                self.handler?()
                for completion in completions {
                    completion()
                }
            })
        }
    }
}
