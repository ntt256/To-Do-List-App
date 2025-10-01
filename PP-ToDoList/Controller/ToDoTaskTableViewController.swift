//
//  ToDoTaskTableViewController.swift
//  PP-ToDoList
//
//  Created by Nhut Tran on 9/17/25.
//

import UIKit
import SwipeCellKit
import CoreData

class ToDoTaskTableViewController: UITableViewController {
    @IBOutlet weak var organizeToDoTasksButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var selectedCategory: Category?
    var selectedToDoTaskCell: ToDoTask?
    var toDoTasks : [ToDoTask] = []
 
     
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToDoTasks()
        let organizeToDoTasksActions : [UIAction] = [
            UIAction(title: "Sort by completed", image: UIImage(systemName: "checkmark.square.fill")) {_ in
                self.loadToDoTasks(sortDescriptor: NSSortDescriptor(key: "completion", ascending: false))
            },
            UIAction(title: "Sort by uncompleted", image: UIImage(systemName: "checkmark.circle")) { action in
                self.loadToDoTasks(sortDescriptor: NSSortDescriptor(key: "completion", ascending: true))
            },
            UIAction(title: "Sort by due date", image: UIImage(systemName: "calendar.badge.exclamationmark")) { action in
                self.loadToDoTasks(sortDescriptor: NSSortDescriptor(key: "dueDate", ascending: true))
            },
            UIAction(title: "Sort by new tasks", image: UIImage(systemName: "arrow.up.document")) { action in
                self.loadToDoTasks(sortDescriptor: NSSortDescriptor(key: "dateCreated", ascending: false))
            },
            UIAction(title: "Sort by older tasks", image: UIImage(systemName: "arrow.down.document")) { action in
                self.loadToDoTasks(sortDescriptor: NSSortDescriptor(key: "dateCreated", ascending: true))
            }
        ]
        let menu = UIMenu(title: "Organize by", options: .displayInline, children: organizeToDoTasksActions)
        organizeToDoTasksButton.menu = menu
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = selectedCategory?.name
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTaskCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = toDoTasks[indexPath.row].name
        cell.accessoryType = toDoTasks[indexPath.row].completion ? .checkmark : .none
        return cell
    }
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toDoTasks[indexPath.row].completion = !toDoTasks[indexPath.row].completion
        saveData()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! DetailedToDoTaskViewController
        destinationVc.taskName = selectedToDoTaskCell?.name
        destinationVc.taskDueDate = selectedToDoTaskCell?.dueDate
        destinationVc.taskCreationDate = selectedToDoTaskCell?.dateCreated
        destinationVc.taskCompleted = selectedToDoTaskCell?.completion
    }
    //MARK: - data manipulation methods
    @IBAction func addNewToDoTask(_ sender: UIBarButtonItem) {
        var newToDoTaskTextField = UITextField()
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 300, height: 70)
        
        //task due date
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = .now
        datePicker.frame = CGRect(x: 90, y: -5, width: 150, height: 50)
        let dueDateTitle = UILabel()
        dueDateTitle.frame = CGRect(x: 40, y: -30, width: 100, height: 100)
        dueDateTitle.text = "Due On"
        vc.view.addSubview(dueDateTitle)
        vc.view.addSubview(datePicker)

        //the alert to be displayed
        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .alert)
        let addNewTaskAction = UIAlertAction(title: "Add", style: .default) { action in
            let newToDoTask = ToDoTask(context: self.context)
            newToDoTask.completion = false
            newToDoTask.name = newToDoTaskTextField.text
            newToDoTask.dueDate = self.convertDateToString(date: datePicker.date)
            newToDoTask.dateCreated = self.convertDateToString(date: Date())
            newToDoTask.parentCategory = self.selectedCategory
            self.saveData()
        }
        
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor") //making the font color red
        
        alert.addAction(addNewTaskAction)
        alert.addAction(cancelAction)
        alert.addTextField { txtField in
            txtField.placeholder = "Name your new task..."
            newToDoTaskTextField = txtField
        }
        alert.setValue(vc, forKey: "contentViewController")
        present(alert, animated: true)
    }
    
    func loadToDoTasks(sortDescriptor: NSSortDescriptor? = nil){
        let request : NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        let defaultPred = NSPredicate(format: "parentCategory = %@", selectedCategory!)
        request.predicate = defaultPred
        if let sortedToDoTasksDescriptor = sortDescriptor{
            request.sortDescriptors = [sortedToDoTasksDescriptor]
        }
    
        do{
            toDoTasks = try context.fetch(request)

        } catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveData(){
        do{
            try context.save()
        } catch{
            print(error)
        }
        loadToDoTasks()
    }
    
    func convertDateToString(date: Date) -> String{
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
//MARK: - SwipeTableViewCellDelegate
extension ToDoTaskTableViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let moreAction = SwipeAction(style: .default, title: "Info") { action, indexPath in
            let selectedRow = indexPath.row
            self.selectedToDoTaskCell = self.toDoTasks[selectedRow]
            self.performSegue(withIdentifier: "viewDetailedToDoTaskInfo", sender: self)
        }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let selectedRow = indexPath.row
            self.context.delete(self.toDoTasks[selectedRow])
            self.toDoTasks.remove(at: selectedRow)
            do{
                try self.context.save()
            } catch{
                print(error)
            }
        }
        
        moreAction.image = UIImage(systemName: "info.circle.fill")
        deleteAction.image = UIImage(systemName: "trash")
        return [deleteAction, moreAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
