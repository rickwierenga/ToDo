//
//  TDToDoTableViewCell.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit

class TDToDoTableViewCell: UITableViewCell {

    @IBOutlet weak var tickView: TDTickView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var todo: TDToDo! {
        didSet {
            tickView.isDone = todo.isDone
            nameLabel.text  = todo.name
        }
    }

}
