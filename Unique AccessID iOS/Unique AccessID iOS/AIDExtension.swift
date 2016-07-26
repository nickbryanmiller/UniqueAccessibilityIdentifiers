//
// AIDExtension.swift
// Description: Creating Unique Accessibility Identifiers of every object at Runtime
//
// Developers:
// Nicholas Bryan Miller (GitHub: https://github.com/nickbryanmiller )
// Justin Rose (GitHub: https://github.com/justnjaster )
// 
// Created by Nicholas Miller on 7/21/16
// Copyright © 2016 Nicholas Miller. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeEveryObjectInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
    
    mutating func removeAllOfAnAbjectInArray(array: [Element], object: Element) {
        for element in array {
            if element == object {
                self.removeObject(object)
            }
        }
    }
}


extension String {
    func removeSpaces() -> String {
        let noSpaceString = self.characters.split{$0 == " "}.map{String($0)}.joinWithSeparator("")
        return noSpaceString
    }
    
    func splitBy(splitter: Character) -> [String] {
        let splitArray = self.characters.split{$0 == splitter}.map(String.init)
        return splitArray
    }
}