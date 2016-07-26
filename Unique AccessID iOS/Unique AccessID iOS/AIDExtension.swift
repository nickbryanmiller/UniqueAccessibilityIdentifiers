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
        self.accessibilityIdentifier = aID
    }
    
    func getID() -> String {
        if let aID = self.accessibilityIdentifier {
            return aID
        }
        else {
            return ""
        }
    }
    
    // We actually could grab the type afterwards instead of doing it all in one function
    private func setID(vc: UIViewController) {
        let vcMirror = Mirror(reflecting: vc)
        var id: String = ""
        
        // let className = NSStringFromClass(vc.classForCoder).splitBy(".")[1]
        let className = "\(vcMirror.subjectType)"
        let grandParentOutletName = getGrandParentOutletName(vcMirror)
        let parentOutletName = getParentOutletName(vcMirror)
        let selfOutletName = getSelfOutletName(vcMirror)
        let uniqueStringAndType = getUniqueStringAndType()
        
        if className != "" {
            id = id + className
        }
        if grandParentOutletName != "" {
            id = id + "_" + grandParentOutletName
        }
        if parentOutletName != "" {
            id = id + "_" + parentOutletName
        }
        if selfOutletName != "" {
            id = id + "_" + selfOutletName
        }
        if uniqueStringAndType != "" {
            id = id + "_" + uniqueStringAndType
        }
    }
    
    func getGrandParentOutletName(vcMirror: Mirror) -> String {
        var memoryID = ""
        let selfString = "\(self.superview?.superview)"
        if let firstColon = selfString.characters.indexOf(":") {
            let twoAfterFirstColon = firstColon.advancedBy(2)
            let beyondType = selfString.substringFromIndex(twoAfterFirstColon)
            if let firstSemicolon = beyondType.characters.indexOf(";") {
                memoryID = beyondType.substringToIndex(firstSemicolon)
            }
        }
        
        for child in vcMirror.children {
            if memoryID != "" && "\(child.value)".containsString(memoryID) {
                if let childLabel = child.label {
                    return childLabel
                }
            }
        }
        
        return ""
    }
    
    func getParentOutletName(vcMirror: Mirror) -> String {
        var memoryID = ""
        let selfString = "\(self.superview)"
        if let firstColon = selfString.characters.indexOf(":") {
            let twoAfterFirstColon = firstColon.advancedBy(2)
            let beyondType = selfString.substringFromIndex(twoAfterFirstColon)
            if let firstSemicolon = beyondType.characters.indexOf(";") {
                memoryID = beyondType.substringToIndex(firstSemicolon)
            }
        }
        
        for child in vcMirror.children {
            if memoryID != "" && "\(child.value)".containsString(memoryID) {
                if let childLabel = child.label {
                    return childLabel
                }
            }
        }
        
        return ""
    }
    
    func getSelfOutletName(vcMirror: Mirror) -> String {
        var memoryID = ""
        let selfString = "\(self)"
        if let firstColon = selfString.characters.indexOf(":") {
            let twoAfterFirstColon = firstColon.advancedBy(2)
            let beyondType = selfString.substringFromIndex(twoAfterFirstColon)
            if let firstSemicolon = beyondType.characters.indexOf(";") {
                memoryID = beyondType.substringToIndex(firstSemicolon)
            }
        }
        
        for child in vcMirror.children {
            if memoryID != "" && "\(child.value)".containsString(memoryID) {
                if let childLabel = child.label {
                    return childLabel
                }
            }
        }
        
        return ""
    }
    
    private func getUniqueStringAndType() -> String {
        var positionInParentView: String = ""
        var title: String = ""
        var elementType: String = ""
        var uniqueStringAndType: String = ""
        
        if let myButton = self as? UIButton {
            elementType = "UIButton"
            if let buttonTitle = myButton.currentTitle {
                title = buttonTitle.removeSpaces()
            }
        }
        else if let myLabel = self as? UILabel {
            elementType = "UILabel"
            if let labelTitle = myLabel.text {
                title = labelTitle.removeSpaces()
            }
        }
        else if self is UIImageView {
            elementType = "UIImageView"
        }
        else if self is UITextView {
            elementType = "UITextView"
        }
        else if let myTextField = self as? UITextField {
            elementType = "UITextField"
            if let textFieldTitle = myTextField.placeholder {
                title = textFieldTitle.removeSpaces()
            }
        }
        else if self is UISegmentedControl {
            elementType = "UISegmentedControl"
        }
        else if self is UISwitch {
            elementType = "UISwitch"
        }
        else if let myNavigationBar = self as? UINavigationBar {
            elementType = "UINavigationBar"
            if let navigationBarTitle = myNavigationBar.topItem?.title {
                title = navigationBarTitle.removeSpaces()
            }
        }
        else if self is UITabBar {
            elementType = "UITabBar"
        }
        else if self is UIWebView {
            elementType = "UIWebView"
        }
        else if self is UITableViewCell {
            elementType = "UITableViewCell"
        }
        else if self is UICollectionViewCell {
            elementType = "UICollectionViewCell"
        }
        else {
            elementType = "UIView"
        }
        
        positionInParentView = getPositionInParentView()
        if positionInParentView != "" {
            uniqueStringAndType = uniqueStringAndType + positionInParentView
        }
        if title != "" {
            uniqueStringAndType = uniqueStringAndType + "_" + title
        }
        if elementType != "" {
            uniqueStringAndType = uniqueStringAndType + "_" + elementType
        }
        
        return uniqueStringAndType

    }
    
    func getType() -> String {
        var elementType: String = ""
        
        if self is UIButton {
            elementType = "UIButton"
        }
        else if self is UILabel {
            elementType = "UILabel"
        }
        else if self is UIImageView {
            elementType = "UIImageView"
        }
        else if self is UITextView {
            elementType = "UITextView"
        }
        else if self is UITextField {
            elementType = "UITextField"
        }
        else if self is UISegmentedControl {
            elementType = "UISegmentedControl"
        }
        else if self is UISwitch {
            elementType = "UISwitch"
        }
        else if self is UINavigationBar {
            elementType = "UINavigationBar"
        }
        else if self is UITabBar {
            elementType = "UITabBar"
        }
        else if self is UIWebView {
            elementType = "UIWebView"
        }
        else if self is UITableViewCell {
            elementType = "UITableViewCell"
        }
        else if self is UICollectionViewCell {
            elementType = "UICollectionViewCell"
        }
        else {
            elementType = "UIView"
        }
        
        return elementType
    }
    
    private func getPositionInParentView() -> String {
        
        var positionInParent: String = ""
        
        if let parentView = self.superview {
            let parentViewHeightDividedByThree = parentView.bounds.height / 3
            let parentViewWidthDividedByThree = parentView.bounds.width / 3
            
            let subviewCenterX = self.center.x
            let subviewCenterY = self.center.y
            
            // Area for Justin to put his code that draws the grid
            
            // End of area
            
            if subviewCenterY <= parentViewHeightDividedByThree {
                if subviewCenterX <= parentViewWidthDividedByThree {
                    positionInParent = "TopLeft"
                }
                else if subviewCenterX > parentViewWidthDividedByThree && subviewCenterX < parentViewWidthDividedByThree * 2 {
                    positionInParent = "TopMiddle"
                }
                else if subviewCenterX >= parentViewWidthDividedByThree * 2 {
                    positionInParent = "TopRight"
                }
            }
            else if subviewCenterY > parentViewHeightDividedByThree && subviewCenterY < parentViewHeightDividedByThree * 2 {
                if subviewCenterX <= parentViewWidthDividedByThree {
                    positionInParent = "MiddleLeft"
                }
                else if subviewCenterX > parentViewWidthDividedByThree && subviewCenterX < parentViewWidthDividedByThree * 2 {
                    positionInParent = "MiddleMiddle"
                }
                else if subviewCenterX >= parentViewWidthDividedByThree * 2 {
                    positionInParent = "MiddleRight"
                }
            }
            else if subviewCenterY >= parentViewHeightDividedByThree * 2 {
                if subviewCenterX <= parentViewWidthDividedByThree {
                    positionInParent = "BottomLeft"
                }
                else if subviewCenterX > parentViewWidthDividedByThree && subviewCenterX < parentViewWidthDividedByThree * 2 {
                    positionInParent = "BottomMiddle"
                }
                else if subviewCenterX >= parentViewWidthDividedByThree * 2 {
                    positionInParent = "BottomRight"
                }
            }
        }
        
        return positionInParent
    }
}





















