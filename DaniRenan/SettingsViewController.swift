//
//  FirstViewController.swift
//  DaniRenan
//
//  Created by Renan Ribeiro Brando on 05/10/17.
//  Copyright © 2017 Renan Ribeiro Brando. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add
    case edit
}

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfExchange: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var dataSource: [State] = []
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        loadStates()
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
        
        if (tfExchange.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite uma cotação.", ViewController: self, toFocus:tfExchange)
            return
        } else {
            UserDefaults.standard.set(tfExchange.text, forKey: "exchange")
        }
    }
   
    @IBAction func editIOF(_ sender: Any) {
        
        if (tfIOF.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite o IOF.", ViewController: self, toFocus:tfIOF)
            return
        } else {
            UserDefaults.standard.set(tfIOF.text, forKey: "iof")
        }
        
    }
    
    // MARK: - Methods
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(type: CategoryType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome da estado"
            if let name = state?.name {
                textField.text = name
            }
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Taxa do estado"
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = "\(tax)"
            }
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            
            if ((alert.textFields?.first?.text?.isEmpty)! || (alert.textFields?.last?.text?.isEmpty)!){
                self.alertWithTitle(title: "Erro", message: "Erro ao adicionar o estado", ViewController: self, toFocus: self.tfIOF)
                return 
            }
            else {
                state.name = alert.textFields?.first?.text
                state.tax = Double((alert.textFields?.last?.text)!)!
                do {
                    try self.context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func add(_ sender: Any) {
        showAlert(type: .add, state: nil)
    }
    
    func alertWithTitle(title: String!, message: String, ViewController: UIViewController, toFocus:UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        });
        alert.addAction(action)
        ViewController.present(alert, animated: true, completion:nil)
    }
   


}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, state: state)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax)"
        cell.accessoryType = .none
      
        return cell
    }

}

