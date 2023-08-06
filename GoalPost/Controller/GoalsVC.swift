//
//  ViewController.swift
//  GoalPost
//
//  Created by Maryna Bolotska on 06/08/23.
//

import UIKit

class GoalsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func addGoalBtnWasPressed(_ sender: Any) {
        print("Button was pressed")
    }
}

