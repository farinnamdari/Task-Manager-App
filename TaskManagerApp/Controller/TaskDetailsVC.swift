//
//  TaskDetailsVC.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/16/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class TaskDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var titleTxtField: CustomTextField!
    @IBOutlet weak var detailsTxtField: CustomTextField!
    @IBOutlet weak var keywordTableView: UITableView!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
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
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = frController.sections, sections.count > 0 {
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
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            taskImage.image = image
            imageSelected = true
        } else {
            print("Valid image was not selected.")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    // MARK: - IBAction
    @IBAction func addImageTapped(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
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
        
        ad.saveContext()
        uploadToFIRStorage() 
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
        keyword.title = ""
        keyword.taskTitle = (taskToEdit == nil) ? titleTxtField.text : taskToEdit?.title
        
        if taskToEdit == nil {
            let task = Task(context: context)
            
            task.title = titleTxtField.text
            taskToEdit = task
        }

        taskToEdit?.addToTaskToKeyword(keyword)
        
        ad.saveContext()
        attemptFetch()
        keywordTableView.reloadData()
    }
    
    // MARK: -
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()        
        let dataSort = NSSortDescriptor(key: "title", ascending: true)

        fetchRequest.sortDescriptors = [dataSort]
        
        if taskToEdit != nil {
            fetchRequest.predicate = NSPredicate(format: "keywordToTask.title == %@", taskToEdit!.title!)
        } else {
            fetchRequest.predicate = NSPredicate(format: "keywordToTask.title IN %@", [])
        }

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
    
    func uploadToFIRStorage() {
        guard let image = taskImage.image, imageSelected else {
            print("An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            
            metadata.contentType = "image/jpeg"
            DataService.instance.REF_UPLOADED_IMAGES.child(imgUid).putData(imgData, metadata: metadata, completion: { (metadata, err) in
                if err != nil {
                    print("Unable to upload image to Firebase storage. - Error: \(err.debugDescription)")
                } else {
                    print("Successfully uploaded to Firebase storage.")
                }
            })
        }
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
