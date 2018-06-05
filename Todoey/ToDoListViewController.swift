//
//  ViewController.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/3/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = ["Item 1", "Item 2", "Item 3"]
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Validate and load data from UserData
        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
            itemArray = items
        }
        
    }

    //MARK: Tableview Datasource Methods
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }

    
    //MARK: Tableview Delegate Methods
    
    //TODO: Actions when item is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        // Deselect row after it is tapped
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add\remove checkmark when cell tapped
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
    }
    
    //MARK: Add new item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Initialize textField variable
        var textField = UITextField()
        
        // Create new list item
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        // Create action button for alert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once user clicks add item button on UIAlert
            
            // Add textField to array
            self.itemArray.append(textField.text!)
            
            // Save updated array to UserDefaults
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
            // Reload table view
            self.tableView.reloadData()
            
        }
        
        // Create the alert text field
        alert.addTextField { (alertTextField) in
            
            // Set the text to the closure scope variable
            textField = alertTextField
        }
        
        // Add the Add Item action to the alert
        alert.addAction(action)
        
        // Show the alert pop-up when the add button is pressed
        present(alert, animated: true, completion: nil)
        
    }
    
}

