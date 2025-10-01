//
//  ViewController.swift
//  PP-ToDoList
//
//  Created by Nhut Tran on 9/16/25.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryViewController: UITableViewController {
    var categories : [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }
    //MARK: - Data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    //MARK: - delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToToDoTasks", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! ToDoTaskTableViewController
        let selectedCategory = tableView.indexPathForSelectedRow!
        destinationVc.selectedCategory = categories[selectedCategory.row]
    }
    //MARK: - data manipulation methods
    
    //adding new category
    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        var newCategoryTextField = UITextField()
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category(context: self.context)
            newCategory.name = newCategoryTextField.text
            self.saveData(category: newCategory)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField(configurationHandler: { txtFld in
            txtFld.placeholder = "Name your category..."
            newCategoryTextField = txtFld
        })
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
            
        present(alert, animated: true, completion: nil)
    }
    
    func loadCategories(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do{
            categories = try context.fetch(request)

        } catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveData(category: Category? = nil){
        do{
            try context.save()
        } catch{
            print(error)
        }
        loadCategories()
    }
}
//MARK: - SwipeTableViewCellDelegate
extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let selectedRow = indexPath.row
            self.context.delete(self.categories[selectedRow])
            self.categories.remove(at: selectedRow)
            do{
                try self.context.save()
            } catch{
                print(error)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}

