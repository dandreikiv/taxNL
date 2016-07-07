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

    /**
     The method calculates income tax.
     
     ```
     Tarieven box 1 (werk en woning) in 2016 AOW-leeftijd nog niet bereikt
     
     Schijf     Belastbaar inkomen              Percentage
     
     1          t/m   € 19.922                  36,55%  (8.4% + 28.15% AOW)
     2          Vanaf € 19.923 t/m € 33.715     40,4%   (12.25% + 28.15% AOW)
     3          Vanaf € 33.716 t/m € 66.421     40,4%
     4          Vanaf € 66.422                  52%
     ```
     */
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
    
    func incomeTaxWith(income: Double) -> Double {
        
        let rate1: Double = 36.55
        let rate2: Double = 40.4
        let rate3: Double = 40.4
        let rate4: Double = 52
        
        if income < 19992 {
            return income * rate1 / 100
        }
        else if income < 33715 {
            return (19992 * rate1 / 100) + (income - 19992) * rate2 / 100
        }
        else if income < 66421 {
            return
                  (19992 * rate1 / 100)
                + (33715  - 19992) * rate2 / 100
                + (income - 33715) * rate3 / 100
        }
        else {
            return
                  (19992 * rate1 / 100)
                + (33715  - 19992) * rate2 / 100
                + (66421  - 33715) * rate3 / 100
                + (income - 66421) * rate4 / 100
        }
    }
    
    /**
     The method calcualates General Old Age Pensions **Algemene Ouderdomswet (AOW)**
     
     ```
     Year   AOW's rate
     2016   17.90%
     ```
     - parameters:
        - income:   taxable income.
     
     - returns: 
     Calculated AOW amount.
     */
    func socialSecurityAOW(income: Double) -> Double {
        
        var taxableIncome: Double = income
        
        if income > 33715 {
            taxableIncome = 33715
        }
        
        return (taxableIncome * 17.9) / 100
    }
    
    /**
     The method calcualates **Algemene nabestaandenwet (Anw)**
     
     ```
     Year   Anw's rate
     2016   0.60%
     ```
     - parameters:
        - income:   taxable income.
     
     - returns:
     Calculated Anw amount.
     */
    func socialSecurityANW(income: Double) -> Double {
        
        var taxableIncome: Double = income
        
        if income > 33715 {
            taxableIncome = 33715
        }
        
        return (taxableIncome * 0.6) / 100
    }
    
    /**
     The method calcualates **Wet langdurige zorg (WLZ)**
     
     ```
     Year   WLZ's rate
     2016   9.65%
     ```
     - parameters:
        - income:   taxable income.
     
     - returns:
     Calculated WLZ amount.
     */
    func socialSecurityWLZ(income: Double) -> Double {
        
        var taxableIncome: Double = income
        
        if income > 33715 {
            taxableIncome = 33715
        }
        
        return (taxableIncome * 9.65) / 100
    }
    
    /**
     Calculates labor credit depends on income and retirement.
     
     ```
     The calculation for a person who is not retired yet.
     
     €0 ......... € 9.147       1,793%  x income
     € 9.147  ... € 19.758      € 164 + 27,698% x (income - € 9.147)
     € 19.758 ... € 34.015      € 3.103
     € 34.015 ... € 111.590     € 3.103 - 4% x (income - € 34.015)
     € 111.590 ............     € 0
     
     The calculation for a person, who is already retired.
     
     €0 ......... € 9.147       0,915%  x income
     € 9.147  ... € 19.758      € 84 + 14,133% x (income - € 9.147)
     € 19.758 ... € 34.015      € 1.585
     € 34.015 ... € 111.590     € 1.585 - 2,041% x (income - € 34.015)
     € 111.590 ............     € 0
     
     ```
     
     - parameters:
        - income:    Employee's annual income
        - isRetired: Indicates if a person is already retired.
     
     - returns:
     Calculated labor credit.
     */
    func laborCredit(income: Double, isRetired: Bool) -> Double {
        var result: Double = 0
        
        /// The calculation for a person who is not retired yet.
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
        
            /// The calculation for a person who is already retired.
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
    
    /**
     Calculates general credit depends on income and retirement.
     
     ```
     The calculation for a person who is not retired yet.
     
     €0 ......... € 19.922      € 2.242
     € 19.922 ... € 66.417      € 2.242 - 4,822% x (income - € 19.922)
     € 66.417 ...........       € 0
     
     The calculation for a person who is already retired.
     
     €0 ......... € 19.922      € 1.145
     € 19.922 ... € 66.417      € 1.145 - 2,460% x (belastbaar inkomen uit werk en woning - € 19.922)
     € 66.417 ...........       € 0
     
     ```
     
     - parameters:
        - income:       Employee's annual income
        - isRetired:    Indicates if a person is already retired.
     
     - returns:
     Calculates general credit
     */
    func generalCredit(income: Double, isRetired: Bool) -> Double {
        var result: Double = 0
    
        /// The calculation for a person who is not retired yet.
        if (isRetired == false) {
            if income < 19922 {
                result = 2242
            }
            else if income < 66417 {
                result = 2242 - 4.822 * (income - 19922) / 100
            }
        }
        else {
            
            /// The calculation for a person who is already retired.
            if income < 19922 {
                result = 1145
            }
            else if income < 66417 {
                result = 1145 - 2.460 * (income - 19922) / 100
            }    
        }
        
        return (result)
    }
}
