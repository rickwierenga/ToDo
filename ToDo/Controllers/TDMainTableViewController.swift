//
//  TDMainTableViewController.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit

class TDMainTableViewController: UITableViewController {
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(promptAdd))
        self.tableView.allowsSelection = false
    }
    
    // MARK: - UI
    @objc private func promptAdd() {
        let ac = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Buy Groceries"
        }
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if let title = ac.textFields?.first?.text {
                self.addToDo(withTitle: title)
            }
        }))
        present(ac, animated: true)
    }
    
    // MARK: - ToDo actions
    private func addToDo(withTitle title: String) {
        
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todo", for: indexPath) as! TDToDoTableViewCell
       
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistantContainer.viewContext
            
            // -- get todo from fetchre... thing
            let todo = TDToDo(context: managedContext)
            todo.name = "Test \(indexPath.row)"
            todo.isDone = false
            // --
            
            cell.todo = todo
            
            return cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
