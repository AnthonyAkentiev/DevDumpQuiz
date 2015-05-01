//
//  QuestionsBase.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 15/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import Foundation
import UIKit

func prepareHtml(html:String)->String{
    // 1 - load stub
    let path = NSBundle.mainBundle().pathForResource("stub_basic_langs", ofType: "html")
    var text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
    
    var out:String = text.stringByReplacingOccurrencesOfString("INSERT_HERE",withString:html as String)
    return out
}

class QuestionsBase: Tags {
    // Per Round:
    var curQuestionID: String = ""
    
    var curQuestion:String = ""
    var curAnswers:[String] = []
    var curAnswersHtml:[String] = []
    var curQuestionTags:String = ""
    var curQuestionLevel:String = ""
    var curCorrectAnswerIndex:Int = 0 // starting from 1
    var curCorrectAnswer:String = ""
    
    //////////////////////////////////////////////////////////////////
    // Read-only src plist file from Bundle
    func getInternalQPath()->String{
        let srcPath: String = NSBundle.mainBundle().pathForResource("Q1", ofType: "plist")!
        return srcPath
    }
    
    // Read-write plist file 
    // All questions is merged into it
    func getQPath()->String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
        
        let name = "Q1.plist"
        let path = documentsDirectory.stringByAppendingPathComponent(name)
        
