//
//  ResultViewController.swift
//  Assignment
//
//  Created by Mac on 2016. 7. 23..
//  Copyright © 2016년 Hosung. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let reuseIdentifier = "resultCollectionViewCell"
    var testItemList : Array<QuestionItem> = Array<QuestionItem>()
    
    @IBOutlet weak var titleViewLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    
    var testScore : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleViewLabel.text = "Test Result"
        testScore = 0
        evaluationLabel.text = ""
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testItemList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ResultCollectionViewCell
        
        cell.numberLabel.text = String(indexPath.item + 1)
        
        if testItemList[indexPath.item].collect_answer == testItemList[indexPath.item].user_answer {
            cell.resultImage.image = UIImage(named: "right")
            testScore += 1
        } else {
            cell.resultImage.image = UIImage(named: "wrong")
        }
        
        if indexPath.item + 1 == testItemList.count {
            scoreLabel.text = "Score: \(testScore)/5"
            if testScore == 5 {
                evaluationLabel.text = "You Are A Genius!"
            }
            else if testScore == 4 {
                evaluationLabel.text = "Excellent Work!"
            }
            else if testScore == 3 {
                evaluationLabel.text = "Good Job!"
            }
            else if testScore < 3 {
                evaluationLabel.text = "Please Try Again!"
            }
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TestReview" {
            let testPageViewController = segue.destinationViewController as! TestPageViewController
            testPageViewController.reviewState = true
            testPageViewController.testItemList = testItemList
        }
    }
}
