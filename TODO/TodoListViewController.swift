//
//  ViewController.swift
//  TODO
//
//  Created by zpcao on 2019/1/2.
//  Copyright © 2019 zpcao.com. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {

//    var itemArray = ["购买水杯","吃药","修改密码"]
    var itemArray = [Item]()
    
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
//            itemArray = items
//        }
//        print(dataFilePath)
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
        loadItems()
        
//        let newItem = Item()
//        newItem.title = "购买水杯"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.title = "吃药"
//        itemArray.append(newItem2)
//
//
//        let newItem3 = Item()
//        newItem3.title = "修改密码"
//        itemArray.append(newItem3)
        
        


        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
//        if itemArray[indexPath.row].done == false {
//            cell.accessoryType = .none
//        } else {
//            cell.accessoryType = .checkmark
//        }
        
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }

    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        print(indexPath.row)
        print(itemArray[indexPath.row])
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
         
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        } else {
            itemArray[indexPath.row].done = false
        }
        
        saveItems()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        tableView.endUpdates()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveItems(){
//        let encoder = PropertyListEncoder()
        do {
            try context.save()
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
        } catch {
            print("编码错误:\(error)")
        }
    }
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest()){
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误:\(error)")
        }
        tableView.reloadData()
        
    }
//    func loadItems(){
//        if let data = try?Data(contentsOf:dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//
//            } catch {
//                print("解码item错误！")
//            }
//        }
//    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "添加项目", style: .default) {
            (action) in
            print(textField.text!)
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)

            self.saveItems()

            //            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            self.tableView.reloadData()
        }
        
        alert.addTextField{
            (alertTextField) in
            alertTextField.placeholder = "创建一个新项目..."
//            print(alertTextField.text!)
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}


extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(with:request)
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("从context获取数据错误:\(error)")
//        }
//        tableView.reloadData()
//        print(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }
            
        }
    }
}
