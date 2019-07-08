//
//  ViewController.swift
//  Todoey
//
//  Created by Mohamed Gamal on 7/3/19.
//  Copyright © 2019 ME. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var ItemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        let item = ItemArray[indexPath.row]
        cell.textLabel?.text = item.title
        if(item.done == true){
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if(ItemArray[indexPath.row].done == false){
            ItemArray[indexPath.row].done = true
        } else {
            ItemArray[indexPath.row].done = false
        }
        saveItems()
        
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(ItemArray[indexPath.row])
            ItemArray.remove(at: indexPath.row)
            saveItems()
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertx) in
            
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if(textField.text?.isEmpty == false){
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                self.ItemArray.append(newItem)
                self.saveItems()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems(){
        do{
           try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do{
           ItemArray = try context.fetch(request)
        } catch {
            print("error loading items \(error)")
        }
        
        self.tableView.reloadData()
    }
    

}

extension TodoListViewController : UISearchBarDelegate{
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do{
            ItemArray = try context.fetch(request)
        } catch {
            print("error loading search items \(error)")
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0){
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

