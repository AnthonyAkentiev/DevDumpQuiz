//
//  MainMenu.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 10/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit


class MainMenu: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var buttonStart: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textQuestions: UITextField!
    
    // This is optional (only for iPad)
    @IBOutlet var textTotalQuestions: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        // select all tags (only first time)!
        appDelegate.model.selectAllTags()
        
        updateStats()
    }
    
    override func viewWillAppear(animated: Bool){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.model.populateTotalTags()
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStartGame(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Let's go!
        var tags: [String] = appDelegate.model.getSelectedTags()
        var gameType: Model.GameType = Model.GameType.TwentyQuestions
        
        if(!appDelegate.model.newRoundWithSelectedTags(tags, andGameType:gameType)){
            // TODO: no more questions...
            
        }else{
            performSegueWithIdentifier("startGame",sender:self)
        }
    }
    
    /////////// TABLE VIEW stuff goes here:
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tags"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var tagsCount:Int = appDelegate.model.getTagsCount()
        
        return tagsCount
    }
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75;
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let tags:[String:Any] = appDelegate.model.getTags()
        let tagKeys = tags.keys.array
        
        var tagStr = tagKeys[indexPath.row]
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        
            //= tableView.dequeueReusableCellWithIdentifier("SimpleCell") as! UITableViewCell
        cell.textLabel?.text = tagStr
        
        var tuple = tags[tagStr] as! NSDictionary
        var cnt:Int = tuple["Count"] as! Int
        var asked:Int = tuple["Asked"] as! Int
        
        var completeStr = "\(asked)/\(cnt) complete"
        
        cell.detailTextLabel?.text = completeStr
        cell.detailTextLabel?.numberOfLines = 1
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // if tag is selected by user
        var checked = appDelegate.model.isTagSelected(tagStr)
        
        if(checked){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // toggle checkbox
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if(cell.accessoryType == UITableViewCellAccessoryType.None){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        // update view
        var checked: [NSIndexPath] = getAllCheckedCells()
        var rows = [Int]()
        for s in checked {
            rows.append(s.row)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.model.selectTagsWithIndexes(rows)
        
        updateStats()
    }
    
    func updateStats(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // total questions:
        textQuestions.text = String(appDelegate.model.getTotalUnaskedQuestions())
        
        textTotalQuestions?.text = String(appDelegate.model.getTotalQuestions())
        
        // button text:
        var cnt = appDelegate.model.getTotalUnaskedQuestions()
        if(cnt > 20){
            cnt = 20
        }
        
        buttonStart.setTitle("Start \(cnt) random questions round", forState: UIControlState.Normal)

        buttonStart.enabled = (cnt != 0)
    }
    
    func getAllCheckedCells()->[NSIndexPath]{
        var out: [NSIndexPath] = [NSIndexPath]()
        
        var cnt = tableView.numberOfRowsInSection(0)
        for i in 0..<cnt {
            var indexPath: NSIndexPath = NSIndexPath(forItem: i, inSection: 0)
            
            var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            if(cell.accessoryType == UITableViewCellAccessoryType.Checkmark){
                out.append(indexPath)
            }
        }
        
        return out
    }
    
}
