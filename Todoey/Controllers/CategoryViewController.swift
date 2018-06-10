//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/9/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    
    //MARK: TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
        
    }
    
    //MARK: TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Add reference to destination view controller
        let destinationVC = segue.destination as! ToDoListViewController
        
        // Set the category variable in the ToDoListViewController to equal the selected category
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }


   //MARK: Add New Categories
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
        
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Add a new category"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }


    
    //MARK: Data Manipulation Methods
    
    // Save updated array to UserDefaults and reload
    func saveCategories() {
        
        do {
            // Save the context to the persistent container
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
        
    }

    func loadCategories() {
    
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            // Pull the items from request via the context and save the values to itemArray
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
        }
        
        tableView.reloadData()
    }
 
    
    
    
}
