//
//  BaseUITableViewController.swift
//  Todoey
//
//  Created by Julio Collado on 9/11/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import UIKit

class BaseUITableViewController: UITableViewController {
   
    //Adding an activity indicator to local tableView
    func addActivityIndicatorToTable(_ selectorAction: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: selectorAction, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}
