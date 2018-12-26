//
//  ViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/20/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import CoreData
//enum TableViewSection:Int {
//    case A = 0, B, C, D, E, F, G, H, I , J, K,L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, Total
//}

struct User {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let email: [String]
    let phone: [String]?
    let address: [String]
}

class ContactsViewController: UITableViewController {
    
    var contactsArray = ["Keanu reeves","Matt Damon", "Alicia Vikander", "Julia Stiles","Margot Robbie", "Jared Leto", "Will Smith","Chris Pine", "Zachary Quinto", "Zoe Saldana","Ryan Reynolds", "Morena Baccarin", "Gina Carano","Gerard Butler", "Aaron Eckhart", "Morgan Freeman", "Angela Bassett","Kate McKinnon", "Leslie Jones", "Melissa McCarthy", "Kristen Wiig","Dwayne Johnson", "Kevin Hart","Mila Kunis", "Kristen Bell", "Kathryn Hahn", "Christina Applegate","Jordan Peele", "Keegan-Michael Key","Seth Rogen", "Rose Byrne","Mary Elizabeth Winstead", "John Goodman", "John Gallagher Jr.","Tom Hanks", "Sarita Choudhury","Jennifer Garner", "Kylie Rogers", "Martin Henderson"]
    var headers = ["A","B","C","D","E","F","G","H","I","J", "K","L","M", "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var sectionHeaderHeight = CGFloat(25)
    
    var firstCharToNameDict: [Character:[String]]?
    
    private var coreDataManager: CoreDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactTapped))
        //get our managed object context, the 'scratchpad' to jot down our CRUD operations on data before committing to persistent store
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        coreDataManager = CoreDataManager(context: context)
        
        //get the existing contacts
        if let currentContacts = coreDataManager?.contactsArray{
        
        //group the names by their first letter, to make table view loading much easier
        firstCharToNameDict = Dictionary(grouping: currentContacts, by: {$0.first!})
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let contacts = coreDataManager?.contactsArray {
            for contact in contacts {
                print(contact)
            }
        }
    }
    
    @objc func addContactTapped(){
        if let newContactVC = storyboard?.instantiateViewController(withIdentifier: "newContact") as? NewContactViewController{
            newContactVC.delegate = self
            navigationController?.pushViewController(newContactVC, animated: true)
        }
    }

    //return total number of sections in the tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return firstCharToNameDict?.keys.count ?? 0
    }
    
    //return height for section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //return title for the section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionKeys = firstCharToNameDict?.keys.sorted(){
            return String(sectionKeys[section])
        } else { return nil }
    }
    //return number of rows for every section (i.e number of names per prefix)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupByPrefixDictionary = firstCharToNameDict{
            let key = groupByPrefixDictionary.keys.sorted()[section]
            return (groupByPrefixDictionary[key]?.count ?? 0)
        }
        return 0
    }
    
    //define what data appears in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        if let groupByPrefixDictionary = firstCharToNameDict {
            let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
            if let sortedNames = groupByPrefixDictionary[key]?.sorted() {
                cell.textLabel?.text = sortedNames[indexPath.row]
            }
            cell.imageView?.image = UIImage(named: "neutralProfile.png")
        }
        return cell
    }
    //when a row is selected, instantiate the profile view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController{
            profileVC.userProfile = User(firstName: "Jerry", lastName: "Wang", dateOfBirth: "8-17-1991", email: ["jerry.wang.ct@gmail.com"], phone: ["7814720251","2032312615","2033874366"], address: ["19 Cedar Acres Rd"])
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

extension ContactsViewController: NewContactDelegate {
    func createNew(contact: DelegateContact) {
        coreDataManager?.createNewContact(firstName: contact.firstName, lastName: contact.lastName)
        let newContactName = "\(contact.firstName) \(contact.lastName)"
        contactsArray.append(newContactName)
        if firstCharToNameDict != nil, let firstChar = newContactName.first {
            var names = firstCharToNameDict?[firstChar] ?? []
            names.append(newContactName)
            firstCharToNameDict?[firstChar] = names
        }
        self.tableView.reloadData()
    }
}

//extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
//    //return total number of sections in the tableview
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return firstCharToNameDict?.keys.count ?? 0
//    }
//
//    //return height for section
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return sectionHeaderHeight
//    }
//
//    //return title for the section
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let sectionKeys = firstCharToNameDict?.keys.sorted(){
//            return String(sectionKeys[section])
//        } else { return nil }
//    }
//    //return number of rows for every section (i.e number of names per prefix)
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let groupByPrefixDictionary = firstCharToNameDict{
//            let key = groupByPrefixDictionary.keys.sorted()[section]
//            return (groupByPrefixDictionary[key]?.count ?? 0)
//        }
//        return 0
//    }
//
//    //define what data appears in each cell
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
//        if let groupByPrefixDictionary = firstCharToNameDict {
//            let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
//            if let sortedNames = groupByPrefixDictionary[key]?.sorted() {
//                cell.textLabel?.text = sortedNames[indexPath.row]
//            }
//            cell.imageView?.image = UIImage(named: "neutralProfile.png")
//        }
//        return cell
//    }
//    //when a row is selected, instantiate the profile view
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController{
//            profileVC.userProfile = User(firstName: "Jerry", lastName: "Wang", dateOfBirth: "8-17-1991", email: ["jerry.wang.ct@gmail.com"], phone: ["7814720251","2032312615","2033874366"], address: ["19 Cedar Acres Rd"])
//            navigationController?.pushViewController(profileVC, animated: true)
//        }
//    }
//
//}
