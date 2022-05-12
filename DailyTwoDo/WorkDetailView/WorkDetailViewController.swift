//
//  WorkDetailViewController.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/05/11.
//

import UIKit

class WorkDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    var order: Int!
    var parentTableView: UITableView!
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd "
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //MARK: 델러게이트 연결
        titleTextField.delegate = self
        
        //MARK: Set labels
        dateLabel.text = dateFormatter.string(from: DayWorks.shared.selectedDate)
        let currentWork = DayWorks.shared.selectedWorks[order]
        titleTextField.text = currentWork.title
        StatusImageManager.setImageOfButton(self.statusButton, status: currentWork.status)
        
        
        //MARK: 배경 클릭 시 모든 편집 종료
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEdit(_:)))
        self.view.addGestureRecognizer(tapGesture)

    }
    
    @objc func endEdit(_ sender: Any) {
        self.view.endEditing(true)
    }
                                                
    
    @IBAction func touchUpInsideBackButton(_ sender: UIButton){

        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WorkDetailViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //할일 업데이트
        var text = ""
        if let textInTextfield = textField.text {
            text = textInTextfield
        }
        DayWorks.shared.editWork(ofOrder: order, changeTitle: text)
        self.parentTableView.reloadData()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
