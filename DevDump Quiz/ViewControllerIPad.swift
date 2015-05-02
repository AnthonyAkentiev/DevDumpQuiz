//
//  ViewControllerIPad.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 24/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit

// This is all-in-one controller for iPad only
class ViewControllerIPad: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var lblTotalQuestion: UITextField!
    @IBOutlet var lblCorrect: UITextField!
    @IBOutlet var lblLevel: UITextField!
    @IBOutlet var lblTopic: UITextField!
    
    @IBOutlet var progress: UIProgressView!
    
    @IBOutlet var view1: UIWebView!
    
    // WARNING: optionals! We can remove this controls in Storyboard (prototyping) and still be happy
    @IBOutlet var view2: UIWebView?
    @IBOutlet var tableView: UITableView?
    
    @IBOutlet var lblOne: UILabel?
    @IBOutlet var lblTwo: UILabel?
    @IBOutlet var lblThree: UILabel?
    @IBOutlet var lblFour: UILabel?
    
    @IBOutlet var btnSkip: UIButton!
    @IBOutlet var btnOk: UIButton!
    
    // 
    let cellBackgroundColor = UIColor.lightGrayColor()
    let cellTextColor = UIColor.blackColor()
    
    let cellHighlightBackgroundColor = UIColor.lightGrayColor()
    let cellHighlightTextColor = UIColor.whiteColor()
    
    //
    var items: [String] = []
    var correctAnswers: [Int] = []    // starting from 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        
        // update controls
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.getIsAnswerEntered()){
            // this happens when we move back from question to this controller
        }else{
            // disable button until user clicks on answer (in table)
            btnOk.enabled = false
        }
        
        initLabels()
        
        showAndHideControls()
    }
    
    func showAndHideControls(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var showTable = appDelegate.getParamBool("IpadShowTableForAnswers")
        
        var labels = [lblOne, lblTwo, lblThree, lblFour]
        for l in labels {
            l?.hidden = showTable
        }
        tableView?.hidden = !showTable
    }
 
    func load(){
        loadQuestion()
        
        loadAnswers()
        
        updateStats()
        
        loadAnswerHtmlFromString("")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadQuestion(){
        loadHtml()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.getIsAnswerEntered()){
            // disable 'skip' button
            btnSkip!.enabled = false
        }
    }
    
    @IBAction func onSkip(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // check if that is last question and go to goToStart
        if(appDelegate.model.isRoundFinished()){
            appDelegate.model.skipQuestion()
            
            performSegueWithIdentifier("goToStart",sender:self)
            return
        }else{
            appDelegate.model.skipQuestion()
        }
        
        // reload everything
        load()
    }
    
    @IBAction func onOk(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // user opened us from Correct Answer controller? And wants to move back? Ok
        if(appDelegate.model.getIsAnswerEntered()){
            onMoveToCorrectAnswer()
        }else{
            onAnswerEntered()
        }
    }
    
    func onMoveToCorrectAnswer(){
        performSegueWithIdentifier("goToCorrectAnswer",sender:self)
    }
    
    // User selected answer and clicked on OK button
    func onAnswerEntered(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // 1 - update controls
        highlightGoodAnswer()
        btnOk.enabled = false
        
        // 2 - update model
        appDelegate.model.setAnswerEntered(true)
        
        // 3 - move to next view controller
        var timer = NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(appDelegate.getParamInteger("WaitBeforeAnswer")),
            target: self,
            selector: Selector("goToCorrectAnswer"),
            userInfo: nil,
            repeats: false)
    }
    
    func highlightGoodAnswer(){
        for answ in correctAnswers {
            var path:NSIndexPath = NSIndexPath(forRow: (answ - 1), inSection: 0)
            
            var selectedCell:UITableViewCell? = tableView?.cellForRowAtIndexPath(path)
            selectedCell?.textLabel!.textColor = UIColor.blueColor()
            selectedCell?.detailTextLabel!.textColor = UIColor.blueColor()
        }
    }
    
    func goToCorrectAnswer(){
        // correct answer is already selected in 'didSelectRowAtIndexPath' method
        performSegueWithIdentifier("goToCorrectAnswer",sender:self)
    }
    
    func loadHtml(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var htmlString:String = appDelegate.model.getQuestion() as String
        
        view1.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func updateStats(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set all label texts:
        lblTotalQuestion.text = String(appDelegate.model.getQuestionIndex()) + "/" + String(appDelegate.model.getTotalQuestionsInRound())
        
        lblCorrect.text = String(appDelegate.model.getCorrectAnswersInRound()) + "/" +
            String(appDelegate.model.getQuestionIndex())
        
        lblLevel.text = (appDelegate.model.getQuestionLevel() as String) + "/10"
        lblTopic.text = (appDelegate.model.getQuestionTags() as String)
        
        var progressVal: Float =
        Float(appDelegate.model.getQuestionIndex() - 1) / Float(appDelegate.model.getTotalQuestionsInRound())
        
        progress!.setProgress(progressVal, animated: false)
    }
    
    func loadAnswers(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        items = appDelegate.model.getAnswers()
        
        correctAnswers = appDelegate.model.getCorrectAnswerIndexes()
        
        // optional
        tableView?.reloadData()
        
        // optional
        lblOne?.text = " " + items[0]
        lblTwo?.text = " " + items[1]
        if(items.count>2){
            lblThree?.text = " " + items[2]
        }
        if(items.count>3){
            lblFour?.text = " " + items[3]
        }
        
        // clear highlighting
        highlightLabel(-1)
    }
    
    ///
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
        if(appDelegate.model.getIsAnswerEntered()){
            cell.textLabel!.textColor = UIColor.blueColor()
            cell.detailTextLabel!.textColor = UIColor.blueColor()
            
            for answ in correctAnswers {
                if(indexPath.row + 1==answ){
                    cell.textLabel!.textColor = UIColor.blueColor()
                    cell.detailTextLabel!.textColor = UIColor.blueColor()
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectAnswer(indexPath.row)
    }
    
    @IBAction func onBtnOne(){
        selectAnswer(0)
    }
    
    @IBAction func onBtnTwo(){
        selectAnswer(1)
    }
    
    @IBAction func onBtnThree(){
        selectAnswer(2)
    }
    
    @IBAction func onBtnFour(){
        selectAnswer(3)
    }
    
    func selectAnswer(index:Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set user selection
        if(!appDelegate.model.getIsAnswerEntered()){
            // TODO:
            var indexes:[Int] = []
            indexes.append(index + 1)
            
            appDelegate.model.setAnswerIndexes(indexes)
        }
        
        let htmlAnswerDesc:String = appDelegate.model.getAnswerDescByIndex(index)
        loadAnswerHtmlFromString(htmlAnswerDesc)
        
        btnOk.enabled = true
        
        // select label
        highlightLabel(index)
    }
    
    func initLabels(){
        var labels = [
            lblOne, lblTwo, lblThree, lblFour
        ]
        var selectors = [
            "onBtnOne","onBtnTwo","onBtnThree","onBtnFour"
        ]
        
        var i = 0
        
        for lbl in labels {
            lbl?.userInteractionEnabled = true
            
            var recognizer = UITapGestureRecognizer(target: self, action: Selector(selectors[i]))
            recognizer.numberOfTapsRequired = 1
            recognizer.cancelsTouchesInView = true
            
            lbl?.backgroundColor = cellBackgroundColor
            lbl?.textColor = cellTextColor
            
            lbl?.addGestureRecognizer(recognizer)
            i++
        }
    }
    
    func highlightLabel(index:Int){
        var lbl:UILabel?
        
        if(index == 0){
            lbl = lblOne
        }else if(index == 1){
            lbl = lblTwo
        }else if(index == 2){
            lbl = lblThree
        }else if(index == 3){
            lbl = lblFour
        }
        
        // Clear cell highlight
        var originalFont = UIFont.systemFontOfSize(17.0)
        var labels = [lblOne, lblTwo, lblThree, lblFour]
        
        for l in labels {
            l?.font = originalFont
            l?.backgroundColor = cellBackgroundColor
            l?.textColor = cellTextColor
        }
        
        // Highlight:
        if(index != -1){
            var boldFont = UIFont.boldSystemFontOfSize(17.0)
            
            //boldSystemFontOfSize:[UIFont systemFontSize]];
            //lbl?.shadowColor = UIColor.blueColor()
            //lbl?.shadowOffset = CGSize(width: 3, height: 3)
            lbl?.highlighted = true
            lbl?.font = boldFont
            
            lbl?.textColor = cellHighlightTextColor
            lbl?.backgroundColor = cellHighlightBackgroundColor
        }
    }
    
    func loadAnswerHtmlFromString(s:String){
        view2?.loadHTMLString(s as String, baseURL: nil)
    }
}



