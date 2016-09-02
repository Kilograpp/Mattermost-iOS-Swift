//
//  ProfileTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell, Reusable {

//MARK: - Properties
    
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var arrowImageView: UIImageView?
    @IBOutlet weak var arrowButton: UIButton?
    
    
//MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

//MARK: - Configuration
    
    func configureWithObject(object: AnyObject) {
        self.arrowButton?.setImage(UIImage(named: "login_arrow_icon_passive.png"), forState: UIControlState.Normal)
        
        if (object is ProfileDataSource) {
            let dataSource: ProfileDataSource = object as! ProfileDataSource
            
            self.titleLabel?.text = dataSource.title
            self.iconImageView?.image = UIImage.init(named: dataSource.iconName)
            self.infoLabel?.text = dataSource.info
        }
    }
}


//MARK: - Setup

extension ProfileTableViewCell {
    func initialSetup() {
        self.titleLabel?.font = UIFont.kg_regular16Font()
        self.infoLabel?.font = UIFont.kg_regular16Font()
        self.titleLabel?.textColor = UIColor.kg_blackColor()
        self.infoLabel?.textColor = UIColor.kg_lightGrayColor()
    }
}