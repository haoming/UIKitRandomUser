//
//  UserTableViewCell.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {
    static let nibName = "UserTableViewCell"

    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarView.layer.cornerRadius = 20
        self.avatarView.clipsToBounds = true

        self.avatarContainer.layer.cornerRadius = 20
        self.avatarContainer.layer.shadowColor = UIColor.black.cgColor
        self.avatarContainer.layer.shadowOpacity = 0.2
        self.avatarContainer.layer.shadowRadius = 5
        self.avatarContainer.layer.shadowOffset = CGSize.zero
        self.avatarContainer.layer.shadowPath = UIBezierPath(roundedRect: self.avatarContainer.bounds, cornerRadius: 20).cgPath
        self.avatarContainer.clipsToBounds = false
    }
    
    func configure(user: UserEntity) {
        self.nameLabel.text = user.fullName
        if let dob = user.dateOfBirth {
            self.dobLabel.text = "DOB: \(DateUtils.formatDob(dob))"
        } else {
            self.dobLabel.text = "DOB: unknown"
        }
        if let genderEmoji = user.genderEmoji {
            self.genderLabel.text = "Gender: \(genderEmoji)"
        } else {
            self.genderLabel.text = "Gender: unknown"
        }
        if let nat = user.nationalityCountryCode {
            self.nationalityLabel.text = "Nationality: \(nat.flag)"
        } else {
            self.nationalityLabel.text = "Nationality: unknown"
        }
        
        let avatarPlaceholder = UIImage(named: "Icon")
        if let avatarUrl = user.avatarUrl {
            self.avatarView.kf.setImage(with: avatarUrl, placeholder: avatarPlaceholder)
        } else {
            self.avatarView.image = avatarPlaceholder
        }
    }
}
