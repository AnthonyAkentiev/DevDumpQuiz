//
//  CorrectAnswerView.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 10/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit

class CorrectAnswerController: UIViewController {
    @IBOutlet var lblIsCorrect:UILabel!
    @IBOutlet var webView: UIWebView!
    
    // optional (only for iPad controller)
    @IBOutlet var lblTotalQuestion: UITextField?
    @IBOutlet var lblCorrect: UITextField?
    @IBOutlet var lblLevel: UITextField?
    @IBOutlet var lblTopic: UITextField?
    
    @IBOutlet var progress: UIProgressView?

    ////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStats()
        
        // is Correct?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.isCorrectAnswer()){
            lblIsCorrect.text = "Correct!"
        }else{
            lblIsCorrect.text = "Wrong answer..."
        }
        
        lblIsCorrect.textColor = UIColor.redColor()
        
        // update correct answer desc
        let s:String = appDelegate.model.getCorrectAnswerDesc()
        loadHtmlFromString(s)
    }
    
    // Dealing with optional members
    func updateStats(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set all label texts:
        lblTotalQuestion?.text = String(appDelegate.model.getQuestionIndex()) + "/" + String(appDelegate.model.getTotalQuestionsInRound())
        
        lblCorrect?.text = String(appDelegate.model.getCorrectAnswersInRound()) + "/" +
            String(appDelegate.model.getQuestionIndex())
        
        lblLevel?.text = (appDelegate.model.getQuestionLevel() as String) + "/5"
        lblTopic?.text = (appDelegate.model.getQuestionTags() as String)
        
        let progressVal: Float =
        Float(appDelegate.model.getQuestionIndex() - 1) / Float(appDelegate.model.getTotalQuestionsInRound())
        
        progress?.setProgress(progressVal, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNextQuestion(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if(appDelegate.model.isRoundFinished()){
            NSLog("Finished round")
            
            performSegueWithIdentifier("goToScore",sender:self)
            return
        }
        
        // will select next question if something left
        appDelegate.model.nextQuestion()
        
        performSegueWithIdentifier("nextQuestion",sender:self)
    }
    
    // 
    private func loadHtmlFromString(s:String){
        webView.loadHTMLString(s as String, baseURL: nil)
    }
    
    // move back to check answers/question
    @IBAction func onSwipe(){
        performSegueWithIdentifier("backToAnswers",sender:self)
    }

}