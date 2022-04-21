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
    var selectedDate: Date {
        get {
            if let selectedDate = self.calendar.selectedDate {
                return selectedDate
            } else {
                let currentDate = Date()
                self.calendar.select(currentDate) //현재 날짜 지정
                return currentDate
            }
        }
    }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //MARK: - 화면 클릭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        tapGesture.cancelsTouchesInView = false //인식하고, view로도 보냄
        view.addGestureRecognizer(tapGesture)

        
        print("worksArray: \(DayWorks.shared.worksArray)")
        print("worksInDay: \(DayWorks.shared.day.works)")
        
        //MARK: - calendar 초기 세팅
        calendar.select(SelectedDate.shared.date) //오늘 날짜 선택
        calendar.appearance.caseOptions =  FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.locale = Locale(identifier:"ko_KR") //Locale.current.identifier
        print(calendar.locale)
        
        //MARK: - NavigationItem 초기 세팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = dateFormatter.string(from: SelectedDate.shared.date)
        
    }
}

extension DayWorksViewController: FSCalendarDelegate{
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print("날짜선택됨: \(date)")
        
        //선택된 날짜가 현재 페이지가 아니면 해당 페이지로 이동
        let currentPageYearMonth = Calendar.current.dateComponents([.year, .month] , from: self.calendar.currentPage)
        print("currentPageYearMonth: \(currentPageYearMonth)")
        let selectedMonth = Calendar.current.dateComponents([.year, .month], from: date)
        if currentPageYearMonth != selectedMonth {
            calendar.setCurrentPage(date, animated: true)
            print("현재 page: \(calendar.currentPage)")
        }
        
        
        //날짜 업데이트
        SelectedDate.shared.date = date
        
        //네비게이션아이템 타이틀 업데이트
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = dateFormatter.string(from: date)
        
        //day works 다시 로드
        DayWorks.shared.setDate(date: SelectedDate.shared.date)
        self.tableView.reloadData()
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
            if DayWorks.shared.deleteWork(date: SelectedDate.shared.date, order: indexPath.row) {
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
            cell.textField.text = ""
        }
        return cell
    }
}

