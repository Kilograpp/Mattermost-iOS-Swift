//
//  TSMarkdownParser+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import TSMarkdownParser

extension TSMarkdownParser {
    @nonobjc static let sharedInstance = TSMarkdownParser.customParser();
    
    private static func customParser() -> TSMarkdownParser {
        let defaultParser = TSMarkdownParser()
        defaultParser.setupAttributes()
        return defaultParser
    }
}

extension TSMarkdownParser {
    private func setupAttributes() -> Void {
        self.setupSettings()
        self.setupDefaultAttributes()
    }
    
    private func setupSettings() -> Void {
        self.skipLinkAttribute = false
    }
    
    private func setupDefaultAttributes() -> Void {
        self.defaultAttributes = [NSFontAttributeName : FontBucket.defaultFont]
    }
    
//    private func setupAttributes() -> Void {
//        
//    }
//    
//    private func setupAttributes() -> Void {
//        
//    }
//    
//    
//    - (void)setupAttrubutes {
//    [self setupSettings];
//    [self setupDefaultAttrubutes];
//    [self setupHeaderAttributes];
//    [self setupOtherAttributes];
//    }
//    
//    - (void)setupDefaultAttrubutes {
//    self.defaultAttributes = @{ NSFontAttributeName            : [UIFont kg_regular15Font],
//    NSForegroundColorAttributeName : [UIColor kg_blackColor] };
//    }
//    
//    - (void)setupHeaderAttributes {
//    NSMutableArray *headerAttrubutes  = [NSMutableArray array];
//    
//    for(int i = 0; i < 6; i++) {
//    NSDictionary *attr = @{ NSFontAttributeName            : [UIFont kg_semiboldFontOfSize:26 - 2 * i],
//    NSForegroundColorAttributeName : [UIColor kg_blackColor] };
//    [headerAttrubutes addObject:attr];
//    }
//    
//    self.headerAttributes = headerAttrubutes.copy;
//    }
//    
//    - (void)setupOtherAttributes {
//    self.emphasisAttributes = @{ NSFontAttributeName            : [UIFont kg_italic15Font],
//    NSForegroundColorAttributeName : [UIColor kg_blackColor] };
//    }

}