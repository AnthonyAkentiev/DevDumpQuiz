//
//  StartController.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 13/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit

class StartController: UIViewController {
    @IBOutlet var lblTotalQuestion: UILabel!
    @IBOutlet var lblCorrect: UILabel!
    @IBOutlet var lblLevel: UILabel!
    @IBOutlet var lblTopic: UILabel!
    @IBOutlet var progress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStats()
    
        scheduleGoToQuestion()
    }
    
    func updateStats(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set all label texts:
        lblTotalQuestion.text = "Question: " + String(appDelegate.model.getQuestionIndex()) + "/" + String(appDelegate.model.getTotalQuestionsInRound())
        
        lblCorrect.text = "Сorrect: " + String(appDelegate.model.getCorrectAnswersInRound()) + "/" +
            String(appDelegate.model.getQuestionIndex())
        
        lblLevel.text = "Question level: " + (appDelegate.model.getQuestionLevel() as String) + "/10"
        lblTopic.text = "Question tags: " + (appDelegate.model.getQuestionTags() as String)
        
        var progressVal: Float =
        Float(appDelegate.model.getQuestionIndex() - 1) / Float(appDelegate.model.getTotalQuestionsInRound())
        
        progress.setProgress(progressVal, animated: false)
        
        // show/hide controls
        let currQuestion = appDelegate.model.getQuestionIndex()
        let totalQuestions = appDelegate.model.getTotalQuestionsInRound()
        
        if(currQuestion == totalQuestions + 1){
            // just show stats and Ok button
            lblLevel.hidden = true
            lblTopic.hidden = true
        }else{
            lblLevel.hidden = false
            lblTopic.hidden = false
        }
    }
    
    func scheduleGoToQuestion(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let currQuestion = appDelegate.model.getQuestionIndex()
        let totalQuestions = appDelegate.model.getTotalQuestionsInRound()
        
        if(currQuestion != totalQuestions + 1){
            // go to question
            var timer = NSTimer.scheduledTimerWithTimeInterval(
                NSTimeInterval(appDelegate.getParamInteger("WaitBeforeGoToQuestion")),
                target: self,
                selector: Selector("goToQuestion"),
                userInfo: nil,
                repeats: false)
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToQuestion(){
        performSegueWithIdentifier("goToQuestion",sender:self)
    }
    
}