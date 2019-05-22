//
//  ViewController.swift
//  Todoey
//
//  Created by Pedro on 3/11/19.
//  Copyright © 2019 Roshka. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var selectedCategory : Category!

    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        searchBar.delegate = self
        navigationItem.backBarButtonItem?.tintColor = UIColor.red
        
        //loadItems()
        filterElements(with: selectedCategory)
        
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
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        
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
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory? = self.selectedCategory
            
            self.selectedCategory.addToItems(newItem)
            
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
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //Se ejecuta el query recibido si se recibió, y si no se recibió se ejecuta el por default
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }

}

extension ToDoListViewController: UISearchBarDelegate {
    
    //MARK: SearchBar Deletate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterElements(with: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            filterElements(with: selectedCategory)
            
            
            DispatchQueue.main.async {
                //Notifica al objeto (en este caso el searchBar) que  hay que estar como en la primera respuesta. O sea, con el focus y sin el teclado de pantalla
                searchBar.resignFirstResponder()
            }
            
        } else {
            filterElements(with: searchBar.text!)
        }
    }
    
    
    func filterElements(with title: String){
        //Crea un fetcher
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //Se crea un predicado, que contiene el query
        let predicate = NSPredicate(format: "title CONTAINS [cd] %@ AND parentCategory.name CONTAINS [cd] %@", title, selectedCategory.name!)
        //Se asigna el query al request
        request.predicate = predicate
        //Un descriptor de orden. Se usa para especificar la regla de ordenamiento. El campo y si es ascendente o descendente
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //Se agrega el sortDescriptor al sortDescriptors del request
        request.sortDescriptors = [sortDescriptor]
        //Se llama a la funcion loadItems con el request creado
        loadItems(with: request)
    }
    
    func filterElements(with category: Category){
        //Crea un fetcher
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //Se crea un predicado, que contiene el query
        let predicate = NSPredicate(format: "parentCategory.name CONTAINS[cd] %@", category.name!)
        //Se asigna el query al request
        request.predicate = predicate
        //Un descriptor de orden. Se usa para especificar la regla de ordenamiento. El campo y si es ascendente o descendente
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //Se agrega el sortDescriptor al sortDescriptors del request
        request.sortDescriptors = [sortDescriptor]
        //Se llama a la funcion loadItems con el request creado
        loadItems(with: request)
    }
    
}

