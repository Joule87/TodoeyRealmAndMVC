//
//  ViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/9/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: BaseUITableViewController {

    var todoItems : Results<Item>?
    var selectedCategory: Category? {
        didSet {
           loadItems()
        }
    }
    
    let realmManager = RealmMananger.shared
    
    //MARK:- Override View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicatorToTable(#selector(refreshLoadItems))
        tableView.rowHeight = 70
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK:- Optional but mandatory methods to implement
    override func getCellIdentifier() -> String {
        return "ToDoItemCell"
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let object = self.todoItems?[indexPath.row] {
            self.realmManager.remove(object, cascading: false)
        }
    }
    
    //MARK:- Table View Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = todoItems?[indexPath.row] else {
            return
        }
        realmManager.update {
            item.done = !item.done
        }
        tableView.reloadRows(at: [indexPath], with: .none)
       
    }
    
    //MARK:- Actions Methods
    
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
    
    //MARK:- View Controller Methods
    func addItemToTodoList(_ itemTitle: String) {
        
        guard let currentCategory = selectedCategory else {
            return
        }
        realmManager.update {
            let newItem = Item()
            newItem.title = itemTitle
            currentCategory.items.append(newItem)
        }
        loadItems()
    }
    
    @objc func refreshLoadItems() {
        //Simulation of a query that takes 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadItems()
            self.tableView.refreshControl?.endRefreshing()
        }
        
    }
    
    @objc func loadItems() {
        print("Fetching Items")
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}
