//
//  ViewController.swift
//  Save Using CoreData
//
//  Created by PARMJIT SINGH KHATTRA on 18/6/20.
//  Copyright © 2020 PARMJIT SINGH KHATTRA. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var companyName = [Company]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
        loaditems()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        companyName.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyCell", for: indexPath)
        let company = companyName[indexPath.row]
        cell.textLabel?.text = company.name
        cell.accessoryType = company.done ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        companyName[indexPath.row].setValue("completed", forKey: "name")
//        companyName[indexPath.row].done = !companyName[indexPath.row].done
        context.delete(companyName[indexPath.row])
        companyName.remove(at: indexPath.row)
        saveItems()
    }
    @IBAction func addCompany(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Company", message: "Company Name", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "your company name"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            let newCompany = Company(context: self.context)
            newCompany.name = textField.text
            newCompany.done = false
            newCompany.parentCategory = self.selectedCategory
            self.companyName.append(newCompany)
            self.saveItems()
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func saveItems(){
        do {
           try context.save()
        } catch  {
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    func loaditems(with request: NSFetchRequest<Company> = Company.fetchRequest()) {
        //let request : NSFetchRequest<Company> = Company.fetchRequest()
        do {
           companyName = try context.fetch(request)
        } catch {
            print("Error\(error)")
        }
        tableView.reloadData()
    }
}
// MARK:- SearchBar
extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Company> = Company.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loaditems(with: request)

        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loaditems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

