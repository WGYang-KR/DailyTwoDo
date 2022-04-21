//
//  CoreDataManager.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/14.
//

import Foundation
import UIKit
import CoreData

class DayWorks {
    
    static let shared: DayWorks = DayWorks()
    private init() {
        
    }
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    let modelName: String = "WorksCoreData"
    var date: Date = Date() //오늘 날짜로 초기화
    
    lazy var day: DayMo = {
        return self.getDayMo(date: date)
    }()
    
    lazy var worksArray: [WorkMo] = {
        return self.getWorksArray(day: self.day)
    }()
    
    //필요기능
    // 1. 할일 추가. addWork
    // 2. 할일 제거. removeWork
    // 3. 할일 내용 수정. updateWorkTitle
    // 4. 할일 상태 수정. updateWorkStatus
    // 5. 할일 날짜 이동. updateWorkDate
    // 6. 할일 순서 이동. updateWorkOrder
    // 7. 그 날 할일,메모 조회. getDay
    // 8. 그 날 메모 수정. updateDayMemo
    func setDate(date: Date) {
        self.day = self.getDayMo(date: date)
        self.worksArray = getWorksArray(day: self.day)
        self.date = date
    }
    
    func getWorksArray(day: DayMo) -> [WorkMo] {
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: true)
        return self.day.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
    }
    
    
    //yyyy-MM-dd HH:mm:ss -> yyyy-MM-dd
    func strDateOnly(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd "
        let result = dateFormatter.string(from: date)
        print("returned by strDateOnly: \(result)")
        return result
    }
    
    
    //날짜에 해당하는 DayMo 조회
    //수정 계획 : 날짜 24:00:00 <, > 날짜 00:00:00 형태로 조회
    func getDayMo(date:Date) -> DayMo {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        
        let pred = NSPredicate(format: "date == %@",strDateOnly(date: date) )
        
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
    //수정 계획: 날짜 00:00:00으로 추가 되는 지 확인.
    func newDayMo(date: Date) -> DayMo {
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Day", into: context)
        object.setValue(strDateOnly(date:date), forKey:"date")
        
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
    
    func newWork(title: String) -> Bool {
        newWork(date: self.date, title: title, status: nil)
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
        
        dayMo.addToWorks(workMo) //저장소에 추가
        
        self.worksArray.append(workMo) //배열에 추가
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }

    func editWork(ofDate: Date, ofOrder: Int, changeTitle: String) -> Bool {
        
        
        let day = getDayMo(date: ofDate)
        print(day.works)
        guard let work = day.works?.filter({($0 as! WorkMo).order == Int16(ofOrder)}).first else {
            print("editWork: 해당 하는 work 없음")
            return false
        }
        
        guard let currentWork = work as? WorkMo else {
            print("WorkMo변화 실패")
            return false
        }
        
        currentWork.title = changeTitle
        
        do { try context.save()
            return true
        }
        catch {
            context.rollback()
            return false
        }
        
    }
    
    func deleteWork(date: Date, order: Int) -> Bool {
        
        let day = getDayMo(date: date)
        guard let work = day.works?.filter({($0 as! WorkMo).order == Int16(order)}).first else {
            print("deleteWork: 해당 하는 work 없음")
            return false
        }
        
        context.delete(work as! NSManagedObject)
        
        do {
            try context.save()
            //제거된 빈자리 order 정렬 필요.
            self.worksArray.remove(at: order)
            resetWorksOrder(day: day)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func resetWorksOrder(day: DayMo) -> Bool {
        
        
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: true)
        let worksArray = day.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
        
        for (i, work) in worksArray.enumerated() {
            
            work.order = Int16(i)
        }
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
        
    }
}
