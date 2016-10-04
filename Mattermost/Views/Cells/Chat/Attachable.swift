//
//  Attachable.swift
//  Mattermost
//
//  Created by Maxim Gubin on 13/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol Attachable: class {
    func configureWithFile(_ file: File)
}
