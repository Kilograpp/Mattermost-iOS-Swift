//
//  AttachmentField.swift
//  Mattermost
//
//  Created by Maxim Gubin on 06/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

enum AttachmentFieldAttributes: String {
    case short = "short"
    case value = "value"
    case attributedValue = "attributedValue"
    case title = "title"
}

final class AttachmentField: RealmObject {
    dynamic var short: Bool = false
    dynamic var value: String? {
        didSet {
            computeAttributedValue()
            computeAttributedValueData()
        }
    }
    dynamic var title: String?
    
    private dynamic var _attributedValueData: RealmAttributedString?
    
    lazy var attributedValue: NSAttributedString? = {
        return self._attributedValueData?.attributedString
    }()
    
    override class func ignoredProperties() -> [String] {
        return [
            AttachmentFieldAttributes.attributedValue.rawValue
        ]
    }
}

//private protocol ResponseMappings : class {
//    static func mapping() -> RKObjectMapping
//}

private protocol Computations : class {
    func computeAttributedValue()
    func computeAttributedValueData()
}

//extension AttachmentField: ResponseMappings {
//    override static func mapping() -> RKObjectMapping {
//        let mapping = super.emptyMapping()
//        mapping.addAttributeMappingsFromArray([
//            AttachmentFieldAttributes.short.rawValue,
//            AttachmentFieldAttributes.value.rawValue,
//            AttachmentFieldAttributes.title.rawValue
//        ])
//        return mapping
//    }
//}

extension AttachmentField: Computations {
    private func computeAttributedValueData() {
        self._attributedValueData = RealmAttributedString(attributedString: self.attributedValue)
    }
    private func computeAttributedValue() {
        self.attributedValue = self.value?.markdownAttributedString()
    }
}