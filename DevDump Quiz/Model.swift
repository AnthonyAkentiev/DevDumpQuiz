//
//  Model.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 10/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    // Thank you stackoverflow for Knuth's shuffle in Swift
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    
    mutating func truncate(count:Int){
        let diff:Int = self.count - count
        if(diff<0){
            return
        }
        
        for _ in 0..<diff {
            self.removeLast()
        }
    }
}

class Model: QuestionsBase {    
    var isSwipeHelpShownQuestion: Bool = false
    var isAnswerEntered:Bool = false
    var userAnswered:[Int] = []   // starting from 1
    
    // Statistics:
    var questionIndex: Int = 0      // can be bigger than arr!
    var correctAnswers: Int = 0
    var totalQuestionsInRound: Int = 0 // question we have not already asked. see newRound
    
    // questionIndex -> realAppQuestionIndex
    // filled in fillQuestions (at the start of each round)
    // this is array of Question IDs
    var curRoundQuestionMap:[Int] = []
    
    enum GameType {
        case TwentyQuestions
        case Blitz
    }
    
    //////////////////////////////// METHODS:
    // Init all variables
    override init(){
        super.init()
        
        loadEverything()
    }
    
    func save(){
        saveVars()
    }
    
    func clearHistory(){
        // Single big Q1.plist file
        let dstPath = getQPath()
        
        var error:NSError?
        if(dstPath.checkResourceIsReachableAndReturnError(&error)){
            do {
                try NSFileManager.defaultManager().removeItemAtPath(dstPath.path!)
            } catch _ as NSError {
                // TODO: write error to log
                //err = error
            }
            
            loadEverything()
        }
    }
    
    func loadEverything(){
        // copy read-only Q1.plist to Documents/Q1.plist
        // + merge new downloaded Q files
        prepareQuestions()
        
        populateTotalTags()
        
        loadSelectedTagsFromFile()
        
        // isSwipeHelpShownQuestion and all other persistent variables
        loadVars()
    }

    // Statistics:
    func getTotalQuestionsInRound()->Int{
        return totalQuestionsInRound
    }
    
    func getCorrectAnswersInRound()->Int{
        return correctAnswers
    }
    
    ////////
    func getQuestionIndex()->Int{
        return questionIndex
    }
    
    func getQuestion()->String {
        return self.curQuestion
    }
    
    func getQuestionTags()->String {
        return curQuestionTags
    }
    
    func getQuestionLevel()->String{
        return curQuestionLevel
    }
    
    /// This is array of strings (not HTML)
    func getAnswers()->[String]{
        return curAnswers
    }
    
    func getCorrectAnswerIndexes()->[Int]{
        return curCorrectAnswerIndexes
    }
    
    // this is full HTML description
    func getAnswerDescByIndex(index:Int)->String{
        if(index >= self.curAnswersHtml.count){
            return ""
        }
        
        let c = self.curAnswersHtml[index].characters.count
        if(c==0){
            return ""
        }
        return self.curAnswersHtml[index]
    }
    
    // this is final correct answer (HTML)
    func getCorrectAnswerDesc()->String{
        return self.curCorrectAnswer
    }
    
    func setAnswerIndexes(indexes:[Int]){
        userAnswered = indexes
    }
    
    func getAnswerIndexes()->[Int]{
        return userAnswered
    }
    
    func setAnswerEntered(val:Bool){
        // remember answer and mark question as "already shown"
        assert(curQuestionID.characters.count != 0)
        
        let isCorrect = isCorrectAnswer()
        markQuestionAsAnsweredWithId(
            curQuestionID as String,
            andValue:true,
            andResult:isCorrect,
            andAnswers:userAnswered)
        
        if(isCorrect){
            correctAnswers++
        }
        
        isAnswerEntered = val
    }
    
    func isCorrectAnswer()->Bool{
        var correctSelected = 0
        
        var totalCorrectIndexes: [Int] = []
        
        // intersection
        for indx in curCorrectAnswerIndexes {
            if(indx != 0){
                totalCorrectIndexes.append(indx)
            }
            
            for answ in userAnswered {
                if(answ == indx){
                    correctSelected++
                }
            }
        }
        
        return (totalCorrectIndexes.count == correctSelected) && (correctSelected == userAnswered.count)
    }
    
