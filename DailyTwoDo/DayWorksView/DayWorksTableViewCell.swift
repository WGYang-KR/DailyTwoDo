//
//  TodayWorkListTableViewCell.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/13.
//

import UIKit

class DayWorksTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    weak var superTableView: UITableView!
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let cellRow = self.superTableView.indexPath(for: self)
        print("textField DidEndEditing of cellRow:\(cellRow) ")
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
