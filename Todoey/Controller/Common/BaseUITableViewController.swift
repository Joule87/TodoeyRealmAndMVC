//
//  BaseUITableViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/11/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit
import SwipeCellKit

class BaseUITableViewController: UITableViewController {
   
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
    //Adding an activity indicator to local tableView
    func addActivityIndicatorToTable(_ selectorAction: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: selectorAction, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = getCellIdentifier()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    //MARK:- Manfatory Methods to implement
    
    //Override this method to set the Cell identifier of your UITableViewCell here
    func getCellIdentifier() -> String {
        return "UNKNOWN CELL IDENTIFIER"
    }
    //Override this method to remove the swiped cell for given indexPath
    func updateModel(at indexPath: IndexPath) {
        
    }
    
}

extension BaseUITableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let removeAction = SwipeAction(style: .destructive, title: "Delete") { (swipeAction, intdexPath) in
            self.updateModel(at: indexPath)
        }
        removeAction.image = UIImage(named: "delete-icon")
        return [removeAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
