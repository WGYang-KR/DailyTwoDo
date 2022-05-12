//
//  InputViewController.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/05/10.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputBoxBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var superTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textField.delegate = self
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        view.addGestureRecognizer(tapGesture)
        
        //키보드 상태 옵저버
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.textField.becomeFirstResponder()
    }
    
    
    
    @objc func dismiss(_ sender: Any?) {
        self.dismiss(animated: true)
    }
    
    //MARK: - 키보드 올라올 때 inputBox 따라 올라가기
    @objc func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
            self.inputBoxBottomMargin.constant = keyboardHeight
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardDidShow(_ sender: Notification) {
       
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        self.inputBoxBottomMargin.constant = 0
        
    }
        
    //MARK: - 완료버튼 클릭: 할일 등록
    @IBAction func touchUpInsideCompleteButton(_ sender: UIButton)
    {
        
       
        if let title = self.textField.text, title != "" {
            //데이터 등록
            if DayWorks.shared.newWork(title: title) {
                //테이블뷰 업데이트
                superTableView.reloadData()
            }
            
         
        }
        
        //창 종료
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

extension InputViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
         if let title = self.textField.text, title != "" {
             //데이터 등록
             if DayWorks.shared.newWork(title: title) {
                 //테이블뷰 업데이트
                 superTableView.reloadData()
                 self.textField.text = ""
             }
             
         }
        
        return false
    }

}

