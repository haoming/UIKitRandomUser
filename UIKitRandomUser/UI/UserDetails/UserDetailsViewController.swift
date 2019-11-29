//
//  UserDetailsViewController.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class UserDetailsViewController: UITableViewController {
    
    @IBOutlet weak var photoContainer: UIView!
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
        
    private var user: User!
    
    func setUp(user: User) {
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeholder = UIImage(named: "Icon")
        if let url = user.largeAvatarUrl {
            self.photoView.kf.setImage(with: url, placeholder: placeholder)
        } else {
            self.photoView.image = placeholder
        }
        
        self.title = user.fullName
        self.firstNameLabel.text = user.firstName
        self.lastNameLabel.text = user.lastName
        if let dob = user.dateOfBirth {
            self.dobLabel.text = DateUtils.formatDob(dob)
        } else {
            self.dobLabel.text = "unknown"
        }
        if let nat = user.nationalityCountryCode {
            self.nationalityLabel.text = "\(nat.flag) \(nat.country)"
        } else {
            self.nationalityLabel.text = "unknown"
        }
        self.emailLabel.text = user.email ?? "unknown"
        self.addressLabel.text = user.address ?? "unkown"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.photoView.ruser_setRoundedRectShadow(cornerRadius: 20, shadowRadius: 5, containerView: self.photoContainer)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
