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
 *   The calculator makes calculations of net income according to the dutch
 *   tax brackets [for 2016](http://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/boxen_en_tarieven/overzicht_tarieven_en_schijven/u_hebt_in_2016_de_aow_leeftijd_nog_niet_bereikt)
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
    
    /**
     Calculates labor credit depends on income and retirement.
     
     - parameters:  
        - income:    brutto annual salary.
        - isRetired: indicates if a person is already retired.
     
     - returns:
     Calculated labor credit.
     */
    func laborCredit(income: Double, isRetired: Bool) -> Double {
        var result: Double = 0
        
        /**
         The calculation for a person who is not retired yet.
         
         €0 ......... € 9.147       1,793%  x income
         € 9.147  ... € 19.758      € 164 + 27,698% x (income - € 9.147)
         € 19.758 ... € 34.015      € 3.103
         € 34.015 ... € 111.590     € 3.103 - 4% x (income - € 34.015)
         € 111.590 ............     € 0
         */

        if isRetired == false {
            
            if income < 9147 {
                result = (1.793 * income) / 100
            }
            else if income < 19758 {
                result = 164 + 27.698 * (income - 9147) / 100
            }
            else if income < 34015 {
                result = 3103
            }
            else if income < 111590 {
                result = 3103 - 4 * (income - 34015) / 100
            }
        }
        else {
            /**
             The calculation for a person who is already retired.
             
             €0 ......... € 9.147       0,915%  x income
             € 9.147  ... € 19.758      € 84 + 14,133% x (income - € 9.147)
             € 19.758 ... € 34.015      € 1.585
             € 34.015 ... € 111.590     € 1.585 - 2,041% x (income - € 34.015)
             € 111.590 ............     € 0
             */
            
            if income < 9147 {
                result = (0.915 * income) / 100
            }
            else if income < 19758 {
                result = 84 + (14.133 * income) / 100
            }
            else if income < 34015 {
                result = 1585
            }
            else if income < 111590 {
                result = 1585 - 2.041 * (income - 34015) / 100
            }
        }
        
        return (result)
    }
}
