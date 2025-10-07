//
//  Date + Extension.swift

//
//   Created by Nikunj Vaghela on 30/09/21.
//  Copyright © 2023 Nikunj Vaghela. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self))) ?? Date()
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth()) ?? Date()
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        return formatter.string(from: yourDate ?? Date())
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func last7daysDate(days: Int) -> [String] {
        var result: [String] = []
        for offset in 1...abs(days) {
            let currentDate = adding(days: offset * (days < 0 ? -1 : 1))
            let formatter = DateFormatter()
            formatter.dateFormat = "d \nMMM"
            let formattedDate = formatter.string(from: currentDate)
            result.append(formattedDate)
        }
        return result
    }
}

extension Calendar {
    
    func dayOfWeek(_ date: Date) -> Int {
        var dayOfWeek = self.component(.weekday, from: date) + 1 - self.firstWeekday
        
        if dayOfWeek <= 0 {
            dayOfWeek += 7
        }
        
        return dayOfWeek
    }
    
    func startOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: -self.dayOfWeek(date) + 1), to: date) ?? Date()
    }
    
    func endOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: 6), to: self.startOfWeek(date)) ?? Date()
    }
    
    func startOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date)) ?? Date()
    }
    
    func endOfMonth(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(date)) ?? Date()
    }
    
    func startOfQuarter(_ date: Date) -> Date {
        let quarter = (self.component(.month, from: date) - 1) / 3 + 1
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: (quarter - 1) * 3 + 1)) ?? Date()
    }
    
    func endOfQuarter(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 3, day: -1), to: self.startOfQuarter(date)) ?? Date()
    }
    
    func startOfYear(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year], from: date)) ?? Date()
    }
    
    func endOfYear(_ date: Date) -> Date {
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: 12, day: 31)) ?? Date()
    }
    
    func previousMonth(_ date: Date) -> Date{
        return self.date(byAdding: .month, value: -1, to: date) ?? Date()
    }
    
    func nextMonth(_ date: Date) -> Date{
        return self.date(byAdding: .month, value: 1, to: date) ?? Date()
    }
    
    func previousWeek(_ date: Date) -> Date{
        return self.date(byAdding: .weekOfYear, value: -1, to: date) ?? Date()
    }
    
    func nextWeek(_ date: Date) -> Date{
        return self.date(byAdding: .weekOfYear, value: 1, to: date) ?? Date()
    }
    
    func previousDay(_ date: Date) -> Date{
        return self.date(byAdding: .day, value: -1, to: date) ?? Date()
    }
    
    func nextDay(_ date: Date) -> Date{
        return self.date(byAdding: .day, value: 1, to: date) ?? Date()
    }
    
    func startOfDay(_ date: Date) -> Date{
        return self.startOfDay(for: date)
    }
    
    func endOfDay(_ date: Date) -> Date{
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(date)) ?? Date()
    }
    
   
}
