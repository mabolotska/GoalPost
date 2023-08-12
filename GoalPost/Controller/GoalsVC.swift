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
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var undoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        undoView.alpha = 0.0
        undoBtn.isHidden = true
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
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
        
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "ADD 1") { (rowAction, indexPath) in
            self.setProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9385011792, green: 0.7164435983, blue: 0.3331357837, alpha: 1)
        
        let goal = goals[indexPath.row]
        
        if goal.goalProgress == goal.goalCompletionValue {
            return [deleteAction]
        } else {
            return [deleteAction, addAction]
        }
    }
}

extension GoalsVC {
    
    func fadeOutView(view: UIView) {
        
                UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
                    view.alpha = 0.0
                }, completion: { (true) in
                    self.undoBtn.isHidden = true
                })
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
