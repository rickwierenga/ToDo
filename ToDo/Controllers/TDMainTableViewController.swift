//
//  TDMainTableViewController.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit
import CoreData

class TDMainTableViewController: UITableViewController {
    
    // MARK: - Properties
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    private var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistantContainer.viewContext
    }()
    
    let CACHE_NAME = "todo"
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(promptAdd))
        self.tableView.allowsSelection = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TDToDo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: CACHE_NAME)
        
        do {
            let o = try fetchedResultsController.performFetch()
            print(o)
        }
        catch {}
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
                self.addToDo(withName: title)
            }
        }))
        present(ac, animated: true)
    }
    
    private func internalError(userDescription: String?) {
        let ac = UIAlertController(title: "Internal Error Occured", message: userDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    // MARK: - ToDo actions
    private func addToDo(withName name: String) {
        let todo = TDToDo(context: managedContext)
        todo.name = name
        todo.isDone = false
        
        do {
            try managedContext.save()
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
        catch {
            internalError(userDescription: error.localizedDescription)
        }
        
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            internalError(userDescription: nil)
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todo", for: indexPath) as! TDToDoTableViewCell
        guard let object = fetchedResultsController?.object(at: indexPath),
            let todo = object as? TDToDo else {
                internalError(userDescription: nil)
                return UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        cell.todo = todo
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
