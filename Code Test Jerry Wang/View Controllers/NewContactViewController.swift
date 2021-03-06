//
//  NewContactViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/24/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import CoreData

struct NewContact {
        let firstName: String
        let lastName: String?
        let uniqueID: String?
        let dob: Date?
        let phone: String?
        let email: String?
        let address: String?
        let profilePicture: UIImage?
}


class NewContactViewController: UIViewController{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    var currentTextField: UITextField?
    
    var textFields: [UITextField]?
    
    @IBOutlet weak var imageView: UIImageView!
    
    var profilePicture: UIImage?
    
    var datePicker: Date?
    
    var coreDataManager: CoreDataManager!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegates()
        
        //tapping outside of keyboard causes dismissal
        let keyboardTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDismissTapped))
        view.addGestureRecognizer(keyboardTapRecognizer)
        
        //tapping on imageview prompts image picker
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setProfilePicture))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNewContactVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveContactTapped))
        self.title = "New Contact"
        
        //add notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    deinit{
        //remove notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //move the scrollview up when the keyboard blocks the current text field
    //https://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 50, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect : CGRect = self.view.frame
        viewRect.size.height -= keyboardSize!.height
        if let activeField = self.currentTextField {
            if (!viewRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.view.endEditing(true)
    }
    
    @objc func dismissNewContactVC(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardDismissTapped(){
        view.endEditing(true)
    }

    
    //check for validity of contact info. If valid, pass info to homeVC and dismiss. Else, throw up an alert VC telling the user what went wrong.
    @objc func saveContactTapped() {
        if let firstName = firstNameTextField.text, !firstName.isEmpty{
            let uniqueID = UUID.init().uuidString
            
            let lastName = lastNameTextField.text
            
            let validDate = datePicker
            
            let phone = phoneTextField.text
            
            let email = emailTextField.text
            
            let address = addressTextField.text
            
            let profilePicture = self.profilePicture
            
            let newContact = NewContact(firstName: firstName, lastName: lastName, uniqueID: uniqueID, dob: validDate, phone: phone, email: email, address: address, profilePicture: profilePicture)
            coreDataManager.createNew(contact: newContact)
        } else {
            let ac = UIAlertController(title: "Please enter a first name!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        dismissNewContactVC()
        
    }
}

//textfield delegate functions
extension NewContactViewController: UITextFieldDelegate{
    
    
    func setTextFieldDelegates(){
        textFields = [firstNameTextField,lastNameTextField,dateOfBirthTextField,emailTextField,addressTextField,phoneTextField]
        textFields?.forEach{ $0.delegate = self }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    ////if d.o.b field is selected, present a datepicker instead.
    //courtesy Natalia Terlecka, https://stackoverflow.com/questions/11197855/iphone-display-date-picker-on-uitextfield-touch/11198489#11198489
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTextField = textField
        if textField.placeholder == "date of birth"{
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(updateTextFieldWithDate(sender:)), for: .valueChanged)
            textField.inputView = datePicker
            textField.text = formatForView(date: datePicker.date)
        }
    }
    //update the d.o.b text field with the date picked by the datepicker
    @objc func updateTextFieldWithDate(sender: UIDatePicker){
        dateOfBirthTextField.text = formatForView(date: sender.date)
    }
    
    //given a Date object, return its string representation as MMM dd, yyyy
    func formatForView(date: Date) -> String{
        datePicker = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from:date)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
    }
    
}

//image picker delegate functions
extension NewContactViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        imageView.image = image
        profilePicture = image
        
    }
    
    @objc func setProfilePicture(){
        let alertVC = UIAlertController(title: nil, message: "Pick a profile picture", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: takePhoto)
        let photoLibraryAction = UIAlertAction(title: "Photos Library", style: .default, handler: pickPhoto)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoLibraryAction)
        alertVC.addAction(cancelAction)
        
        //popover presentation is used on iPads to specify origin of alertVC popup.
        alertVC.popoverPresentationController?.sourceView = self.view
        alertVC.popoverPresentationController?.sourceRect = imageView.frame
        
        present(alertVC, animated: true)
    }
    
    func takePhoto(action: UIAlertAction){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    func pickPhoto(action: UIAlertAction){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc,animated: true)
    }
}
