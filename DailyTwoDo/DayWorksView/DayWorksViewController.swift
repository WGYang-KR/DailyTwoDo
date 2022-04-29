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
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier: String = "DayWorksCell"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //MARK: - 화면 클릭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        tapGesture.cancelsTouchesInView = false //인식하고, view로도 보냄
        view.addGestureRecognizer(tapGesture)

        
        //MARK: - calendar 초기 세팅

        // 한달 단위(기본값)
        calendar.scope = .month
        // 일주일 단위
        calendar.scope = .week
        calendar.select(DayWorks.shared.selectedDate) //오늘 날짜 선택
      
        calendar.appearance.caseOptions =  FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.locale = Locale(identifier:"ko_KR") //Locale.current.identifier
        print(calendar.locale)
        // 헤더 폰트 설정
        calendar.appearance.headerTitleFont = UIFont.nanum(size: 10, family: .Regular)
        // Weekday 폰트 설정
        calendar.appearance.weekdayFont = UIFont.nanum(size: 10, family: .Regular)
        // 각각의 일(날짜) 폰트 설정 
        calendar.appearance.titleFont = UIFont.nanum(size: 12, family: .Regular)
        
        //MARK: - NavigationItem 초기 세팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = dateFormatter.string(from: DayWorks.shared.selectedDate)
        
        //MARK: 스와이프 시 달력 높이 조정
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeEvent(_ swipe: UISwipeGestureRecognizer) {

        if swipe.direction == .up {
            calendar.setScope(.week, animated: true)
        }
        else if swipe.direction == .down {
            calendar.setScope(.month, animated: true)
        }
        
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
        
        //네비게이션아이템 타이틀 업데이트
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = dateFormatter.string(from: date)
        
        //day works 다시 로드
        print("날짜 선택 반영")
        DayWorks.shared.selectedDate = date
        print("날짜 선택 반영 완료")
        self.tableView.reloadData()
    }
    
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
           
            calendarHeight.constant = bounds.height
            UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
            }
        
    }
    
}


extension DayWorksViewController: UITableViewDelegate {
    
    //MARK: - 셀 Swipe 삭제 기능 구현
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if DayWorks.shared.deleteWork(order: indexPath.row) {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                success(true)
            }
            success(false)
            
        })
        deleteAction.image = UIImage(named: "tick")
        deleteAction.backgroundColor = .purple
     
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //MARK: - 테이블 스크롤 시 달력 크기 변경
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        //위로 스크롤
        if yVelocity < 0 {
            //위로 스크롤
            //달력 .week로
            calendar.setScope(.week, animated: true)
            
        }
        else if yVelocity > 0 {
            //아래로 스크롤
                //테이블 최상단이면 달력 .month로
                let contentYoffset = scrollView.contentOffset.y
                print("contentYoffset: \(contentYoffset)")
                if contentYoffset <= 0 {
                
                    calendar.setScope(.month, animated: true)
                }
        }
    }
    
    //MARK: - 셀 선택 시 텍스트필드 활성화
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? DayWorksTableViewCell else {
            return
        }
        print("didSelectRowAt called")
        cell.textField.becomeFirstResponder()
    }

   
    
}

extension DayWorksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayWorks.shared.selectedWorks.count + 1
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DayWorksTableViewCell else { return DayWorksTableViewCell() }
  
        cell.superTableView = self.tableView
        
        let numWorks = DayWorks.shared.selectedWorks.count
    
        if indexPath.row < numWorks {
            //목록cell
            cell.textField.text = DayWorks.shared.selectedWorks[indexPath.row].title
            cell.status = DayWorks.shared.selectedWorks[indexPath.row].status
            cell.rightButton.isHidden = false
            StatusImageManager.setImageOfButton(cell.rightButton, status: cell.status)
            
        } else {
            //입력cell
            cell.textField.text = ""
            cell.status = .inComplete
            cell.rightButton.isHidden = true
        }
        return cell
    }
}
