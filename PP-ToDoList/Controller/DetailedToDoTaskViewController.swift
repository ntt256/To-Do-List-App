//
//  DetailedToDoTaskViewController.swift
//  PP-ToDoList
//
//  Created by Nhut Tran on 9/21/25.
//

import UIKit

class DetailedToDoTaskViewController: UIViewController {
    
    @IBOutlet weak var toDoTaskNameLabel: UILabel!
    @IBOutlet weak var toDoTaskDueDateLabel: UILabel!
    @IBOutlet weak var toDoTaskCreationDateLabel: UILabel!
    @IBOutlet weak var toDoTaskCompletionSwitch: UISwitch!
    
    var taskName: String?
    var taskDueDate: String?
    var taskCreationDate: String?
    var taskCompleted: Bool?
    let textAttributes : [NSAttributedString.Key : Any] = [
        .font : UIFont.boldSystemFont(ofSize: 20.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoTaskNameLabel.attributedText = NSAttributedString(string: taskName!, attributes: textAttributes)
        toDoTaskDueDateLabel.text = "Due: \(taskDueDate!)"
        toDoTaskCreationDateLabel.text = "Created on \(taskCreationDate!)"
        toDoTaskCompletionSwitch.isOn = taskCompleted!
        toDoTaskCompletionSwitch.isEnabled = false
    }
    
    @IBAction func toDoTaskCompletionStatusToggler(_ sender: UISwitch) {
        
    }
}
