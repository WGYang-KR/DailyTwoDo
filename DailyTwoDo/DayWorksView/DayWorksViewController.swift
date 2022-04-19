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
    
    
    //쉐어 데이터 클래스 생성해서 해당 날짜의 day,work 저장.
    let coreDataManager = CoreDataManager()
    var date: Date = Date()
    
    lazy var day: DayMo = {
        return coreDataManager.getDayMo(date: date)
    }()
   
    lazy var works: [WorkMo] = {
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: false)
        return day.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
    }()
    

    let cellIdentifier: String = "DayWorksCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(date)
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        tapGesture.cancelsTouchesInView = false //인식하고, view로도 보냄
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

