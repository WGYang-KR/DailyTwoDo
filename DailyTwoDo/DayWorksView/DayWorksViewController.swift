//
//  ViewController.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/13.
//

import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    let coreDataManager = CoreDataManager()
    var date: Date = Date()
    
    lazy var day: DayMo = {
        return coreDataManager.getDayMo(date: date)
    }()
   
    lazy var works: [WorkMo] = {
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: false)
        return day.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
    }()
        
    
    
    /*@IBAction func textFieldEditingDidEnd(_ sender: UITextField) {
    
        print("textFieldEditingDidEnd")
        //데이터 등록
        coreDataManager.newWork(date: date, title: sender.text ?? "", status: .inComplete)
    }*/
    
    

    let cellIdentifier: String = "DayWorksCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(date)
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numWorks = self.day.works?.count {
            return numWorks+2 //맨밑 입력란 추가 위해 + 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DayWorksTableViewCell else { return DayWorksTableViewCell() }
  
        cell.superTableView = self.tableView
        guard let numWorks = self.day.works?.count else {
            return cell
        }
        
        if indexPath.row < numWorks {
            //목록cell
            cell.textField.text = works[indexPath.row].title
        } else {
            //입력cell
        }
       
        return cell
        
    }


}

