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
    
    public var tickAction: ((TDToDo) -> Void)?
    
    override func layoutSubviews() {
        self.tickView.addTarget(self, action: #selector(performTickAction), for: .valueChanged)
    }
    
    var todo: TDToDo! {
        didSet {
            tickView.isDone = todo.isDone
            nameLabel.text  = todo.name
        }
    }
    
    @objc private func performTickAction() {
        self.todo.isDone = tickView.isDone
        if let action = tickAction {
            action(todo)
        }
    }
}
