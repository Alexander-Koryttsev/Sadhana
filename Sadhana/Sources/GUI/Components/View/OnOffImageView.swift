//
//  DoubleImageView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/18/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



class OnOffImageView : UIImageView {

    var isOn : Bool = false { didSet {
            if isOn {
                image = onImage
                highlightedImage = onImageHighlighted
            }
            else {
                image = offImage
                highlightedImage = offImageHighlighted
            }
        }
    }

    var onImage : UIImage
    var onImageHighlighted : UIImage?

    var offImage : UIImage
    var offImageHighlighted : UIImage?

    init(offImage: UIImage, offImageHighlighted: UIImage? = nil, onImage: UIImage, onImageHighlighted: UIImage? = nil) {
        self.onImage = onImage
        if let onImageHighlighted = onImageHighlighted {
            self.onImageHighlighted = onImageHighlighted
        }

        self.offImage = offImage
        if let offImageHighlighted = offImageHighlighted {
            self.offImageHighlighted = offImageHighlighted
        }
        super.init(image: self.offImage, highlightedImage: self.offImageHighlighted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
