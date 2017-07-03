//
//  TestPageViewController.swift
//  Assignment
//
//  Created by Hosung, Lee on 2016. 7. 22..
//  Copyright © 2016년 Hosung. All rights reserved.
//

import UIKit

class QuestionItem:NSObject {
    var question : String?
    var question_type : String?
    var question_img : String?
    var answers: Dictionary<String,String>?
    var collect_answer : String?
    var user_answer : String?
}

class TestPageViewController: UIPageViewController, XMLParserDelegate, UIPageViewControllerDataSource {
    // for view state
    var reviewState : Bool = false
    
    // for loading indicator
    var boxView = UIView()
    
    // for xml
    var parser = XMLParser()
    var testTitle : String = ""
    var testXMLList : Array<QuestionItem>?
    var testXMLItem : QuestionItem?
    var curElement = String()
    var curElementID = String()
    
    // for test pages
    var testItemList : Array<QuestionItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIndicator()
        
        // for Test Review
        if reviewState {
            settingPageViewController()
            removeIndicator()
            return
        }
        
        // for noraml Test
        if(parseXMLFile()) {
            if(testXMLList?.count == 0) {
                return
            }
            if testItemList != nil {
                testItemList = nil
            }
            testItemList = Array<QuestionItem>()
            let selectedIndexArray =  makeRandomIndexArray((testXMLList?.count)!)
            for index in selectedIndexArray {
                testItemList?.append(testXMLList![index])
            }
            settingPageViewController()
            removeIndicator()
        }
        else {
            removeIndicator()
        }
    }
    
    func settingPageViewController() {
        // set pageviewcollor
        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(0)] as [TestItemViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        // set page controller
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    func showIndicator() {
        view.backgroundColor = UIColor.black
        
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.white
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = "Loading XML"
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        view.addSubview(boxView)
    }
    
    func removeIndicator(){
        boxView.removeFromSuperview()
        view.backgroundColor = UIColor.white
    }
    
    // for load & parsing XML
    func parseXMLFile() -> Bool {
        // load xml url
        //let urlpath:String="http://"
        //let url: NSURL = NSURL(string: urlpath)!
        
        // load xml file
        let urlpath = Bundle.main.path(forResource: "workbook", ofType: "xml")
        if urlpath == nil {
            NSLog("Failed to find workbook.xml")
            return false
        }
        let url = URL(fileURLWithPath: urlpath!)
        
        // parsing
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        return parser.parse()
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        if testXMLList == nil {
            testXMLList = Array<QuestionItem>()
        }else{
            testXMLList?.removeAll()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        curElement = elementName
        if curElement == "workbook" {
            testTitle = attributeDict ["subject"]! as String
        }
        else if curElement == "item" {
            if testXMLItem != nil {
                testXMLItem = nil
            }
            testXMLItem = QuestionItem()
            testXMLItem!.question_type = attributeDict ["type"]! as String
            testXMLItem!.user_answer = ""
            testXMLList!.append(testXMLItem!)
        }
        else if curElement == "answer" {
            curElementID = attributeDict ["id"]! as String
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if testXMLItem == nil {
            return
        }
        if curElement == "question" {
            testXMLItem!.question = string
        }
        else if curElement == "question_img" {
            testXMLItem!.question_img = string
        }
        else if curElement == "answer" {
            if testXMLItem!.answers == nil {
                testXMLItem!.answers = Dictionary<String,String>()
            }
            testXMLItem!.answers!.updateValue(string, forKey: curElementID)
        }
        else if curElement == "collect_answer" {
            testXMLItem!.collect_answer = string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        curElement = ""
        curElementID = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        curElement = ""
        curElementID = ""
        print("failure error: %@", parseError)
    }
    
    // for selecting questions randomly
    func makeRandomIndexArray(_ max: Int) -> Array<Int> {
        var indexArray = Array<Int>()
        while(indexArray.count < 5) {
            let value = Int(arc4random_uniform(UInt32(max)))
            if !indexArray.contains(value) {
                indexArray.append(value)
            }
        }
        return indexArray
    }
    
    // for page view controll
    func getViewControllerAtIndex(_ index: Int) -> TestItemViewController
    {
        let testItemViewController = storyboard!.instantiateViewController(withIdentifier: "TestItemViewController") as! TestItemViewController
        testItemViewController.testPageViewController = self
        testItemViewController.pageIndex = index
        testItemViewController.reviewState = reviewState
        testItemViewController.questionText = testItemList![index].question!
        testItemViewController.questionImg = testItemList![index].question_img!
        testItemViewController.answers = testItemList![index].answers!
        testItemViewController.collect_answer = testItemList![index].collect_answer!
        if reviewState {
            testItemViewController.user_answer = testItemList![index].user_answer!
        }
        
        return testItemViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let testItemController = viewController as! TestItemViewController
        var index = testItemController.pageIndex
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let testItemController = viewController as! TestItemViewController
        var index = testItemController.pageIndex
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == testItemList?.count {
            return nil
        }
        return getViewControllerAtIndex(index)
    }

    // for page controller
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return testItemList!.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func callResultViewController() {
        if let resultViewController = storyboard!.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultViewController.testItemList = testItemList!
            present(resultViewController, animated: true, completion: nil)
        }
    }
}
