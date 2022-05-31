//
//  ViewController.swift
//  core-data
//
//  Created by adamszlosarczyk on 20/05/2022.
//

import UIKit
import CoreData

class PersonCell: UITableViewCell {
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var pesel: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var addPersonButton: UIAlertAction?
    var addPersonFirstNameTextField: UITextField?
    var addPersonLastNameTextField: UITextField?
    var addPersonPeselTextField: UITextField?
    
    var editPersonButton: UIAlertAction?
    var editPersonFirstNameTextField: UITextField?
    var editPersonLastNameTextField: UITextField?
    var editPersonPeselTextField: UITextField?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var items: [Person]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonCell
        
        let person = self.items![indexPath.row]
        
        cell.firstName.text = person.imie
        cell.lastName.text = person.nazwisko
        cell.pesel.text = person.pesel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items![indexPath.row]
        
        let alert = UIAlertController(title: "Edycja osoby", message: "Edycja imienia, nazwiska i peselu", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        self.editPersonFirstNameTextField = alert.textFields![0]
        self.editPersonFirstNameTextField!.text = person.imie
        self.editPersonLastNameTextField = alert.textFields![1]
        self.editPersonLastNameTextField!.text = person.nazwisko
        self.editPersonPeselTextField = alert.textFields![2]
        self.editPersonPeselTextField!.text = person.pesel
        
        self.editPersonFirstNameTextField!.placeholder = "Imie"
        self.editPersonLastNameTextField!.placeholder = "Nazwisko"
        self.editPersonPeselTextField!.placeholder = "PESEL"
        
        self.editPersonFirstNameTextField!.addTarget(self, action: #selector(editTextChanged), for: .editingChanged)
        self.editPersonLastNameTextField!.addTarget(self, action: #selector(editTextChanged), for: .editingChanged)
        self.editPersonPeselTextField!.addTarget(self, action: #selector(editTextChanged), for: .editingChanged)
        
        let cancelButton = UIAlertAction(title: "Anuluj", style: .cancel)
        self.editPersonButton = UIAlertAction(title: "Zapisz", style: .default) { (action) in
            let firstName = alert.textFields![0].text
            let lastName = alert.textFields![1].text
            let pesel = alert.textFields![2].text
            
            person.imie = firstName
            person.nazwisko = lastName
            person.pesel = pesel
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchPeople()
        }
    
        alert.addAction(cancelButton)
        alert.addAction(self.editPersonButton!)
        
        self.present(alert, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        fetchPeople()
    }
    
    func fetchPeople() {
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            let sort = NSSortDescriptor(key: "nazwisko", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }
    
    @IBAction func addPerson(_ sender: Any) {
        let alert = UIAlertController(title: "Dodaj osobe", message: "Podaj imie, nazwisko i pesel", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        self.addPersonFirstNameTextField = alert.textFields![0]
        self.addPersonLastNameTextField = alert.textFields![1]
        self.addPersonPeselTextField = alert.textFields![2]
        self.addPersonFirstNameTextField!.placeholder = "Imie"
        self.addPersonLastNameTextField!.placeholder = "Nazwisko"
        self.addPersonPeselTextField!.placeholder = "PESEL"
        self.addPersonFirstNameTextField!.addTarget(self, action: #selector(addTextChanged), for: .editingChanged)
        self.addPersonLastNameTextField!.addTarget(self, action: #selector(addTextChanged), for: .editingChanged)
        self.addPersonPeselTextField!.addTarget(self, action: #selector(addTextChanged), for: .editingChanged)
        
        self.addPersonButton = UIAlertAction(title: "Dodaj", style: .default) { (action) in
            let firstNameField = alert.textFields![0]
            let lastNameField = alert.textFields![1]
            let peselField = alert.textFields![2]
            
            let newPerson = Person(context: self.context)
            newPerson.imie = firstNameField.text
            newPerson.nazwisko = lastNameField.text
            newPerson.pesel = peselField.text
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchPeople()
        }
        self.addPersonButton!.isEnabled = false
        
        alert.addAction(self.addPersonButton!)
        alert.addAction(UIAlertAction(title: "Anuluj", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTextChanged() {
        if (isPeselValid(PESEL: self.addPersonPeselTextField!.text!) && checkText(text: self.addPersonFirstNameTextField!.text!) && checkText(text: self.addPersonLastNameTextField!.text!)) {
            self.addPersonButton!.isEnabled = true
        } else {
            self.addPersonButton!.isEnabled = false
        }
    }
    
    @objc func editTextChanged() {
        if (isPeselValid(PESEL: self.editPersonPeselTextField!.text!) && checkText(text: self.editPersonFirstNameTextField!.text!) && checkText(text: self.editPersonLastNameTextField!.text!)) {
            self.editPersonButton!.isEnabled = true
        } else {
            self.editPersonButton!.isEnabled = false
        }
    }
    
    func checkText(text: String) -> Bool {
        if text.count < 3 {
            return false
        }
        for char in text {
            if !char.isLetter {
                return false
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Usun") { (action, view, completionHanlder) in
            let personToRemove = self.items![indexPath.row]
            
            self.context.delete(personToRemove)
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchPeople()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func isPeselValid(PESEL: String) -> Bool {
        if PESEL.count != 11 {
            return false
        }
        for char in PESEL {
            if !char.isNumber {
                return false
            }
        }
        
        let datePart = String(PESEL.prefix(6))
        let yearSuffix = String(datePart.prefix(2))
        let day = Int(String(datePart.suffix(2))) ?? 0
        var month = Int(String(datePart.suffix(4).prefix(2))) ?? 0
        
        var yearPrefix = ""
        if month >= 81 && month <= 92 {
            yearPrefix = "18"
            month -= 80
        } else if month >= 1 && month <= 12 {
            yearPrefix = "19"
        } else if month >= 21 && month <= 32 {
            yearPrefix = "20"
            month -= 20
        } else if month >= 41 && month <= 52 {
            yearPrefix = "21"
            month -= 40
        } else if month >= 61 && month <= 72 {
            yearPrefix = "22"
            month -= 60
        } else {
            return false
        }
        
        let year = Int(yearPrefix + yearSuffix)!
        
        var daysByMonth: [Int: Int] = [
            1: 31,
            2: 28,
            3: 31,
            4: 30,
            5: 31,
            6: 30,
            7: 31,
            8: 31,
            9: 30,
            10: 31,
            11: 30,
            12: 31
        ]
        
        if checkIfLeapYear(year: year) {
            daysByMonth[2] = 29
        }
        
        if day > daysByMonth[month]! {
            return false
        }
        
        if (calculateControlSum(PESEL: PESEL) % 10 != 0) {
            return false
        }
        
        return true
    }

    func checkIfLeapYear(year: Int) -> Bool {
        return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
    }

    func calculateControlSum(PESEL: String) -> Int {
        let multipliers = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3, 1]
        var index = 0
        var sum = 0
        for char in PESEL {
            sum += multipliers[index] * char.wholeNumberValue!
            
            index += 1
        }
        
        return sum
    }
}

