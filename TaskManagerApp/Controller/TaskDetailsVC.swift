//
//  TaskDetailsVC.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/16/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit
import CoreData

class TaskDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var titleTxtField: CustomTextField!
    @IBOutlet weak var detailsTxtField: CustomTextField!
    @IBOutlet weak var keywordTableView: UITableView!
    
    var frController: NSFetchedResultsController<Keyword>!
    var taskToEdit: Task?
    var keywords = [Keyword]() // maight not need this
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        keywordTableView.delegate = self
        keywordTableView.dataSource = self
        
        //generateKeyword()
        attemptFetch()
        
        if taskToEdit != nil {
            loadTaskData()
        }
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = frController.sections {
            //print("\(frController.fetchedObjects![0])")
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
        let cell = keywordTableView.dequeueReusableCell(withIdentifier: "KeywordCell", for: indexPath) as! KeywordCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        keywordTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        keywordTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                keywordTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                keywordTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .move:     // need to implement touch moving/dragging
            if let indexPath = indexPath {
                keywordTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                keywordTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = keywordTableView.cellForRow(at: indexPath) as! KeywordCell
                
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        }
    }
    
    /* fix it when done with cell*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // MARK: - IBAction
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        var task: Task!
        
        task = (taskToEdit == nil) ? Task(context: context) : taskToEdit
        
        if let title = titleTxtField.text {
            task.title = title
        }
        
        if let details = detailsTxtField.text {
            task.details = details
        }
        
        task.state = 0

        for keyword in keywords {
            task.setValue(NSSet(object: keyword), forKey: "taskToKeyword")
        }

        // task.toKeyword  = array of keywords
        //task?.toKeyword
        //let keyword = Keyword(context: context)
        //keyword.title =
        //task.toKeyword?.adding(keyword)
        
        ad.saveContext()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        if taskToEdit != nil {
            context.delete(taskToEdit!)
            ad.saveContext()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func addKeywordBtnPressed(_ sender: UIButton) {
        let keyword = Keyword(context: context)
        keyword.title = "New Title"
        keyword.taskTitle = (taskToEdit == nil) ? titleTxtField.text : taskToEdit?.title
        
//        taskToEdit?.addToTaskToKeyword(keyword)
//        taskToEdit?.setValue(NSSet(object: keyword), forKey: "taskToKeyword")
        //keywords.append(keyword)
        
        ad.saveContext()
        keywordTableView.reloadData()
    }
    
    // MARK: -
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()        
        let dataSort = NSSortDescriptor(key: "title", ascending: true)

        fetchRequest.sortDescriptors = [dataSort]
        fetchRequest.predicate = NSPredicate(format: "ANY keywordToTask.title == %@", taskToEdit!.title!)

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        frController = controller
        
        do {
            try controller.performFetch()
        } catch {
            let err = error as NSError
            
            print("Error: \(err)")     // replace with fatalerror
        }
        
    }
    
    func loadTaskData() {
        if let task = taskToEdit {
            titleTxtField.text = task.title
            detailsTxtField.text = task.details
            
            if let keywords = task.taskToKeyword {
                print("keywords: \(keywords)")
                print("\(keywords.count)")
                
                print("\(keywords.allObjects)")
            }
            /*
             if let keywords = task.toKeyword {
                populate table view with keywords
             }
            */
        }
    }

    func configureCell(cell: KeywordCell, indexPath: NSIndexPath) {
        let keyword = frController.object(at: indexPath as IndexPath)

        cell.configureCell(keyword: keyword)
    }
    
    func generateKeyword() {
        let keyword1 = Keyword(context: context)
        keyword1.title = "High Priority"
        keyword1.taskTitle = "Finish Proj 4"
        
        let keyword2 = Keyword(context: context)
        keyword2.title = "CS"
        keyword2.taskTitle = "Finish Proj 4"
        
        ad.saveContext()
    }
    
}
