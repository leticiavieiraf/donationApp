//
//  Helper.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 17/08/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

class Helper: NSObject {

    static func periodBetween(date1: Date, date2: Date) -> String {
        
        var period = ""
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .month, .year], from: date1, to: date2)
        
        let minutes = components.minute
        let hours = components.hour
        let days = components.day
//        let months = components.month
//        let years = components.year
        
//        if let years = years {
//            if (years > 0) {
//                let title = (years > 1) ? " anos" : " ano"
//                period = String(years) + title
//                return period
//            }
//        }
//        
//        if let months = months {
//            if (months > 0) {
//                let title = (months > 1) ? " meses" : " mês"
//                period = String(months) + title
//                return period
//            }
//        }
        
        if let days = days {
            if (days > 0) {
                if (days > 20) {
                    period = stringFrom(date: date1, format: "dd MMM yyyy")
                    return period.lowercased()
                }
                let title = (days > 1) ? " dias" : " dia"
                period = "há " + String(days) + title
                return period
            }
        }
        
        if let hours = hours {
            if (hours > 0) {
                let title = (hours > 1) ? " horas" : " hora"
                period = "há " + String(hours) + title
                return period
            }
        }
        
        if let minutes = minutes {
            if (minutes > 0) {
                period = "há " + String(minutes) + " min"
                return period
            }
        }
        return "Agora"
    }
    
    static func dateFrom(string: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: string)
        
        return (date != nil) ? date! : Date()
    }
    
    static func stringFrom(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        
        let string = dateFormatter.string(from: date)
        
        return string
    }
    
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default)
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
