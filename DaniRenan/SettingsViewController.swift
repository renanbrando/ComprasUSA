//
//  FirstViewController.swift
//  DaniRenan
//
//  Created by Renan Ribeiro Brando on 05/10/17.
//  Copyright © 2017 Renan Ribeiro Brando. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfExchange: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    // MARK: - Properties
    var dataSource: [Category] = []
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tfExchange.text = UserDefaults.standard.string(forKey: "exchange")
        tfIOF.text = UserDefaults.standard.string(forKey: "iof")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editExchange(_ sender: Any) {
       
        UserDefaults.standard.set(tfExchange.text!, forKey: "exchange")
    }
   
    @IBAction func editIOF(_ sender: Any) {
        
        UserDefaults.standard.set(tfIOF.text!, forKey: "iof")
    }


}

