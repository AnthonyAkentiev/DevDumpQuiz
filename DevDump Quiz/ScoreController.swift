//
//  ScoreController.swift
//  Heap Spray Game
//
//  Created by Anthony Akentiev on 25/04/15.
//  Copyright (c) 2015 Anthony Akentiev. All rights reserved.
//

import UIKit

class ScoreController: UIViewController {
    @IBOutlet var lblTotalQuestion: UITextField!
    @IBOutlet var lblCorrect: UITextField!
    @IBOutlet var lblLevel: UITextField!
    @IBOutlet var lblTopic: UITextField!

    @IBAction func onContinue(){
        performSegueWithIdentifier("goToMainMenu",sender:self)
    }
}