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

extension UIViewController {
    
    private struct AssociatedKeys {
        static var existingIDArray: [String] = []
    }
    
    func setEachIDInViewController() {
        setEachIDForViewControllerAndView(self.view)
    }
    
    private func setEachIDForViewControllerAndView(view: UIView) {
        for element in view.subviews {
            
            if element is UITableViewCell || element is UICollectionViewCell {
                setAndCheckID(view)
            }
            
            // Do we really need imageview though?
            if element is UITextField || element is UITextView || element is UILabel || element is UIButton || element is UINavigationBar || element is UITabBar || element is UISwitch || element is UISegmentedControl || element is UIImageView || element is UIWebView {
                setAndCheckID(view)
            }
            else if element.subviews.count > 0 {
                setEachIDForViewControllerAndView(view)
            }
        }
    }
    
    private func setAndCheckID(element: UIView) {
        if element.accessibilityIdentifier != nil && element.accessibilityIdentifier != "" {
            return
        }
        else {
            // Could just make it and return it here instead of setting it in setID
            element.setID(self)
            var idString = element.getID()
            while AssociatedKeys.existingIDArray.contains(idString) {
                idString = idString + "\(1)"
            }
            element.setCustomID(idString)
            AssociatedKeys.existingIDArray.append(idString)
        }
    }
    
    // Make sure to add ones that they set to this array also
    func getExisitingIDArray() -> [String] {
        return AssociatedKeys.existingIDArray
    }
    
    func printEachID() {
        for element in AssociatedKeys.existingIDArray {
            print(element)
        }
    }
    
    func printOutlets() {
        let vcMirror = Mirror(reflecting: self)
        
        for child in vcMirror.children {
            print(child)
            print(child.label)
        }
    }
}

extension UIView {
    
    func setCustomID(aID: String) {
        
    }
    
    func getID() -> String {
        
    }
    
    private func setID(vc: UIViewController) {
        let vcMirror = Mirror(reflecting: vc)
        var id: String = ""
    }
    
    func getGrandParentOutletName(vcMirror: Mirror) -> String {
        
    }
    
    func getParentOutletName(vcMirror: Mirror) -> String {
        
    }
    
    func getSelfOutletName(vcMirror: Mirror) -> String {
        
    }
    
    private func getUniqueStringAndType() -> String {
        
    }
    
    func getType() -> String {
        
    }
    
    private func getPositionInParentView() -> String {
        
    }
}





















