//
//  ProfileTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellConfiguration {
    func configureWith(title: String, info: String?, icon: String)
    func configureWithObject(_ object: AnyObject)
}

class ProfileTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var infoLabel: UILabel?
 
}


extension ProfileTableViewCell: ProfileTableViewCellConfiguration {
    func configureWith(title: String, info: String?, icon: String) {
        self.titleLabel?.text = title
        self.iconImageView?.image = UIImage(named: icon)
        self.infoLabel?.text = info
    }
    
    func configureWithObject(_ object: AnyObject) {
        if (object is ProfileDataSource) {
            let dataSource: ProfileDataSource = object as! ProfileDataSource
            self.titleLabel?.text = dataSource.title
            self.iconImageView?.image = UIImage.init(named: dataSource.iconName)
            self.infoLabel?.text = dataSource.info
        }
    }
}


private protocol ProfileTableViewCellLifeCycle {
    func awakeFromNib()
    func setSelected(_ selected: Bool, animated: Bool)
}


private protocol ProfileTableViewCellSetup {
    func initialSetup()
}


//MARK: ProfileTableViewCellLifeCycle

extension ProfileTableViewCell: ProfileTableViewCellLifeCycle {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


//MARK: - Setup

extension ProfileTableViewCell: ProfileTableViewCellSetup {
    func initialSetup() {
        self.titleLabel?.font = UIFont.kg_regular16Font()
        self.infoLabel?.font = UIFont.kg_regular16Font()
        self.titleLabel?.textColor = UIColor.kg_blackColor()
        self.infoLabel?.textColor = UIColor.kg_lightGrayColor()
    }
}
