//
//  CoreDataManager.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/14.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    lazy var context = appDelegate.persistentContainer.viewContext
    
    let modelName: String = "WorksCoreData"
    
    //필요기능
    // 1. 할일 추가. addWork
    // 2. 할일 제거. removeWork
    // 3. 할일 내용 수정. updateWorkTitle
    // 4. 할일 상태 수정. updateWorkStatus
    // 5. 할일 날짜 이동. updateWorkDate
    // 6. 할일 순서 이동. updateWorkOrder
    // 7. 그 날 할일,메모 조회. getDay
    // 8. 그 날 메모 수정. updateDayMemo
    
    //yyyy-MM-dd HH:mm:ss -> yyyy-MM-dd
    func getStrFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        print(date)
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let result = dateFormatter.string(from: date) + "*"
        print("returned by getStrFromDate: \(result)")
        return result
    }
    
    func removeTimeFromDate(date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let strDate = dateFormatter.string(from: date)
        guard let date = dateFormatter.date(from: strDate) else {
            print("Date 시간 제거 실패")
            return Date()
        }
        print("returned by removeTimeFromeDate: \(date)")
        return date
    }
    
    
    //날짜에 해당하는 DayMo 조회
    func getDayMo(date:Date) -> DayMo {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        
        let pred = NSPredicate(format: "date like %@", getStrFromDate(date: date) )
        
        fetchRequest.predicate = pred
        
        do {
            let result:[NSManagedObject] = try context.fetch(fetchRequest)
            if let dayMo = result.first as? DayMo {
                print("getDayMo 완료.")
                return dayMo
            } else {
                print("fetch 결과에 DayMo 없음")
                return newDayMo(date: date)
            }
             
        } catch {
            print("DayMo DB조회 실패")
            return newDayMo(date: date)
        }
        
    }
    
    //새로운 dayMo 추가
    func newDayMo(date: Date) -> DayMo {
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Day", into: context)
        object.setValue(removeTimeFromDate(date: date), forKey:"date")
        
        do{
            try context.save()
            print("새 Day 생성완료")
            return object as! DayMo
        } catch {
            context.rollback()
            print("새 Day 생성실패")
            fatalError("새 DayMo 생성 실패")
        }
        
    }
    
    //새로운 work 추가
    func newWork(date: Date, title: String, status: Status?) -> Bool {
        let status:Status = status ?? .inComplete
        
        let dayMo:DayMo = getDayMo(date: date)
        
        guard let workMo = NSEntityDescription.insertNewObject(forEntityName: "Work", into: context) as? WorkMo else {
            print("updateWork:insertNewObject 실패")
            return false
        }
        workMo.title = title
        workMo.status = Int16(status.rawValue)
        workMo.order = Int16(dayMo.works?.count ?? 0)
        
        dayMo.addToWorks(workMo)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }


}
