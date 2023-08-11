//
//  ViewController.swift
//  GoalPost
//
//  Created by Maryna Bolotska on 06/08/23.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {
    var goals: [Goal] = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects() {
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
            }
        }
    }

    @IBAction func addGoalBtnWasPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC") else {return}
        presentDetail(createGoalVC)
    }
}

extension GoalsVC: UITableViewDelegate, UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
        
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal)
        return cell
    }
}

extension GoalsVC {
    
    func fadeOutView(view: UIView) {
        
        //        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
        //            view.alpha = 0.0
        //        }, completion: { (true) in
        //            self.undoBtn.isHidden = true
        //        })
            }
        
        func fadeInView(view: UIView) {
            UIView.animate(withDuration: 2.0) {
                view.alpha = 1.0
            }
        }
        
        func setProgress (atIndexPath indexPath: IndexPath) {
            guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
            let chosenGoal = goals[indexPath.row]
            if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
                chosenGoal.goalProgress += 1
            } else {
                return
            }
            
            do {
                try managedContext.save()
            } catch {
                debugPrint("Could not set progress \(error.localizedDescription)")
            }
        }
        
            func removeGoal(atIndexPath indexPath: IndexPath) {
                guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
                managedContext.undoManager = UndoManager()
                managedContext.delete(goals[indexPath.row])
                do {
                    try managedContext.save()
                    undoBtn.isHidden = false
                    fadeInView(view: undoView)
                } catch {
                    debugPrint("Could not remove \(error.localizedDescription)")
                }
            }
        
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do {
            goals = try managedContext.fetch(fetchRequest)
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
    }
    
}
