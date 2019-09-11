//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/10/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var category = [Category]()
    let context = CoreDataMananger.shared.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let newCategory = Category(context: context)
        newCategory.name = categoryName
        category.append(newCategory)
        persistCategory()
    }
    
    func persistCategory() {
        CoreDataMananger.shared.saveContext()
        loadCategory()
    }
    
    func loadCategory(request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            category = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("\(error)")
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return category.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = category[indexPath.row].name
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
            destinationVC.selectedCategory = category[indexPath.row]
        }
        
        
    }
   
}
