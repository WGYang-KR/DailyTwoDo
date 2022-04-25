//
//  TodayWorkListTableViewCell.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/13.
//

import UIKit

class DayWorksTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! //할일 내용
    @IBOutlet weak var rightButton: UIButton! //할일 상태 표시 및 변경 호출
    weak var superTableView: UITableView! //셀이 속한 테이블뷰
    
    @IBAction func touchUpInsideRightButton(_ sender: UIButton) {
        print("사각형 클릭됨")
        //선택상자 출력
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        guard let cellRow = self.superTableView.indexPath(for: self) else {
            print("셀 위치 찾기 실패")
            return
            
        }
        print("텍스트필드 편집완료. cellRow:\(cellRow) ")
        
        //수정필요:: 마지막 칸이면 추가, 아니면 수정 실행.
        if cellRow.row < DayWorks.shared.selectedWorks.count {
        
            print("수정실행")
            if DayWorks.shared.editWork(ofOrder: cellRow.row, changeTitle: textField.text ?? "") {
                print("수정완료")
                superTableView.reloadRows(at: [cellRow], with: .none)
            }
            
        
        } else {
            print("생성실행")
            DayWorks.shared.newWork(title: textField.text ?? "")
            superTableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
        
    }
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
