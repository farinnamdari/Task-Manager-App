//
//  TaskCell.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/15/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var taskTitleLbl: UILabel!
    
    func configureCell(task: Task) {
        taskTitleLbl.text = task.title?.capitalized
    }

}
