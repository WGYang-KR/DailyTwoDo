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
        print("init")
        self._selectedDate = Date()
    }
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private lazy var context = appDelegate.persistentContainer.viewContext
   
    lazy var days: [DayMo] = {
        print("days 처음 호출")
        return self.getDays()
    }()
    
    private var _selectedDate: Date
    var selectedDate: Date {
        get {
            print("selectedDate 호출")
            return _selectedDate
        }
        
        set(value) {
            print("selectedDate 변경")
            _selectedDate = value
            //selectedDay, selectedWorks 갱신
            self.selectedDay = getDay(date: value)
            self.selectedWorks = getWorks(day: self.selectedDay)
        }
    }
    
    lazy var selectedDay: DayMo = {
        print("selectedDay 처음 호출")
        return self.getDay(date: self.selectedDate)
    }()
    lazy var selectedWorks: [WorkMo] = {
        print("selectedWorks 처음 호출")
        return self.getWorks(day: self.selectedDay)
    }()
    
    
    private func getDays() -> [DayMo] {
        print("getDays()호출")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]

        do {
            let result:[NSManagedObject] = try context.fetch(fetchRequest)
            if let days = result as? [DayMo] {
                print("getDays 완료.")
                return days
            } else {
                print("getDays 변환 실패")
                return []
            }
        } catch {
            print("[DayMo] DB조회 실패")
            return []
        }
    }
    
    
    private func getWorks(day: DayMo) -> [WorkMo] {
        print("getWorks 호출")
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: true)
        
        return day.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
    }
    
    func changeStatus(ofOrder: Int , status: Status) -> Bool {
        print("changeStatus()호출 order:\(ofOrder), status:\(status)")
        
        let day = selectedDay
        guard let work = day.works?.filter({($0 as! WorkMo).order == Int16(ofOrder)}).first else {
            print("changeStatus: 해당 하는 work 없음")
            return false
        }
        
        guard let currentWork = work as? WorkMo else {
            print("WorkMo변화 실패")
            return false
        }
        
        currentWork.status = status
        
        do { try context.save()
            return true
        }
        catch {
            context.rollback()
            return false
        }
        
    }
    
    //yyyy-MM-dd HH:mm:ss -> yyyy-MM-dd
    private func strDateOnly(date: Date) -> String {

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
    private func getDay(date:Date) -> DayMo {
        print("getDay()호출")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        
        let pred = NSPredicate(format: "date == %@",strDateOnly(date: date) )
        
        fetchRequest.predicate = pred
        
        do {
            let result:[NSManagedObject] = try context.fetch(fetchRequest)
            if let dayMo = result.first as? DayMo {
                print("getDay 완료.")
                return dayMo
            } else {
                print("fetch 결과에 DayMo 없음")
                return newDay(on: date)
            }
             
        } catch {
            print("DayMo DB조회 실패")
            return newDay(on: date)
        }
        
    }
    
    //새로운 dayMo 추가
    //수정 계획: 날짜 00:00:00으로 추가 되는 지 확인.
    private func newDay(on: Date) -> DayMo {
        print("newDay()호출")
        let object = NSEntityDescription.insertNewObject(forEntityName: "Day", into: context)
        object.setValue(strDateOnly(date: on), forKey:"date")
        
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
        print("newWork()호출")
        return newWork(date: self.selectedDate, title: title, status: nil)
    }
    //새로운 work 추가
    private func newWork(date: Date, title: String, status: Status?) -> Bool {
        print("newWork(date:)호출")
        let status:Status = status ?? .inComplete
        
        let dayMo:DayMo = getDay(date: date)
        
        guard let workMo = NSEntityDescription.insertNewObject(forEntityName: "Work", into: context) as? WorkMo else {
            print("updateWork:insertNewObject 실패")
            return false
        }
        workMo.title = title
        workMo.status = status
        workMo.order = Int16(dayMo.works?.count ?? 0)
        
        dayMo.addToWorks(workMo) //저장소에 추가
        
        self.selectedWorks.append(workMo) //배열에 추가
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }

    func editWork(ofOrder: Int, changeTitle: String) -> Bool {
        print("editWork()호출")
        let day = selectedDay
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
    
    func deleteWork(order: Int) -> Bool {
        print("deleteWork호출")
        let day = self.selectedDay
        guard let work = day.works?.filter({($0 as! WorkMo).order == Int16(order)}).first else {
            print("deleteWork: 해당 하는 work 없음")
            return false
        }
        
        context.delete(work as! NSManagedObject)
        
        do {
            try context.save()
            //제거된 빈자리 order 정렬 필요.
            self.selectedWorks.remove(at: order)
            reorderWorks(ofDay: day)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    

    
    private func reorderWorks(ofDay: DayMo) -> Bool {
        print("reorderWorks()호출")
        let sortDescription: NSSortDescriptor =  NSSortDescriptor(key: "order", ascending: true)
        let worksArray = selectedDay.works?.sortedArray(using: [sortDescription]) as? [WorkMo] ?? []
        
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
    
    
    func moveWork(moveWorkAt sourceIndex: Int, to destinationDate: Date, completion: @escaping () -> Void ) {
        
        let srcDayMo = getDay(date: self.selectedDate)
        let destDayMo = getDay(date: destinationDate)
        let workMoWillMove = self.selectedWorks[sourceIndex]
        
        srcDayMo.removeFromWorks(workMoWillMove)
        destDayMo.addToWorks(workMoWillMove)
        
        
        self.selectedWorks.remove(at: sourceIndex)
        //재정렬
        for (index, item) in self.selectedWorks.enumerated() {
            item.order = Int16(index)
        }
        
        DispatchQueue.main.async {
            completion()
        }
        
    }
    
    func moveWork(moveWorkAt sourceIndex: Int, to destinationIndex: Int) -> Bool {
        
        
        let moveCell = self.selectedWorks[sourceIndex]
        self.selectedWorks.remove(at: sourceIndex)
        self.selectedWorks.insert(moveCell, at: destinationIndex )
        
        for (index, item) in self.selectedWorks.enumerated() {
            item.order = Int16(index)
        }
        
        /*
        let day = selectedDay
        
        guard let sourceWork: WorkMo = day.works?.filter({($0 as! WorkMo).order == Int16(sourceIndex)}).first as? WorkMo else {
            print("moveWork: 해당 하는 source work 없음")
            return false
        }
        guard let destinationWork: WorkMo = day.works?.filter({($0 as! WorkMo).order == Int16(destinationIndex)}).first as? WorkMo  else {
            print("moveWork: 해당 하는 destination work 없음")
            return false
        }
        
        sourceWork.order = Int16(destinationIndex)
        destinationWork.order = Int16(sourceIndex)
        */
        
        do { try context.save()
            return true
        }
        catch {
            context.rollback()
            return false
        }
    }
    
    func addGuide() {
        
        let guides: [String] = [
            "🗓데일리투두 사용법🗓",
            "할일 추가: + 버튼을 눌러서 할일을 추가해요.",
            "할일 수정: 할일을 탭하면 수정화면으로 이동해요.",
            "할일 삭제: 할일을 왼쪽으로 쓸어넘겨서 삭제해요.",
            "순서 변경: 할일을 꾸욱 눌러서 이동해요",
            "달력 모드: 달력을 아래로 쓸어내려서 펼쳐요"
        ]
       
        let status: Status = .inComplete
        let dayMo: DayMo = getDay(date: Date() )
        
        for guide in guides {
            guard let workMo = NSEntityDescription.insertNewObject(forEntityName: "Work", into: context) as? WorkMo else {
                print("updateWork:insertNewObject 실패")
                return
            }
            
            workMo.title = guide
            workMo.status = status
            workMo.order = Int16(dayMo.works?.count ?? 0)
            
            dayMo.addToWorks(workMo) //저장소에 추가
        }
  
        
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
