//
//  ViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/9/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = CoreDataMananger.shared.persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addActivityIndicatorToTable()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    func addActivityIndicatorToTable() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshLoadItems), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    //MARK:- Table View Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK:- Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        let accessoryType = itemArray[indexPath.row].done ? UITableViewCell.AccessoryType.checkmark : .none
        tableView.cellForRow(at: indexPath)?.accessoryType = accessoryType
        CoreDataMananger.shared.saveContext()
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
    
    //MARK:- Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldValue: UITextField?
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Create new Item"
            textFieldValue = textField
        }
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let itemTitle = textFieldValue?.text ?? ""
            self.addItemToTodoList(itemTitle)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
           self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func addItemToTodoList(_ itemTitle: String) {
        let newItem = Item(context: context)
        newItem.title = itemTitle
        newItem.parentCategory = selectedCategory
        
        itemArray.append(newItem)
        CoreDataMananger.shared.saveContext()
        loadItems()
    }
    
    @objc func refreshLoadItems() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadItems()
            self.tableView.refreshControl?.endRefreshing()
        }
    
    }
   
    
    @objc func loadItems(fetchRequestItem: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        print("Fetching Items")
        let categoryName = selectedCategory?.name ?? ""
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        
        var predicates = [NSPredicate]()
        predicates.append(categoryPredicate)
        if let itemPredicate = predicate {
            predicates.append(itemPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequestItem.predicate = compoundPredicate
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequestItem.sortDescriptors = [sortDescriptor]
        
        do {
            itemArray = try context.fetch(fetchRequestItem)
            tableView.reloadData()
        } catch {
            print("Error Fetching Items \(error)")
        }
    }

}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            return
        }
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadItems(fetchRequestItem: request, predicate: predicate)
    }
    
}

