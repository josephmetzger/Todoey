//
//  ViewController.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/3/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    // Create itemArray from Item class
    var itemArray = [Item]()
    
    // Create data file path for data save director
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creat file path to directory
        
        
        print(dataFilePath)

        //Load data

        loadItems()
        
    }
    
    
        
    

    //MARK: Tableview Datasource Methods
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // Create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Create item for row
        let item = itemArray[indexPath.row]
        
        // Set cell text from array
        cell.textLabel?.text = item.title
        
        // Set checkmark status from array
        // Ternary operator:
        // Value = condition ? valueIfTrue : valueIfFalse
        // cell.accessoryType = item.done == true ? .checkmark : .none
        cell.accessoryType = item.done ? .checkmark : .none
        
        // Long way:
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }

    
    //MARK: Tableview Delegate Methods
    
    //TODO: Actions when item is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row after it is tapped
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Set done status in array to opposite current value (using !)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Write and reload
        saveDataItems()
        
        // Long way:
//        if itemArray[indexPath.row].done == false {
//            itemArray[indexPath.row].done = true
//        } else {
//            itemArray[indexPath.row].done = false
//        }
        
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
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            // Write and reload
            self.saveDataItems()
            
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
    
    // Save updated array to UserDefaults and reload
    func saveDataItems() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
            itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    
}

