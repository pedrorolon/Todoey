//
//  ViewController.swift
//  Todoey
//
//  Created by Pedro on 3/11/19.
//  Copyright © 2019 Roshka. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems() 
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add new Items
    
    
    //What will happen once the user clicks the Add Item button on our UIAlert
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            //What will happen when user clicks the button Add Item
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("canceled")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func saveItems(){
        let encoder = PropertyListEncoder()
        
        do{
            let data  = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("Error encoding item array, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("Error decoding data, \(error)")
            }
        }
    }
    

}

