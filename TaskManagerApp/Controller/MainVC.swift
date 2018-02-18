//
//  ViewController.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/15/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var taskSegControl: UISegmentedControl!
    
    var frController: NSFetchedResultsController<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        //generateTestData()  // remove this
        attemptFetch(index: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskDetailsVCEdit" {
            guard let destination = segue.destination as? TaskDetailsVC else {
                return
            }
            
            guard let task = sender as? Task else {
                return
            }
            
            destination.taskToEdit = task
        }
    }

    // MARK: - UITableViewDelegate/UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = frController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frController.sections {
            let sectionInfo = sections[section]

            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tasks = frController.fetchedObjects, tasks.count > 0 else {
            return
        }
        
        let task = tasks[indexPath.row]
        
        performSegue(withIdentifier: "showTaskDetailsVCEdit", sender: task)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // for completed task, just change state
        // for pending task, start the task immediately
        _ = UIContextualAction(style: .normal, title: "swipeRight") { (ac, view, success: (Bool) -> Void) in
            print("swipeRight")
            success(true)
        }
        
        if taskSegControl.selectedSegmentIndex == 0 {
            print("start task immediately")
        } else {
            let tasks = frController.fetchedObjects
            let task = tasks![indexPath.row]            // add guard/if let to avoid forced unwrap

            task.state = 0
        }
        
        ad.saveContext()
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // for completed task, just change state
        // for pending task, start the task in 1 min
        
        _ = UIContextualAction(style: .normal, title: "swipeLeft") { (ac, view, success: (Bool) -> Void) in
            print("swipeLeft")
            success(true)
        }
        
        if taskSegControl.selectedSegmentIndex == 0 {
            print("start task in 1 min")
        } else {
            let tasks = frController.fetchedObjects
            let task = tasks![indexPath.row]            // add guard/if let to avoid forced unwrap
            
            task.state = 0
        }
        
        ad.saveContext()
        return nil
    }
    
    /* fix it when done with cell*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                taskTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                taskTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .move:     // need to implement touch moving/dragging
            if let indexPath = indexPath {
                taskTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                taskTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = taskTableView.cellForRow(at: indexPath) as! TaskCell
                
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        }
    }
    
    // MARK: - IBAction
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        attemptFetch(index: taskSegControl.selectedSegmentIndex)
        taskTableView.reloadData()
    }
    
    // MARK: -
    func attemptFetch(index: Int) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let stateSort = NSSortDescriptor(key: "state", ascending: false)
        
        fetchRequest.sortDescriptors = [stateSort]
        fetchRequest.predicate = NSPredicate(format: "state == %i", index)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        frController = controller
        
        do {
            try frController.performFetch()            
        } catch {
            let err = error
            
            print("Error: \(err)")
        }
    }
    
    func configureCell(cell: TaskCell, indexPath: NSIndexPath) {
        let task = frController.object(at: indexPath as IndexPath)
        
        cell.configureCell(task: task)
    }
    
    func generateTestData() {
        let task1 = Task(context: context)
        task1.title = "Task for Farin"
        task1.state = 0
        
        let keyword = Keyword(context: context)
        keyword.title = "Math"
        keyword.taskTitle = "Task for Farin"
        task1.setValue(NSSet(object: keyword), forKey: "taskToKeyword")
        ad.saveContext()
        
        let keyword2 = Keyword(context: context)
        keyword2.title = "CS"
        keyword2.taskTitle = "Task for Farin"
        task1.setValue(NSSet(object: keyword2), forKey: "taskToKeyword")
        ad.saveContext()
    }
}

