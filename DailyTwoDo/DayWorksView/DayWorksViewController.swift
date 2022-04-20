//
//  ViewController.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/13.
//

import UIKit
import FSCalendar
import CoreData

class DayWorksViewController: UIViewController{

    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier: String = "DayWorksCell"
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        tapGesture.cancelsTouchesInView = false //인식하고, view로도 보냄
        view.addGestureRecognizer(tapGesture)

        
        print("worksArray: \(DayWorks.shared.worksArray)")
        print("worksInDay: \(DayWorks.shared.day.works)")
        
        //MARK: calendar 커스터마이징
        calendar.select(SelectedDate.shared.date) //오늘 날짜 선택
        calendar.appearance.caseOptions =  FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.locale = Locale(identifier:"ko_KR") //Locale.current.identifier
        print(calendar.locale)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        print(self.navigationItem.title)
        customNavigationItem.title = dateFormatter.string(from: date)
        
    }
}

extension DayWorksViewController: FSCalendarDelegate{
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        //현재 화면의 달이 아니면 해당 달력으로 페이지 이동
        let currentPageYearMonth = Calendar.current.dateComponents([.year, .month] , from: self.calendar.currentPage)
        let selectedMonth = Calendar.current.dateComponents([.year, .month], from: date)
        
        if currentPageYearMonth != selectedMonth {
            calendar.setCurrentPage(date, animated: true)
            print("현재 page: \(calendar.currentPage)")
        }
        print("날짜선택됨: \(date)")
        
        SelectedDate.shared.date = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = dateFormatter.string(from: date)
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
    
}


extension DayWorksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if DayWorks.shared.deleteWork(date: self.date, order: indexPath.row) {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                success(true)
            }
            success(false)
            
        })
        deleteAction.image = UIImage(named: "tick")
        deleteAction.backgroundColor = .purple
     
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DayWorksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayWorks.shared.worksArray.count + 1
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DayWorksTableViewCell else { return DayWorksTableViewCell() }
  
        cell.superTableView = self.tableView
        let numWorks = DayWorks.shared.worksArray.count
    
        if indexPath.row < numWorks {
            //목록cell
            cell.textField.text = DayWorks.shared.worksArray[indexPath.row].title
        } else {
            //입력cell
        }
        return cell
    }
}

