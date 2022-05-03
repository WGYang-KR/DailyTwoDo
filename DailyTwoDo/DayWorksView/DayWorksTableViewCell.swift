//
//  TodayWorkListTableViewCell.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/13.
//

import UIKit

class DayWorksTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! //할일 내용
    @IBOutlet weak var rightButton: UIButton! //할일 상태 표시 및 변경 호출
    var superTableView: UITableView! //셀이 속한 테이블뷰
    var status: Status!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
     
       
        
    }
    
    @objc func doneBtnFromKeyBoardClicked(_ sender : Any ) {
        textField.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
        // Initialization code
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIButton.init(type: .custom)
        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.gray, for: .normal)
        doneButton.backgroundColor = .lightGray
        doneButton.layer.cornerRadius = 10
        doneButton.addTarget(self, action: #selector(doneBtnFromKeyBoardClicked(_:)), for: .touchUpInside)
        doneButton.frame = CGRect.init(x: 0, y: 0, width: 50, height: 30)
        let barDoneButton = UIBarButtonItem.init(customView: doneButton)
        toolBar.items = [barDoneButton]
        print("cell init실행")
        textField.inputAccessoryView = toolBar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if !self.textField.isEditing, selected == true {
            self.textField.becomeFirstResponder()
        }
       
    }

    
    @IBAction func touchUpInsideRightButton(_ sender: UIButton) {
        
        print("상태 클릭됨")
        
        guard let cellIndexPath = self.superTableView.indexPath(for: self) else {
            print("셀 위치 찾기 실패")
            return
        }
        
        let statusAlertController = StatusAlertController(currentStatus: status, cellOrder: cellIndexPath.row, currentCell: self)
        if let rootVC = self.window?.rootViewController {
            statusAlertController.present(inViewController: rootVC, animated: true)
        } else {
            print("rootVC 미존재")
        }
   
    }
    
    //MARK: 다음 칸으로 커서 이동
    func moveNextRow(_ tableView: UITableView, From indexPath: IndexPath) {
        var nextIndexPath = indexPath
        nextIndexPath.row += 1
        
        if let nextCell = tableView.cellForRow(at: nextIndexPath) as? DayWorksTableViewCell  {
            tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            nextCell.textField.becomeFirstResponder()
            
        }

    }
    
}

extension DayWorksTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        guard let cellRow = self.superTableView.indexPath(for: self) else {
            print("셀 위치 찾기 실패")
            return
            
        }
        print("텍스트필드 편집완료. cellRow:\(cellRow) ")
        
        //중간 칸이면 수정, 마지막 칸이면 생성
        if cellRow.row < DayWorks.shared.selectedWorks.count {
        
            //할일 내용 수정 실행. 내용 없으면 삭제.
            if let newText = textField.text, newText != "" {
                print("할일 수정 실행")
                if DayWorks.shared.editWork(ofOrder: cellRow.row, changeTitle: newText) {
                    print("할일 수정 성공")
                    superTableView.reloadRows(at: [cellRow], with: .none)
                    //다음 칸으로 커서 이동
                    //moveNextRow(superTableView, From: cellRow)
                    
                }
            }  else {
                print("내용 없음->할일 삭제")
                if DayWorks.shared.deleteWork(order: cellRow.row) {
                    print("할일 삭제 성공")
                    superTableView.deleteRows(at: [cellRow], with: .none)
                    //다음 칸으로 커서 이동
                    //moveNextRow(superTableView, From: cellRow)
                }
            }
        }
        else {
            print("할일 생성 실행")
            if let newText = textField.text, newText != "" {
                if DayWorks.shared.newWork(title: newText) {

                    //테이블 새로고침
                    superTableView.reloadData()
                    //마지막 칸으로 커서 이동
                    //moveNextRow(superTableView, From: cellRow)
                }
            }
      
           
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        guard let cellRow = self.superTableView.indexPath(for: self) else {
            print("셀 위치 찾기 실패")
            return false
        }
        textField.resignFirstResponder()
        moveNextRow(superTableView, From: cellRow)
        return false
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let cellRow = self.superTableView.indexPath(for: self) {
            self.superTableView.scrollToRow(at: cellRow, at: .top, animated: true)
        }
    
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        guard let firstResponder = superTableView.window?.firstResponder else { return true }
        
        //현재 firstResponder가 textField이면 입력해제
        if let currentTextField = firstResponder as? UITextField {
            print("firstResponder가 텍스트필드")
            currentTextField.resignFirstResponder()
            return false
        } else {
            print("firstResponder가 텍스트필드 아님")
            return true
        }

        return true
    }
}


