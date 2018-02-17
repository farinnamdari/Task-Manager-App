//
//  KeywordCell.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/16/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import UIKit

class KeywordCell: UITableViewCell {
    
    @IBOutlet weak var titleTxtField: CustomTextField!
 
    func configureCell(keyword: Keyword) {
        titleTxtField.text = keyword.title?.capitalized
    }
    
}