        return path
    }
    
    func prepareQuestions(){
        // this will copy
        makeInternalQuestionsCopy()
        
        // check if everything is OK
        let dstPath = getQPath()
        assert(NSFileManager.defaultManager().fileExistsAtPath(dstPath))
        
        // In debug - manually copy Additional Questions (in-app-purchases)
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //if(appDelegate.getParamBool("DEBUG_CopyAQs")){
        if(true){
            copyAdditionalQuestionsToDocuments()
        }
        
        // merge new (in-app-purchased) questions in Documents/Q1.plist
        mergeNewQuestions()
        
        // run to prevent problems!
        assert(checkIdCollisions())
    }
    
    func copyAdditionalQuestionsToDocuments(){
        // 1 - enumerate each in-app-purchased file with questions
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        
        // TODO: manually update this list for debug
        var aqs = [
            "AQ1",
            "AQ2"
        ]
        
        for aq in aqs {
            let srcPath: String = NSBundle.mainBundle().pathForResource(aq, ofType: "plist")!
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as! String
            let dstPath = documentsDirectory.stringByAppendingPathComponent(aq + ".ext")
            
            assert(NSFileManager.defaultManager().fileExistsAtPath(srcPath))
            
            if(!NSFileManager.defaultManager().fileExistsAtPath(dstPath)){
                // copy
                NSLog("Copy additional questions: \(srcPath) file to \(dstPath)")
                
                var err: NSError?
                if(NSFileManager.defaultManager().copyItemAtPath(srcPath, toPath: dstPath, error: &err)){
                
                }
            }
        }
    }
    
    // scan all ids and check for collisions
    func checkIdCollisions()->Bool{
        let path = getQPath()
        var myDict: NSDictionary? = NSDictionary(contentsOfFile: path)
        
        var questionsArr: NSArray = myDict!.objectForKey("questions") as! NSArray
        var qIdsMap = [String:Bool]()
        
        // scan all questions and find one with (Id == id)
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            
            let qId: String = q.objectForKey("Id") as! String
            
            if let boolHere = qIdsMap[qId] {
                return false
            }else {
                qIdsMap[qId] = true
            }
        }
        
        // OK
        return true
    }
    
    // Copy from read-only plist to Documents folder
    func makeInternalQuestionsCopy(){
        let srcPath = getInternalQPath()
        let dstPath = getQPath()
        
        // check if already exists and do not copy in this case
        if(!NSFileManager.defaultManager().fileExistsAtPath(dstPath)){
            // copy
            NSLog("Copy \(srcPath) file to \(dstPath)")
            
            var myDict: NSDictionary? = NSDictionary(contentsOfFile: srcPath)
            myDict!.writeToFile(dstPath, atomically: false)
        }
    }
  
    func mergeNewQuestions(){
        // 1 - enumerate each in-app-purchased file with questions
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
        
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(documentsDirectory)!
        
        while let f = enumerator.nextObject() as? String {
            if f.hasSuffix("ext") { // checks the extension
                // 2 - for each question in this file - merge it into destination
                mergeNewQuestionsFile(f)
            }
        }
    }
    
    // this is additional file that is downloaded on demand when user 
    // makes in-app-purchase
    func mergeNewQuestionsFile(fileName:String){
        // read plist file
        NSLog("Reading additional file: \(fileName)")
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
        let fullPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        
        // read it and enumerate all questions
        // the format of that file 100% same as Q1.plist
        var myDict: NSDictionary? = NSDictionary(contentsOfFile: fullPath)
        
        var questionsArr: NSArray = myDict!.objectForKey("questions") as! NSArray
        var qIdsMap = [String:Bool]()
        
        // scan all questions and find one with (Id == id)
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            
            let qId: String = q.objectForKey("Id") as! String
            
            if(isNewQuestionWithId(qId)){
                // add it to Documents/Q1.plist
                addNewQuestionFromExtension(q)
                
                // check that we added it
                assert(!isNewQuestionWithId(qId))
            }
        }
    }
    
    func isNewQuestionWithId(id:String)->Bool{
        // scan all questions in Documents/Q1.plist
        let path = getQPath()
        var myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        var questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        let countBefore = questionsArr.count
        
        // scan all questions and find one with (Id == id)
        var index: Int = -1
        
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            
            var qId: String = q.objectForKey("Id") as! String
            if(qId==id){
                // already in Q1.plist
                return false
            }
        }
        
        return true
    }
    
    func addNewQuestionFromExtension(q:NSDictionary){
        var qId: String = q.objectForKey("Id") as! String
        NSLog("New question: \(qId). Adding to list")
        
        let path = getQPath()
        var myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        var questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        
        questionsArr.insertObject(q, atIndex: 0)
        myDict!.setObject(questionsArr, forKey: "questions")
        
        // now save
        myDict!.writeToFile(path, atomically: true)
    }
    
    // Search in Documents/Q1.plist file
    func getQuestionWithId(id: Int)->NSDictionary{
        let path = getQPath()
        var myDict: NSDictionary? = NSDictionary(contentsOfFile: path)
        
        var questionsArr: NSArray = myDict!.objectForKey("questions") as! NSArray
        
        // scan all questions and find one with (Id == id)
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            
            var qId: String = q.objectForKey("Id") as! String
            if(qId.toInt() == id){
                return q
            }
        }
        
        // not found?
        return NSDictionary()
    }
    
    // Update Q1.plist file - replace question
    func updateQuestionWithId(id: Int, andValue:NSDictionary){
        let path = getQPath()
        var myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        var questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        let countBefore = questionsArr.count
        
        // scan all questions and find one with (Id == id)
        var index: Int = -1
        
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            
            var qId: String = q.objectForKey("Id") as! String
            if(qId.toInt() == id){
                index = i
            }
        }
        
        questionsArr.replaceObjectAtIndex(index, withObject: andValue)
        assert(questionsArr.count == countBefore)
        
        // now save
        myDict!.setObject(questionsArr, forKey: "questions")
        myDict!.writeToFile(path, atomically: true)
        
        // Assert
        var tstDict: NSDictionary = getQuestionWithId(id)
        var isAsked: Bool = tstDict.objectForKey("IsAsked") as! Bool
        assert(isAsked == true)
    }
    
    func readQuestionFromDict(dict:NSDictionary){
        var id: String = dict.objectForKey("Id") as! String
        var q: String = dict.objectForKey("q") as! String
        var a: String = dict.objectForKey("a") as! String
        var tags: String = dict.objectForKey("Tags") as! String
        var level: String = dict.objectForKey("Level") as! String
        var correctAnswer: Int = dict.objectForKey("Correct Answer") as! Int
        
        // Unique app ID (different questions from different files should not collide)
        curQuestionID = id
        
        curQuestionTags = tags
        curQuestionLevel = level
        curCorrectAnswerIndex = correctAnswer
        
        curQuestion = prepareHtml(q)
        curCorrectAnswer = prepareHtml(a)
        
        var answers: NSArray = dict.objectForKey("answers") as! NSArray
        curAnswers = answers as AnyObject as! [String]
        
        // each answer could have separate html text for help (optional)
        if let answersHtml = dict["answers_html"] as? NSArray {
            curAnswersHtml = answersHtml as AnyObject as! [String]
        }else{
            curAnswersHtml = []
        }
    }
    
    // When user answer the question - we mark it with "IsAsked" and "Answered" 
    func markQuestionAsAnsweredWithId(id:String, andResult:Bool, andAnswer:Int){
        NSLog("User answered question \(id) with result: \(andResult)")
        
        // get q object from plist in Documents
        var q: NSMutableDictionary = getQuestionWithId(id.toInt()!) as! NSMutableDictionary
        var ID: String = q.objectForKey("Id") as! String
        assert(ID==id)
        
        q.setObject(true, forKey: "IsAsked")
        q.setObject(andAnswer, forKey: "Answered")
        
        // save to read/write plist file
        updateQuestionWithId(id.toInt()!, andValue:q)
    }

    func getTotalQuestionsCount()->Int{
        let path = getQPath()
        let myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        let questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        return questionsArr.count
    }
    
    // find all unasked questions with such tags
    func getUnaskedQuestionsWithTags(tags:[String])->[Int]{
        var out: [Int] = []
        
        // iterate through all questions and select ones with same 'tag'
        let path = getQPath()
        var myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        var questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        let countBefore = questionsArr.count
        
        // is skip?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let isSkipAlreadyAsked: Bool = appDelegate.getParamBool("IsSkipAsked")
        
        // scan all questions and find one with (Id == id)
        var index: Int = -1
        
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            var qId: String = q.objectForKey("Id") as! String
            
            // Skip it?
            var skipQuestion: Bool = false
            if let isAsked = q.objectForKey("IsAsked") as? Bool {
                if(isSkipAlreadyAsked && isAsked){
                   skipQuestion = true
                }
            }
            
            if(!skipQuestion){
                var strTags: String = q.objectForKey("Tags") as! String
                if(isHasOneOfTheseTags(tags,questionsTags:strTags) == true){
                    out.insert(qId.toInt()!, atIndex: 0)
                }
            }
        }
        
        return out
    }
    
    // iterate through all questions and select ones with same 'tag'
    func populateTotalTags(){
        let path = getQPath()
        var myDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: path)
        
        var questionsArr: NSMutableArray = myDict!.objectForKey("questions") as! NSMutableArray
        
        totalTags = [String:Any]()
        
        for i in 0...questionsArr.count - 1 {
            var q: NSDictionary = questionsArr.objectAtIndex(i) as! NSDictionary
            var strTags: String = q.objectForKey("Tags") as! String
            
            let questionTagsSplit:[String] = strTags.componentsSeparatedByString(",")
            
            // process each tag from each question
            for tag:String in questionTagsSplit {
                var isAskedCount = isQuestionWasAsked(q)
                
                totalTags = updateTotalTags(totalTags,tag:tag,isAskedCount:isAskedCount)
            }
        }
        
        NSLog("Total tags: \(totalTags.count)")
    }
    
    private func isQuestionWasAsked(q:NSDictionary)->Int{
        // this is optional field in dictionary
        if let isAsked = q.objectForKey("IsAsked") as? Bool {
            if(isAsked){
                return 1
            }
        }
        
        return 0
    }
    
    private func updateTotalTags(totalTags:[String:Any], tag:String, isAskedCount:Int)->[String:Any]{
        var tagTrimmed = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // copy ((
        var out = totalTags
        
        if let cnt = out[tagTrimmed] {
            var tuple = out[tagTrimmed] as! NSDictionary
            var cnt:Int = tuple["Count"] as! Int
            var asked:Int = tuple["Asked"] as! Int
            
            out[tagTrimmed] = ["Count": cnt + 1, "Asked":asked + isAskedCount]
        }else{
            out[tagTrimmed] = ["Count":1, "Asked":isAskedCount]
        }
        
        return out
    }
}