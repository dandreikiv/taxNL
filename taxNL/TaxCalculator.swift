//
//  TaxCalculator.swift
//  taxNL
//
//  Created by dmytro.andreikiv@philips.com on 23/06/16.
//  Copyright © 2016 A-Level. All rights reserved.
//

import Foundation

typealias TaxLevel = (limit: Double, tax: Double)

/// Maximum tax for income which exceeds amont from last bracket.
private let maxTax: Double = 52

/**
    The calculator makes calculations of net income according to the dutch
    tax brackets [for 2016](http://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/boxen_en_tarieven/overzicht_tarieven_en_schijven/u_hebt_in_2016_de_aow_leeftijd_nog_niet_bereikt)
 */
final class TaxCalculator: NSObject {

    func incomeTaxWith(salary: Double, taxLevels: [TaxLevel]) -> Double {
        
        var incomeTax: Double = 0
        var taxedSalary: Double = 0
        
        for level in taxLevels {
            
            if salary > level.limit {
                incomeTax   = incomeTax + (level.limit - taxedSalary) * (level.tax / 100)
                taxedSalary = taxedSalary + (level.limit - taxedSalary)
            } else {
                incomeTax   = incomeTax + (salary - taxedSalary) * (level.tax / 100)
                taxedSalary = salary
                break
            }
        }
        
        if (taxedSalary < salary) {
            incomeTax = incomeTax + (salary - taxedSalary) * (maxTax / 100)
        }
        
        return (incomeTax)
    }
}
