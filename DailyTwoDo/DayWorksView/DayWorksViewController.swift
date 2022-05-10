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
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    let cellIdentifier: String = "DayWorksCell"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.tableView.dragInteractionEnabled = true
        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self
        
        //MARK: - 화면 클릭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(self.resignFirstResponder))
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
        
        //MARK: 키보드 올라올 때 테이블뷰 크기 조정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
              
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)

    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
            self.tableViewBottomMargin.constant = keyboardHeight
            
           
        }
    }
    @objc func keyboardDidShow(_ sender: Notification) {
        //현재 firstResponder가 속한 행으로 초점 이동.
        if let selectedRow = self.tableView.indexPathForSelectedRow
        {
            self.tableView.scrollToRow(at: selectedRow, at: .top, animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.tableViewBottomMargin.constant = 0 // Move view to original position
    }
    
    @objc func swipeEvent(_ swipe: UISwipeGestureRecognizer) {

        if swipe.direction == .up {
            calendar.setScope(.week, animated: true)
        }
        else if swipe.direction == .down {
            calendar.setScope(.month, animated: true)
        }
        
    }
    
    @IBAction func touchUpInsideAddButton(_ sender: UIButton) {
        
        //InputView를 띄운다.
        let inputViewController = InputViewController()
        inputViewController.modalPresentationStyle = .overFullScreen
        inputViewController.modalTransitionStyle = .crossDissolve
        self.present(inputViewController, animated: true)
        
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
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        customNavigationItem.title = formatter.string(from: calendar.currentPage) 
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
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        //달력 줄이기
        calendar.setScope(.week, animated: true)
        if let curSelectedIndex = tableView.indexPathForSelectedRow, indexPath == curSelectedIndex {
            print("같은 행 클릭")
            return indexPath
        } else {
            print("다른행 클릭")
            //모든 행 선택 해제.
            //텍스트필드 비활성
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        print("willDeselect")
        return indexPath
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            print("\(sourceIndexPath.row) -> \(destinationIndexPath.row)")
    
        if DayWorks.shared.moveWork(moveWorkAt: sourceIndexPath.row, to: destinationIndexPath.row) {
            print("셀 이동 DB반영 완료")
        }
    }
 
}

extension DayWorksViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }

}

extension DayWorksViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        //if inner drop, do insert.
        if session.localDragSession != nil {
               return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        //if a drop from out of app, cancel.
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
       
    }
    
}
