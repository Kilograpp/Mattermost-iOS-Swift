//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 04.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


import MBProgressHUD

private protocol Configuration: class {
    func configureForNewImage()
    func configureZoomScale()
    func showActivityIndicator()
    func hideActivityIndicator()
}


public class ImagePreviewTableViewCell: UICollectionViewCell {

//MARK: Properties
    var scrollView: UIScrollView
    let imageView: UIImageView
    var activityIndicatorView: UIActivityIndicatorView
    var image: UIImage? {
        didSet {
            configureForNewImage()
        }
    }

//MARK: LifeCycle
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        self.scrollView = UIScrollView(frame: frame)
        self.activityIndicatorView = UIActivityIndicatorView()
        
        super.init(frame: frame)
        
        initialSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: Configuration
extension ImagePreviewTableViewCell: Configuration {
    func configureForNewImage() {
        self.imageView.image = image
        self.imageView.sizeToFit()
        self.imageView.alpha = 0.0
        
        configureZoomScale()
        scrollViewDidZoom(scrollView)
        
        UIView.animate(withDuration: 0.5) {
            self.imageView.alpha = 1.0
        }
    }
    
    fileprivate func configureZoomScale() {
        let imageViewSize = self.imageView.bounds.size
        let scrollViewSize = self.scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        self.scrollView.minimumZoomScale = min(widthScale, heightScale)
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
    }
    
    func showActivityIndicator() {
        self.activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        self.activityIndicatorView.stopAnimating()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupScrollView()
    func setupImageView()
    func setupGestureRecognizers()
}

fileprivate protocol Action: class {
    func doubleTapAction(recognizer: UITapGestureRecognizer)
}

//MARK: Setup
extension ImagePreviewTableViewCell: Setup {
    func initialSetup() {
        setupScrollView()
        setupImageView()
        scrollView.delegate = self
        setupGestureRecognizers()
        setupActivityIndicatorView()
    }
    
    func setupScrollView() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingLayoutConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .leading, relatedBy: .equal,
                                                         toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        let topLayoutConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal,
                                                     toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0)
        let trailingLayoutConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .trailing, relatedBy: .equal,
                                                         toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomLayoutConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .bottom, relatedBy: .equal,
                                                       toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let scrollViewConstraints = [ leadingLayoutConstraint, topLayoutConstraint, trailingLayoutConstraint, bottomLayoutConstraint ]
        
        contentView.addSubview(self.scrollView)
        contentView.addConstraints(scrollViewConstraints)
        
    }
    
    func setupImageView() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: .leading, relatedBy: .equal,
                                                         toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let topLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal,
                                                    toItem: self.scrollView, attribute: .top, multiplier: 1, constant: 0)
        let trailingLayoutConstrain = NSLayoutConstraint(item: self.imageView, attribute: .trailing, relatedBy: .equal,
                                                         toItem: self.scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomLayoutConstrain = NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal,
                                                       toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let imageViewConstraints = [leadingLayoutConstraint, topLayoutConstraint, trailingLayoutConstrain, bottomLayoutConstrain]
        
        self.scrollView.addSubview(self.imageView)
        self.scrollView.addConstraints(imageViewConstraints)
    }
    
    func setupActivityIndicatorView() {
        let size = Constants.UI.LongPaddingSize
        let x = (self.contentView.frame.size.width - size) / 2
        let y = (self.contentView.frame.size.height - size) / 2
        
        self.activityIndicatorView.frame = CGRect(x: x, y: y, width: size, height: size)
        self.contentView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.activityIndicatorViewStyle = .gray
        self.activityIndicatorView.hidesWhenStopped = true
    }
    
    func setupGestureRecognizers() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
}

//MARK: Action
extension ImagePreviewTableViewCell: Action {
    func doubleTapAction(recognizer: UITapGestureRecognizer) {
        let zoomScale = (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) ? self.scrollView.minimumZoomScale
                                                                                       : self.scrollView.maximumZoomScale
        self.scrollView.setZoomScale(zoomScale, animated: true)
    }
}

//MARK: UIScrollViewDelegate
extension ImagePreviewTableViewCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = (imageViewSize.height < scrollViewSize.height) ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = (imageViewSize.width < scrollViewSize.width) ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding,
                                                   left: horizontalPadding,
                                                   bottom: verticalPadding,
                                                   right: horizontalPadding)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
}
