//
//  AnswerController.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 10/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit

class AnswerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var webView: UIWebView?
    @IBOutlet var btnOk: UIButton!
    
    var items: [String] = []
    // starting from 1
    var correctAnswer: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.flashScrollIndicators()
    
        // load data from model
        loadAnswers()
        
        // disable selection - but show user correct answer and the one he selected
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        btnOk.enabled = !appDelegate.model.getIsAnswerEntered()
        
        // select
        if(appDelegate.model.getAnswerIndex() != 0){
            var row:Int = appDelegate.model.getAnswerIndex() - 1
            var path:NSIndexPath = NSIndexPath(forRow: row, inSection: 0)
            
            tableView.selectRowAtIndexPath(
                path,
                animated: false,
                scrollPosition: UITableViewScrollPosition.None)
            
            let htmlAnswerDesc:String = appDelegate.model.getAnswerDescByIndex(row)
            loadHtmlFromString(htmlAnswerDesc)
        }else{
            // required to fix bug with no-swipe
            loadHtmlFromString("")
        }
    }
    
    func loadAnswers(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        items = appDelegate.model.getAnswers()
        
        correctAnswer = appDelegate.model.getCorrectAnswerIndex()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwipeLeft(){
        performSegueWithIdentifier("showQuestionsPanel",sender:self)
    }
    
    @IBAction func onSwipeRight(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.getIsAnswerEntered()){
            performSegueWithIdentifier("goToCorrectAnswer",sender:self)
        }
    }
    
    @IBAction func onOk(){
        assert(correctAnswer>0)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // highlight good answer
        highlightGoodAnswer()
        
        //selectedCell.contentView.backgroundColor = UIColor.redColor()
        
        // user finished answering this question
        appDelegate.model.setAnswerEntered(true)
        
        // hide Ok button
        btnOk.enabled = false
        
        // add little timer!
        var timer = NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(appDelegate.getParamInteger("WaitBeforeAnswer")),
            target: self,
            selector: Selector("moveToCorrectAnswer"),
            userInfo: nil,
            repeats: false)
    }
    
    func highlightGoodAnswer(){
        var path:NSIndexPath = NSIndexPath(forRow: (correctAnswer - 1), inSection: 0)
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(path)!
        selectedCell.textLabel!.textColor = UIColor.blueColor()
        selectedCell.detailTextLabel!.textColor = UIColor.blueColor()
    }
    
    func moveToCorrectAnswer(){
        // correct answer is already selected in 'didSelectRowAtIndexPath' method
    
        performSegueWithIdentifier("goToCorrectAnswer",sender:self)
    }
    
    /////////// TABLE VIEW stuff goes here:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = String(indexPath.row + 1)
        
        cell.detailTextLabel?.text = self.items[indexPath.row] as String
        cell.detailTextLabel?.numberOfLines = 3
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // highlight if "already answered" mode
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.getIsAnswerEntered() && (indexPath.row + 1==appDelegate.model.getCorrectAnswerIndex())){
            cell.textLabel!.textColor = UIColor.blueColor()
            cell.detailTextLabel!.textColor = UIColor.blueColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set user selection
        if(!appDelegate.model.getIsAnswerEntered()){
            appDelegate.model.setAnswerIndex(indexPath.row + 1)
        }
        
        let htmlAnswerDesc:String = appDelegate.model.getAnswerDescByIndex(indexPath.row)
        loadHtmlFromString(htmlAnswerDesc)
    }
    
    /////////////////////
    func loadHtmlFromString(s:String){
        webView?.loadHTMLString(s as String, baseURL: nil)
    }
}



