//
//  TaskDetailsVC.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/16/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit
import CoreData

class TaskDetailsVC: UIViewController {

    @IBOutlet weak var titleTxtField: CustomTextField!
    @IBOutlet weak var detailsTxtField: CustomTextField!
    
    var taskToEdit: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        if taskToEdit != nil {
            loadTaskData()
        }
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
        
        // task.toKeword  = array of keywords
        
        task.state = 0
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
    
    // MARK: -
    func loadTaskData() {
        if let task = taskToEdit {
            titleTxtField.text = task.title
            detailsTxtField.text = task.details
            /*
             if let keywords = task.toKeyword {
                populate table view with keywords
             }
            */
        }
    }

    
}
