//
//  ViewController.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/3/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    // Create itemArray from Item class
    var itemArray = [Item]()
    
    // Creates selected category variable. didSet runs as soon as category has a value set
    var selectedCategory : Category? {
        didSet {
            // Load items from the array
            loadItems()
        }
    }
    
    // Get path for data save directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // Get viewContext from AppDelegate via singleton
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print path for data save directory
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
        
    

    //MARK: Tableview Datasource Methods
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // Create cell ("ToDoItemCell" comes from Prototype Cell Identifier
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
        
        // Code to remove data from context (has to be done first before deleting from the array)
        //context.delete(itemArray[indexPath.row])
        // Code to remove item from array instead of update
        //itemArray.remove(at: indexPath.row)

        
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
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
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
    
    //MARK: Model Manipulation Methods
    
    // Save updated array to UserDefaults and reload
    func saveDataItems() {
        
        do {
            // Save the context to the persistent container
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    // Load persistent storage items into local array; use default fetch request if no parameter input given
    // External parameter: with, Internal parameter: request
    // By default (no inputs), let the request be a NSFetchRequest that will fetch all "Items" from the persistent container
    // Set NSPredicate to nil to prevent having to pass in the predicate when called
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
       
        //Create categorypredicate (query) to filter items returned by category
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory!.name!))
        
        // Create compound predicate to combine queries for parent category and search predicates
        // Conditional binding to check if predicate is not nil, if not create the constant additionalPredicate
        if let additionalPredicate = predicate {
            // If predicate is not nil, use compound predicate
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            // If predicate is nil, use default category only predicate
            request.predicate = categoryPredicate
        }
        
        //Deprecated via default above
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            // Pull the items from request via the context and save the values to itemArray
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
        print("tableView reloaded")
    }
    
    
}

//MARK: Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Create search request
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
//        // Create predicate (query); [cd] is for case and diacratic insensitivity
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        // Add predicate (query) to request
//        request.predicate = predicate
        
//        // Create sorting
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//        // Add sorting to request
//        request.sortDescriptors = [sortDescriptor]
        
        // Create predicate (query) and add predicate (query) to request; [cd] is for case and diacratic insensitivity
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Create sorting and add sorting to request
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // Run the request via the context and save the values to itemArray
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context: \(error)")
//        }
        
        // Pass to load items and return filtered results
        loadItems(with: request, predicate: predicate)
    
    }
    
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            // If search bar is blank, load all items in the list
            loadItems()
            
            // Dismiss the keyboard and focus on the search bar in the main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}