    func getIsAnswerEntered()->Bool{
        return isAnswerEntered
    }
    
    func isRoundFinished()->Bool{
        let currQuestion = getQuestionIndex()
        let totalQuestions = getTotalQuestionsInRound()
        
        // currQuestion starts from 1
        // totalQuestions starts from 0
        return (currQuestion == totalQuestions)
    }

    func getTotalQuestions()->Int{
        return getTotalQuestionsCount()
    }
    
    func getTotalUnaskedQuestions()->Int{
        let unaskedQuestions:[Int] = getUnaskedQuestionsWithTags(selectedTags)
        return unaskedQuestions.count
    }
    
    //////////////////////////
    func loadVars(){
        let path: String = getPersistPath()
        
        // skip if no such file
        if(!NSFileManager.defaultManager().fileExistsAtPath(path)){
            return
        }
        
        let myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        isSwipeHelpShownQuestion = myDict!.objectForKey("isSwipeHelpShownQuestion") as! Bool
    }
    
    func saveVars(){
        let path: String = getPersistPath()
        
        let myDict: NSMutableDictionary? = NSMutableDictionary()
        myDict?.setObject(isSwipeHelpShownQuestion, forKey: "isSwipeHelpShownQuestion")
        
        // now save
        myDict!.writeToFile(path, atomically: true)
    }
    
    func getPersistPath()->String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
            
        let name = "Persist.plist"
        //let path = documentsDirectory.stringByAppendingPathComponent(name)
            
        let path = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent(name)
        let pathStr = "\(path)"
        
        return pathStr
    }
    
    func newRoundWithSelectedTags(tags:[String], andGameType:GameType)->Bool{
        correctAnswers = 0
        questionIndex = 0
        
        // TODO: game type?
        
        if(!fillQuestionsWithTags(tags)){
            return false
        }
        
        nextQuestion()
        
        return true
    }
    
    // will scan through ALL app questions and fill curRoundQuestionMap with fresh questions
    // that weren't asked yet
    private func fillQuestionsWithTags(tags:[String])->Bool{
        let unaskedQuestions:[Int] = getUnaskedQuestionsWithTags(tags)
        
        if(unaskedQuestions.count == 0){
            // no more questions...
            NSLog("No more questions...")
            return false
        }
        
        let randomQuestions:[Int] = randomizeArray(unaskedQuestions)
        assert(randomQuestions.count == unaskedQuestions.count)
        
        curRoundQuestionMap = randomQuestions
        curRoundQuestionMap.truncate(20)
        
        assert(curRoundQuestionMap.count<=20)
        
        totalQuestionsInRound = curRoundQuestionMap.count
        return true
    }
    
    private func randomizeArray(arr:[Int])->[Int]{
        var out = arr
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.getParamBool("IsRandomizeQuestions")){
            out.shuffle()
        }
        
        return out
    }
        
    func nextQuestion(){
        // reset
        isAnswerEntered = false
        userAnswered = []
        
        // random and that was not already asked
        selectNextQuestionIndex()
    
        loadQuestion()
    }
    
    func skipQuestion(){
        // remove question from array
        curRoundQuestionMap.removeAtIndex(questionIndex - 1)
        
        totalQuestionsInRound = curRoundQuestionMap.count
        
        // the questionIndex must be the same
        isAnswerEntered = false
        userAnswered = []
        
        loadQuestion()
    }
    
    func loadQuestion(){
        if(questionIndex-1 >= curRoundQuestionMap.count){
            // no more questions, stop
            return;
        }
        
        // load from file
        let realAppQuestionIndex: Int = mapQuestionIndex(questionIndex - 1)
        let q: NSDictionary = getQuestionWithId(realAppQuestionIndex)
        readQuestionFromDict(q)
    }
    
    //////////////////////////    
    private func selectNextQuestionIndex(){
        questionIndex++;
    }
    
    // questionIndex (in current round) -> realAppQuestionIndex (total app questions arr)
    private func mapQuestionIndex(questionIndex:Int)->Int{
        assert(questionIndex < curRoundQuestionMap.count)
        
        return curRoundQuestionMap[questionIndex]
    }
}