//
//  NewOrderViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

class NewOrderViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()
    var selectedItem: String = String()
    var delegate : ItemSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Popup
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.showAnimate()
        
        //Picker
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = [Constants.kSweaters,
                      Constants.kFood,
                      Constants.kShoes,
                      Constants.kHygieneProducts,
                      Constants.kClothes]
    }
    
    
    // MARK: - UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // MARK: - UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = pickerData[row]
    }
    
    // MARK: - Save Button
    @IBAction func save(_ sender: Any) {
        selectedItem = selectedItem == "" ? pickerData[0] : selectedItem
        
        self.removeAnimate()
        self.delegate?.didPressSaveWithSelectItem(selectedItem)
    }
    
    // MARK: - Cancel Button
    @IBAction func cancel(_ sender: Any) {
        self.removeAnimate()
    }
    
    // MARK: - New Donation's Popup
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
