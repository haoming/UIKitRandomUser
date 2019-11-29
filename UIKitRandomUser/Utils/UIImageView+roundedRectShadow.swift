//
//  UIImageView+roundedRectShadow.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 30/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func ruser_setRoundedRectShadow(cornerRadius: CGFloat, shadowRadius: CGFloat, containerView: UIView) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true

        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = shadowRadius
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadius).cgPath
        containerView.clipsToBounds = false
    }
    
}
