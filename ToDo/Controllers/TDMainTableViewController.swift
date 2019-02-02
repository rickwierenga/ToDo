//
//  TDMainTableViewController.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit
import CoreData
import ConfettiView

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
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(info), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = .init(customView: infoButton)
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptAdd))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(askDeleteCompleted))
        self.navigationItem.rightBarButtonItems = [add, delete]
        
        self.tableView.allowsSelection = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TDToDo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: CACHE_NAME)
        
        update()
    }
    
    // MARK: - UI
    @objc private func info() {
        let ac = UIAlertController(title: "ToDo", message: "ToDo is a simple open-source productivity app first created by Rick Wierenga. \n\n ©2019 Rick Wierenga", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "GitHub", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: "https://github.com/rickwierenga/ToDo")!, options: [:], completionHandler: nil)
        }))
        present(ac, animated: true)
    }
    
    @objc private func promptAdd() {
        prompt(todo: nil)
    }
    
    private func prompt(todo: TDToDo?) {
        let ac = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            if let todo = todo {
                textField.text = todo.name
            } else {
                textField.placeholder = "Buy Groceries"
            }
        }
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if let name = ac.textFields?.first?.text {
                if let todo = todo {
                    todo.name = name
                    self.update()
                } else {
                    self.addToDo(withName: name)

                }
            }
        }))
        present(ac, animated: true)
    }
    
    private func internalError(userDescription: String?) {
        let ac = UIAlertController(title: "Internal Error Occured", message: userDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    @objc private func askDeleteCompleted() {
        let ac = UIAlertController(title: "Delete all completed items?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.deleteCompleted()
        }))
        ac.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    // MARK: - ToDo actions
    private func addToDo(withName name: String) {
        let todo = TDToDo(context: managedContext)
        todo.name = name
        todo.isDone = false
        update()
    }
    
    private func deleteObject(_ object: NSManagedObject) {
        self.managedContext.delete(object)
        self.update()
    }
    
    @objc private func deleteCompleted() {
        if let todos = fetchedResultsController.fetchedObjects as? [TDToDo] {
            for todo in todos where todo.isDone {
                deleteObject(todo)
            }
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
        cell.tickAction = { _ in
            self.update()
            if self.numberOfUncompletedItems == 0 {
                let confettieView = ConfettiView()
                confettieView.frame = self.view.frame
                self.view.addSubview(confettieView)
                confettieView.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    confettieView.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        confettieView.removeFromSuperview()
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            guard let self = self else { return }
            if let object = self.fetchedResultsController.object(at: indexPath) as? NSManagedObject {
                self.deleteObject(object)
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            if let todo = self.fetchedResultsController.object(at: indexPath) as? TDToDo {
                self.prompt(todo: todo)
            }
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    // MARK: - Helpers
    func update() {
        do {
            try managedContext.save()
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
        catch {
            internalError(userDescription: error.localizedDescription)
        }
        
        self.navigationItem.title = "ToDo's (\(numberOfUncompletedItems))"
    }
    
    var numberOfUncompletedItems: UInt {
        get {
            let fetchRequest = NSFetchRequest<TDToDo>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "TDToDo", in: managedContext)
            fetchRequest.predicate = NSPredicate(format: "isDone == FALSE")
            do {
                let items = try managedContext.fetch(fetchRequest)
                return UInt(items.count)
            }
            catch {
                internalError(userDescription: error.localizedDescription)
            }
            return 0
        }
    }
}

