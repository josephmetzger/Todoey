//
//  ViewController.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/3/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    // Create items from Item class
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    // Creates selected category variable. didSet runs as soon as category has a value set
    var selectedCategory : Category? {
        didSet {
            // Load items from the array
            loadItems()
        }
    }
    
    // Get path for data save directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print path for data save directory
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.color else {fatalError("Error")}
            
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "7CB8FF")
        
    }
    
    //MARK: Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode : String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColor = HexColor(colorHexCode) else {fatalError("Error")}
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
        
    }
    
    
        
    @IBOutlet weak var searchBar: UISearchBar!
    

    //MARK: Tableview Datasource Methods
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell ("ToDoItemCell" comes from Prototype Cell Identifier
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        
        // Create item for row if not nil
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = HexColor(selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }

    
    //MARK: Tableview Delegate Methods
    
    //TODO: Actions when item is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row after it is tapped
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Set done status in array to opposite current value
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    // To delete:
//                    realm.delete(item)
                }
            } catch {
                print("Error updating completion status: \(error)")
            }
        }
        
        tableView.reloadData()

        
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
            
            if let currentCategory = self.selectedCategory {
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
                } catch {
                    print("Error saving data: \(error)")
                }
            }
            
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
    
    //MARK: Model Manipulation Methods
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()

    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                    
                }
            } catch {
                print("Error deleting item: \(error)")
            }
            
        }
    }
    
   
    
    
}

//MARK: Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()

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

