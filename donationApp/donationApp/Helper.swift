//
//  Helper.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 17/08/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

typealias SelectedBlock = (Int) -> Void

class Helper: NSObject {

    // MARK: - Date helpers
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
    
    static func periodBetween(date1: Date, date2: Date) -> String {
        var period = ""
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .month, .year], from: date1, to: date2)
        
        let minutes = components.minute
        let hours = components.hour
        let days = components.day
        
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
    
    // MARK: - String helpers
    static func institutionAddress(_ institution: Institution) -> String {
        let address = institution.address + ", " + institution.district + ", " + institution.city + " - " + institution.state + ". Cep: " + institution.zipCode
        
        if address != "" && address != ", ,  - . Cep: "{
            return address
        } else {
            return "-"
        }
    }
    
    static func institutionUserAddress(_ institutionUser: InstitutionUser) -> String {
        let address = institutionUser.address + ", " + institutionUser.district + ", " + institutionUser.city + " - " + institutionUser.state + ". Cep: " + institutionUser.zipCode
        
        if address != "" && address != ", ,  - . Cep: "{
            return address
        } else {
            return "-"
        }
    }
}
