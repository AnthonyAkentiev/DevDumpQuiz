//
//  Tags.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 21/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import Foundation

class Tags: NSObject {
    var totalTags = [String:Any]()
    var selectedTags = [String]()   // not indexes, but tag strings
    
    /////////////////////////
    func getTagsCount()->Int {
        return totalTags.count
    }
    
    func getTags()->[String:Any]{
        return totalTags
    }
    
    func getSelectedTags()->[String]{
        return selectedTags
    }
    
    func selectTagsWithIndexes(indexes:[Int]){
        // update selectedTags
        let tags:[String:Any] = getTags()
        let tagKeys = Array(tags.keys)
        
        // convert from index to String
        var result = [String]()
        for i in indexes {
            result.append(tagKeys[i])
        }
        selectedTags = result
        
        saveSelectedTagsToFile()
    }
    
    // only if selectedTags not empty!
    func selectAllTags(){
        if(selectedTags.count != 0){
            return
        }
        
        let tags:[String:Any] = getTags()
        let tagKeys = Array(tags.keys)
        
        // convert from index to String
        var result = [String]()
        for i in 0..<tagKeys.count {
            result.append(tagKeys[i])
        }
        
        selectedTags = result
        
        saveSelectedTagsToFile()
    }
    
    func isTagSelected(tagStr:String)->Bool{
        let result: [String] = selectedTags.filter{ $0 == tagStr }
        return (result.count != 0)
    }
    
    func saveSelectedTagsToFile(){
        let path1 = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        let path = NSURL(fileURLWithPath: path1).URLByAppendingPathComponent("tags.plist")
        
        //let path = path1.stringByAppendingPathComponent("tags.plist")
        
        let data = NSMutableDictionary()
        data.setObject(selectedTags, forKey: "tags")
        data.writeToURL(path, atomically: true)
    }
    
    func loadSelectedTagsFromFile(){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String

        let fullPath = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("tags.plist")
        
        let fullPathStr = "\(fullPath)"
        
        if(!NSFileManager.defaultManager().fileExistsAtPath(fullPathStr)){
            return
        }
        
        // read it and enumerate all questions
        // the format of that file 100% same as Q1.plist
        let myDict: NSDictionary? = NSDictionary(contentsOfFile: fullPathStr)
        let tagsArr: NSArray = myDict!.objectForKey("tags") as! NSArray
        
        selectedTags = tagsArr as! [String]
    }
    
    // Helpers:
    func isHasOneOfTheseTags(tags:[String], questionsTags:String)->Bool{
        let questionTagsSplit:[String] = questionsTags.componentsSeparatedByString(",")
        
        for tag in tags {
            for qTag in questionTagsSplit {
                let tagTrimmed = qTag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                if(tagTrimmed == tag){
                    return true
                }
            }
        }
        
        // do not add this question
        return false
    }
}