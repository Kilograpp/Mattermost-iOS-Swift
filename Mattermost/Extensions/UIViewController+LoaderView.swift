//
//  UIViewController+LoaderView.swift
//  Mattermost
//
//  Created by Владислав on 06.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

import NVActivityIndicatorView

protocol LoaderView{
    func showLoaderView()
    func hideLoaderView()
}

extension UIViewController: LoaderView{
    func showLoaderView(){
        let screenSize = UIScreen.main.bounds
        
        let loader = UIView.init(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height
, width: screenSize.width, height: screenSize.height))
        loader.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.92)
        
        let frame = CGRect(x: (screenSize.width-screenSize.width/7)/2, y: (screenSize.height-screenSize.height/7)/2, width: screenSize.width/7, height: screenSize.height/7)
        let color = UIColor.kg_blueColor()
        let spinner = NVActivityIndicatorView(frame: frame, type: .ballPulse, color: color, padding: 0.0)
        loader.addSubview(spinner)
        spinner.startAnimating()
        self.view.addSubview(loader)
    }
    
    func hideLoaderView(){
        let activityIndicator = self.view.subviews.last?.subviews.first
        guard activityIndicator != nil else { return }
        guard (activityIndicator?.isKind(of: NVActivityIndicatorView.self))! else { return }
        
        (activityIndicator as! NVActivityIndicatorView).stopAnimating()
        self.view.subviews.last?.removeFromSuperview()
    }
}
