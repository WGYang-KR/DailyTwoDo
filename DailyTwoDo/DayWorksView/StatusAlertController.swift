//
//  StatusAlertController.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/27.
//

import UIKit


class StatusAlertController {
    
    private var alertController: UIAlertController!
    private let currentStatus: Status!
    private let cellOrder: Int!
    private let currentCell: DayWorksTableViewCell!
    private var actionDic: [Int: UIAlertAction] = [:]
    private var targetStatus: Status? = nil
    
    init(currentStatus: Status, cellOrder: Int, currentCell: DayWorksTableViewCell) {
        self.currentStatus = currentStatus
        self.cellOrder = cellOrder
        self.currentCell = currentCell
        alertController = UIAlertController(
            title: "할일상태변경",
            message: "현재상태: \(currentStatus)",
            preferredStyle: .alert
        )
        
        //MARK: Action 리스트 초기화
        var tempActionDic: [Int:UIAlertAction] = [:]
        let completeAction = UIAlertAction(title: "완료", style: .default, handler: { _ in
            self.targetStatus = .complete
            self.updateStatus()
            
        })
        tempActionDic[Status.complete.rawValue] = completeAction
        let onGoingAction = UIAlertAction(title: "진행중", style: .default) { _ in
            self.targetStatus = .onGoing
            self.updateStatus()
          
        }
        tempActionDic[Status.onGoing.rawValue] = onGoingAction
        let inCompleteAction = UIAlertAction(title: "미완료", style: .default, handler: { _ in
            self.targetStatus = .inComplete
            self.updateStatus()
        })
        tempActionDic[Status.inComplete.rawValue] = inCompleteAction
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            //취소 이동
        })
        
        tempActionDic[Status.allCases.count] = cancelAction //마지막
        
        actionDic = tempActionDic
        
        //MARK: 현재상태 제외한 Action만 추가.
        for (status,action) in actionDic.sorted(by: {$0.0 < $1.0}) {
            if status != currentStatus.rawValue {
                alertController.addAction(action)
            }
        }
    }
    
    private func updateStatus() {
        if let targetStatus = self.targetStatus {
            if DayWorks.shared.changeStatus(ofOrder: self.cellOrder, status: targetStatus) {
                print("진행상태 업데이트 완료")
                StatusImageManager.setImageOfButton(self.currentCell.rightButton, status: targetStatus)
                self.currentCell.status = targetStatus
            }
        }
        
    }
    
    
    
    func present(inViewController controller: UIViewController, animated: Bool) {
        controller.present(alertController, animated: animated)
    }
        
   
    
}
