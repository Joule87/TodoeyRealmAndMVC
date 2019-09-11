//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/10/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: BaseUITableViewController {
    var category: Results<Category>?
    let realmManager = RealmMananger.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicatorToTable(#selector(refreshCategories))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategory()
    }

    //MARK:- Actions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldCategory = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Create Category"
            textFieldCategory = textField
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let categoryName = textFieldCategory.text {
                self.addToCategory(categoryName: categoryName)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.dismiss(animated: true)
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func addToCategory(categoryName: String) {
        let newCategory = Category()
        newCategory.name = categoryName
        persistCategory(newCategory)
    }
    
    func persistCategory(_ newCategory: Category) {
       realmManager.save(object: newCategory)
       loadCategory()
    }
    
    func loadCategory() {
        category = realmManager.get(objectsType: Category.self)
        tableView.reloadData()
    }
    
    @objc func refreshCategories() {
        //Simulation of a query that takes 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadCategory()
            self.tableView.refreshControl?.endRefreshing()
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return category?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = category?[indexPath.row].name ?? "No Categories added yet"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TodoListViewController else {
            return
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = category?[indexPath.row]
        }
        
        
    }
   
}
