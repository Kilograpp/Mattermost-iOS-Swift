//
//  FeedTableViewSectionHeader.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class FeedTableViewSectionHeader: UITableViewHeaderFooterView {
    var titleLabel: UILabel?
    var barView: UIView?
    fileprivate var title : String?
    
    static func reuseIdentifier() -> String {
        return "\(String(describing: self))Identifier"
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() -> Void {
        self.setupContentView()
        self.setupTitleLabel()
        self.setupBarView()
    }
    
    func setupContentView() -> Void {
        self.contentView.frame = self.bounds;
        self.contentView.backgroundColor = ColorBucket.whiteColor
    }
    
    func setupTitleLabel() -> Void {
        self.titleLabel = UILabel.init()
        self.titleLabel?.font = FontBucket.sectionTitleFont
        self.titleLabel?.textColor = ColorBucket.blackColor
        self.addSubview(self.titleLabel!)
    }
    
    func setupBarView() -> Void {
        self.barView = UIView.init()
        self.barView?.backgroundColor = ColorBucket.grayColor
        self.addSubview(self.barView!)
    }
    
    func configureWithTitle(_ title: String) {
        self.title = title
        self.titleLabel?.text = title
    }
    
    class func height() -> CGFloat {
        return 25
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //temp, s3 refactor
        if (self.title == nil) {
            self.title = "SWIFT3"
        }
        let width = CGFloat(StringUtils.widthOfString(self.title as NSString!, font: FontBucket.postAuthorNameFont))// as CGFloat
        self.titleLabel!.frame = CGRect(x: UIScreen.screenWidth() - 10 - ceil(width), y: 5, width: ceil(width), height: 18);
        if ((self.barView) != nil) {
            self.barView!.frame = CGRect(x: 0, y: 12, width: self.titleLabel!.frame.minX - 10, height: 1);
        }
        
    }
    
    override func prepareForReuse() {
        self.titleLabel!.text = nil;
        self.barView = nil;

    }
}
