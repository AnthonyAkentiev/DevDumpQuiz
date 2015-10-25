import UIKit

class ViewController: UIViewController {
    @IBOutlet var view1: UIWebView!
    @IBOutlet var btnSkip: UIButton!
    
    @IBOutlet var lblSwipe: UILabel?
    @IBOutlet var imgSwipeHand: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // this var is saved to plist file
        if(appDelegate.model.isSwipeHelpShownQuestion){
            // hide "Swipe" (help) label if it was already shown...
            lblSwipe?.hidden = true
            imgSwipeHand?.hidden = true
        }else{
            //view1!.hidden = true
            
            // hide it after little time
            NSTimer.scheduledTimerWithTimeInterval(
                NSTimeInterval(appDelegate.getParamInteger("WaitBeforeHideSwipeLabel")),
                target: self,
                selector: Selector("hideSwipeLabel"),
                userInfo: nil,
                repeats: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onGiveAnswerClicked(){
        performSegueWithIdentifier("showAnswersPanel",sender:self)
    }
    
    @IBAction func onSwipeRight(){
        performSegueWithIdentifier("showAnswersPanel",sender:self)
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
        
        // reload question
        load()
    }
    
    ///////////////////
    func load(){
        loadHtml()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.model.getIsAnswerEntered()){
            // disable 'skip' button
            btnSkip.enabled = false
        }
    }
    
    func loadHtml(){
        //let myURL = NSBundle.mainBundle().URLForResource("question1", withExtension: "html")
        //let requestObj = NSURLRequest(URL: myURL!)
        //view1.loadRequest(requestObj)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let htmlString:String = appDelegate.model.getQuestion() as String
        
        //NSLog(htmlString)
        view1.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func hideSwipeLabel(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        lblSwipe?.hidden = true
        imgSwipeHand?.hidden = true
        
        appDelegate.model.isSwipeHelpShownQuestion = true
        
        //view1!.hidden = false
    }
}

