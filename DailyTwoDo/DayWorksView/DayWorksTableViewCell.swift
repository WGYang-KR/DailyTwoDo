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
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let cellRow = self.superTableView.indexPath(for: self)
        print("textField DidEndEditing of cellRow:\(cellRow) ")
        //datacore에 해당 데이터 저장하도록 호출.
        DayWorks.shared.newWork(title: textField.text ?? "")
        superTableView.reloadData()
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
