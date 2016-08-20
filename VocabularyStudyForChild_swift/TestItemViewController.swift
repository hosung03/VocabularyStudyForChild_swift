//
//  TestItemViewController.swift
//  XMLParsing
//
//  Created by Mac on 2016. 7. 18..
//  Copyright © 2016년 Hosung. All rights reserved.
//

import UIKit

class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topPosition = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topPosition = max(0, topPosition)
            contentInset = UIEdgeInsets(top: topPosition, left: 0, bottom: 0, right: 0)
        }
    }
}

class TestItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var testPageViewController: TestPageViewController?
    var reviewState: Bool = false
    var pageIndex: Int = 0
    var questionText: String = "" {
        didSet {
            if let textView = itemTextView {
                textView.text = questionText
            }
        }
    }
    var questionImg: String = "" {
        didSet {
            if let imageView = itemImageView {
                let urlpath = NSBundle.mainBundle().pathForResource(questionImg, ofType: "png")
                if urlpath == nil {
                    return
                }
                if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: urlpath!)) {
                    imageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    var answers = Dictionary<String,String>?()
    var collect_answer: String = ""
    var user_answer: String = ""
    var selectedSection : Int = -1
    var selectedRow : Int = -1

    let testItemIdentifier = "TestItemIdentifier"
    
    @IBOutlet weak var itemTextView: VerticallyCenteredTextView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var goTestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTitleLabel!.text = "Question " + String(pageIndex + 1)
        itemTextView!.text = questionText
        if reviewState {
            goTestButton.hidden = false
        }
        else {
            goTestButton.hidden = true
        }

        let urlpath = NSBundle.mainBundle().pathForResource(questionImg, ofType: "png")
        if urlpath == nil {
            return
        }
        if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: urlpath!)) {
             itemImageView!.image = UIImage(data: imageData)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (answers!.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(testItemIdentifier) as UITableViewCell?
        if (cell == nil) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: testItemIdentifier)
        }
        
        cell!.textLabel?.text = answers![String(indexPath.row + 1)]
        if reviewState && String(indexPath.row + 1) == user_answer {
            cell!.imageView?.image = UIImage(named: "ic_check_box")
        }
        else if selectedSection == indexPath.section && selectedRow == indexPath.row {
            cell!.imageView?.image = UIImage(named: "ic_check_box")
        } else {
            cell!.imageView?.image = UIImage(named: "ic_uncheck_box")
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedSection = indexPath.section
        selectedRow = indexPath.row
        
        for i in 0...tableView.numberOfSections-1
        {
            for j in 0...tableView.numberOfRowsInSection(i)-1
            {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    if selectedSection == i && selectedRow == j {
                        cell.imageView?.image = UIImage(named: "ic_check_box")
                    } else {
                        cell.imageView?.image = UIImage(named: "ic_uncheck_box")
                    }
                }
            }
        }
        testPageViewController!.testItemList![pageIndex].user_answer = String(indexPath.row +  1)
        
        if pageIndex + 1 == testPageViewController!.testItemList!.count {
            let controller = UIAlertController(title: "Answer", message: "You want to get a result!", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in self.testPageViewController!.callResultViewController()
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            
            controller.addAction(yesAction)
            controller.addAction(noAction)
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoTest" {
            let testPageViewController = segue.destinationViewController as! TestPageViewController
            testPageViewController.reviewState = false
        }
    }
}
