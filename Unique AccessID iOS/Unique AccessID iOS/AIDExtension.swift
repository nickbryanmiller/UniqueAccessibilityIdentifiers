// Please Leave This Header In This File
//
// File Name: AIDExtension.swift
//
// Description:
// Creating Unique Accessibility Identifiers of every object at Runtime
//
// This is big for Native Automated Testing in conjunction with the XCTest Framework
// If you call this file the test recording software no longer has to grab the relative identifier because it
// can grab the absolute identifier making the test cases less difficult to write
//
// Developers:
// Nicholas Bryan Miller (GitHub: https://github.com/nickbryanmiller )
// Justin Rose (GitHub: https://github.com/justinjaster )
// 
// Created by Nicholas Miller on 7/21/16
// Copyright © 2016 Nicholas Miller. All rights reserved.
// This code is under the Apache 2.0 License.
//
// Use:
// In the viewDidLayoutSubviews() method in each ViewController put "self.setEachIDInViewController()"
// and this file will do the rest for you
//
// Tools:
// We make use of class extensions, mirroring, and the built in view hierarchy
//
// Note:
// If you see an issue anywhere please open a merge request and we will get to it as soon as possible.
// If you would like to make an improvement anywhere open a merge request.
// If you liked anything or are curious about anything reach out to one of us.
// We like trying to improve the iOS Community :)
// If you or your company decides to take it and implement it we would LOVE to know that please!!
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
    
    mutating func removeAllOfAnObjectInArray(array: [Element], object: Element) {
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
    
    // This could be a dictionary where the key is the ViewControllerName
    private struct AssociatedKeys {
        static var existingIDArray: [String] = []
    }
    
    func setEachIDInViewController() {
        setEachIDForViewControllerAndView(self.view)
    }
    
    private func setEachIDForViewControllerAndView(view: UIView) {
        for element in view.subviews {
            
            if element is UITableViewCell || element is UICollectionViewCell || element is UIScrollView {
                setAndCheckID(element)
            }
            
            // Do we really need imageview though?
            if element is UITextField || element is UITextView || element is UILabel || element is UIButton || element is UINavigationBar || element is UITabBar || element is UISwitch || element is UISegmentedControl || element is UIImageView || element is UIWebView {
                setAndCheckID(element)
            }
            else if element.subviews.count > 0 {
                setEachIDForViewControllerAndView(element)
            }
        }
    }
    
    private func setAndCheckID(element: UIView) {
        if element.accessibilityIdentifier != nil && element.accessibilityIdentifier != "" {
            return
        }
        else {
            if element is UIScrollView {
                element.setID(self, pageType: "Dynamic")
            }
            else {
                element.setID(self, pageType: "Static")
            }
            
            var idString = element.getID()
            
            var testIDString = idString
            var duplicateCount = 1
            
            // This is to make sure that we do not have a duplicate. If we do it appends a number to it
            // This number is increasing based on the order it was added to the xml
            while AssociatedKeys.existingIDArray.contains(testIDString) {
                testIDString = idString
                testIDString = testIDString + "\(duplicateCount)"
                duplicateCount = duplicateCount + 1
            }
            
            idString = testIDString
            element.setCustomID(idString)
            AssociatedKeys.existingIDArray.append(idString)
        }
    }
    
    // This method is for developers to set a custom ID
    // At the viewcontroller level is ideal because we can check for a duplicate
    func setIDForElement(element: UIView, aID: String) {
        if AssociatedKeys.existingIDArray.contains(aID) {
            print("It already exists in the application")
        }
        else {
            element.setCustomID(aID)
        }
    }
    
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
    
    private func setID(vc: UIViewController, pageType: String) {
        let vcMirror = Mirror(reflecting: vc)
        var id: String = "<NJAid"
        
        // let className = NSStringFromClass(vc.classForCoder).splitBy(".")[1]
        let className = "\(vcMirror.subjectType)"
        let grandParentOutletName = getGrandParentOutletName(vcMirror)
        let parentOutletName = getParentOutletName(vcMirror)
        let selfOutletName = getSelfOutletName(vcMirror)
        let positionInParent = getPositionInParentView()
        let title = getTitle()
        let type = getType()
        
        if className != "" {
            id = id + ", ClassName: " + className
        }
        if grandParentOutletName != "" {
            id = id + ", GPOutlet: " + grandParentOutletName
        }
        if parentOutletName != "" {
            id = id + ", POutlet: " + parentOutletName
        }
        if selfOutletName != "" {
            id = id + ", SelfOutlet: " + selfOutletName
        }
        if pageType == "Static" {
            if positionInParent != "" {
                id = id + ", PositionInParent: " + positionInParent
            }
        }
        if title != "" {
            id = id + ", Title: " + title
        }
        if type != "" {
            id = id + ", Type: " + type
        }
        
        id = id + ">"
        
        self.accessibilityIdentifier = id
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
    
    private func getTitle() -> String {
        var title: String = ""
        
        if let myButton = self as? UIButton {
            if let buttonTitle = myButton.currentTitle {
                title = buttonTitle.removeSpaces()
            }
        }
        else if let myLabel = self as? UILabel {
            if let labelTitle = myLabel.text {
                title = labelTitle.removeSpaces()
            }
        }
        else if let myTextField = self as? UITextField {
            if let textFieldTitle = myTextField.placeholder {
                title = textFieldTitle.removeSpaces()
            }
        }
        else if let myNavigationBar = self as? UINavigationBar {
            if let navigationBarTitle = myNavigationBar.topItem?.title {
                title = navigationBarTitle.removeSpaces()
            }
        }

        return title
    }
    
    func getType() -> String {
        var elementType: String = ""
        
        switch self {
        case is UIButton:
            elementType = "UIButton"
        case is UILabel:
            elementType = "UILabel"
        case is UIImageView:
            elementType = "UIImageView"
        case is UITextView:
            elementType = "UITextView"
        case is UITextField:
            elementType = "UITextField"
        case is UISegmentedControl:
            elementType = "UISegmentedControl"
        case is UISwitch:
            elementType = "UISwitch"
        case is UINavigationBar:
            elementType = "UINavigationBar"
        case is UITabBar:
            elementType = "UITabBar"
        case is UIWebView:
            elementType = "UIWebView"
        case is UITableViewCell:
            elementType = "UITableViewCell"
        case is UICollectionViewCell:
            elementType = "UICollectionViewCell"
        case is UITableView:
            elementType = "UITableView"
        case is UICollectionView:
            elementType = "UICollectionView"
        default:
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





















