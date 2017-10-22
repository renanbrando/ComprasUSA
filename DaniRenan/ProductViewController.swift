//
//  ProductViewController.swift
//  DaniRenan
//
//  Created by Renan Ribeiro Brando on 13/10/17.
//  Copyright © 2017 Renan Ribeiro Brando. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var stCard: UISwitch!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!
    //PickerView que será usado como entrada para o textField de Gênero
    var pickerView: UIPickerView!
    
    //Objeto que servirá como fonte de dados para alimentar o pickerView
    var dataSource:[State] = []
    
    // MARK:  Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView() //Instanciando o UIPickerView
        pickerView.backgroundColor = .white
        pickerView.delegate = self  //Definindo seu delegate
        pickerView.dataSource = self  //Definindo seu dataSource
        
        //Criando uma toobar que servirá de apoio ao pickerView. Através dela, o usuário poderá
        //confirmar sua seleção ou cancelar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão abaixo servirá para o usuário cancelar a escolha do estado, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        //Aqui definimos que o pickerView será usado como entrada do textField
        tfState.inputView = pickerView
        
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfState.inputAccessoryView = toolbar
        
        //Carrega o dataSource com os estados
        loadStates()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage(tapGestureRecognizer:)))
        ivImage.isUserInteractionEnabled = true
        ivImage.addGestureRecognizer(tapGestureRecognizer)
        
        if product != nil {
            tfName.text = product.name
            tfValue.text = "\(product.value)"
            tfState.text = product.states?.name
            stCard.setOn(product.card, animated: false)
            if let image = product.image as? UIImage {
                ivImage.image = image
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    func cancel() {
        
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim
        //com que o teclado (pickerView) desapareça da tela
        tfState.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component
        //em nosso pickerView)
        tfState.text = dataSource[pickerView.selectedRow(inComponent: 0)].name
        
        cancel()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }

    
    // MARK: - IBActions
    @IBAction func addImage(tapGestureRecognizer: UITapGestureRecognizer) {
        
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func registerProduct(_ sender: Any) {
        if product == nil {
            product = Product(context: context)
        }
        
        if (tfName.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite o nome do produto.", ViewController: self, toFocus:tfName)
            return
        } else {
            product.name = tfName.text
        }
        
        if (tfState.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Escolha um estado.", ViewController: self, toFocus:tfState)
            return
        } else {
             product.states = dataSource[pickerView.selectedRow(inComponent: 0)]
        }
        
        if (tfValue.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite um valor para o produto.", ViewController: self, toFocus:tfValue)
            return
        } else {
            product.value = Double(tfValue.text!)!
        }
        
        
        product.card = stCard.isOn
        if smallImage != nil {
            product.image = smallImage
        }
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }

    }
    
    func alertWithTitle(title: String!, message: String, ViewController: UIViewController, toFocus:UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        });
        alert.addAction(action)
        ViewController.present(alert, animated: true, completion:nil)
    }

    
    // MARK:  Methods
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension ProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 278, height: 134.5)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImage.image = smallImage //Atribuindo a imagem à ivPoster
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}

extension ProductViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return dataSource[row].name
    }
}

extension ProductViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    //Usaremos apenas 1 coluna (component) em nosso pickerView
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count //O total de linhas será o total de itens em nosso dataSource
    }
}

