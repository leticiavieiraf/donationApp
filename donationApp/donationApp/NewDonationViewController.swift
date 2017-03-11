//
//  NewDonationViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

class NewDonationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()
    var selectedItem: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Popup
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.showAnimate()
        
        //Picker
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["Agasalhos", "Alimentos não-perecíveis", "Calçados", "Produtos de Higiene", "Roupas"]
    }
    
    
    // UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewDataSource
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
     // UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20.0
    }
    
    // UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedItem = pickerData[row]
    }
    
    //Save Button
    @IBAction func save(_ sender: Any) {
        print(self.selectedItem)
    }
    
    
    // Cancel Button
    @IBAction func cancel(_ sender: Any) {
        self.removeAnimate()
    }
    
    //Popup
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
