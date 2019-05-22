//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Pedro on 5/21/19.
//  Copyright © 2019 Roshka. All rights reserved.
//

import UIKit
import CoreData


class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (actionButton) in
            print("action Canceled")
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new Category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    
    }
    
    //MARK: TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let categorySelected = tableView.cellForRow(at: indexPath)?.textLabel?.text!
        
        let categorySelected = categoryArray[indexPath.row]
        
        
        performSegue(withIdentifier: "goToItems", sender: categorySelected)
    }
    
    //MARK: Data Manipulations Methods
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        print("Loading Categories...")
        do{
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
        print("Categories loaded!")
    }
    
    func saveCategories(){
        print("Saving Categories...")
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        print("Categories saved!")
        self.tableView.reloadData()
    }
    
    
    
    //To send data to the nextViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SENDER. Selected Category is : \(String(describing: (sender as! Category).name ))")
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        
        destinationVC.selectedCategory = sender as? Category
    }
}
