//
//  ViewController.swift
//  Conventer
//
//  Created by adam musallam on 20.02.17.
//  Copyright © 2017 adam musallam. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
//Interface
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//Constants
    let currencies = [ "RUB" , "USD" , "EUR" , "AUD" , "BGN" , "BRL" , "CAD" , "CHF" , "CNY" , "CZK" , "DKK" , "GBP" , "HKD" , "HRK" , "HUF" , "IDR" , "ILS" , "INR" , "JPY" , "KRW" , "MXN" , "MYR" , "NOK" , "NZD" , "PHP" , "PLN" ,"RON" , "SEK" , "SGD" , "THB" , "TRY" , "ZAR" ]
    
    
//UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerTo{
            return self.currenciesExceptBase().count
        }
       return currencies.count
    }
    
//UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == pickerTo{
            return NSAttributedString(string:self.currenciesExceptBase()[row], attributes: [NSForegroundColorAttributeName:UIColor.orange])
        }

       return NSAttributedString(string: currencies[row], attributes: [NSForegroundColorAttributeName:UIColor.orange])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerTo{
            return self.currenciesExceptBase()[row]
        }
        
        return currencies[row]
    }
    
    
//For any value
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === pickerFrom{
            self.pickerTo.reloadAllComponents()
        }
        self.requestCurrentCurrencyRate()    }
    
//exeptBase
    
    func currenciesExceptBase()->[String]{
        var currenciesExceptBase = currencies
        currenciesExceptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        return currenciesExceptBase
    }
    
//requestCurrentCurrencyRate
    
    func requestCurrentCurrencyRate(){
        self.activityIndicator.startAnimating()
        self.label.text = ""
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = self.currencies[baseCurrencyIndex]
        let toCurrency = self.currenciesExceptBase()[toCurrencyIndex]
        
        self.retrieveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) {[weak self] (value)  in
            DispatchQueue.main.async(execute: {
                if let strongSelf = self{
                    
                    strongSelf.label.text = value
                    strongSelf.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
//Request
    
    func requestCurrencyRates(baseCurrency: String, parseHandler: @escaping(Data?,Error?)->Void){
        let url = URL(string: "https://api.fixer.io/latest?base="+baseCurrency)!
    
        let dataTask  = URLSession.shared.dataTask(with: url){
            (dataReceived,responce,error) in
            parseHandler(dataReceived,error)
        }
        dataTask.resume()
    }
    
//JSON-Serialization
    
    func parseCurrencyRatesResponse(data: Data?, toCurrency:String)-> String {
        var value : String = ""
        do{
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
            print("\(parsedJSON)")
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                        
                           }  else {
                              value = "No rate for currency \"\(toCurrency)\" found"
                    }
                } else {
                        value = "No \"rates\" field found"
            }
                }else {
                   value = "No JSON value parsed"
                    }
        }  catch {
                        value = error.localizedDescription
                    }
        
        return value
                }
    
    func retrieveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String)->Void){
        self.requestCurrencyRates(baseCurrency: baseCurrency){ [weak self] (data,error) in
            var string = "No currency retrieved"
            if let currentError = error{
                string = currentError.localizedDescription}
            else{
                if let strongSelf = self{
                    string = strongSelf.parseCurrencyRatesResponse(data: data, toCurrency: toCurrency)
                }
            }
            completion(string)
            }
        self.label1.text = "1 " + baseCurrency
        self.label2.text = toCurrency
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Тут будет курс"
        
        self.pickerTo.reloadAllComponents()
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.requestCurrentCurrencyRate()
                
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            }


}

