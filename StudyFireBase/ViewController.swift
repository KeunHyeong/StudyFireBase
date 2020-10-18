//
//  ViewController.swift
//  StudyFireBase
//
//  Created by KeunHyeong on 2020/10/18.
//  Copyright © 2020 KeunHyeong. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var numberOfCustomers: UILabel!
    let db = Database.database().reference()
    
    var customers:[Customer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updataLabel()
    }
    
    func updataLabel(){
        db.child("firstData").observeSingleEvent(of: .value) { snapshot in
            print("--->\(snapshot)")
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.dataLabel.text = value
            }
        }
    }
    @IBAction func createCustomer(_ sender: Any) {
        saveCustomers()
    }
    @IBAction func fetchCustomer(_ sender: Any) {
        fetchCustomers()
    }
    
    func  updateCustomers(){
        guard customers.isEmpty == false else{ return }
        customers[0].name = "Son"
        
        let dictionary = customers.map{ $0.toDic }
        db.updateChildValues(["customers":dictionary])
    }
    
    @IBAction func updateCustomer(_ sender: Any) {
        updateCustomers()
    }
    @IBAction func deleteCustomer(_ sender: Any) {
        db.child("customers").removeValue()
    }
}

extension ViewController{
    func saveBasicTypes(){
        //string, number, dictionary, array
        
        db.child("int").setValue(3)
        db.child("double").setValue(3.5)
        db.child("str").setValue("string value Hello")
        db.child("array").setValue(["a","b","c"])
        db.child("dic").setValue(["id":"ID","age":10])
    }
    
    func saveCustomers(){
        let books = [Book(title: "스위프트 프로그래밍", author: "야곰"),
        Book(title: "코딩인터뷰완전분석", author: "블라블라")]
        
        let customer1 = Customer(id: "\(Customer.id)", name: "Jang", books: books)
        Customer.id += 1
        let customer2 = Customer(id: "\(Customer.id)", name: "hong", books: books)
        Customer.id += 1
        let customer3 = Customer(id: "\(Customer.id)", name: "kim", books: books)
        Customer.id += 1
        
        db.child("customers").child(customer1.id).setValue(customer1.toDic)
        db.child("customers").child(customer2.id).setValue(customer2.toDic)
        db.child("customers").child(customer3.id).setValue(customer3.toDic)
    }
}

extension ViewController{
    func updateBasicTypes(){
        
//        db.child("int").setValue(3)
//        db.child("double").setValue(3.5)
//        db.child("str").setValue("string value Hello")
        
        db.updateChildValues(["int":6])
        db.updateChildValues(["double":10.6])
        db.updateChildValues(["str":"update str"])
        
    }
    func deleteBasicTypes(){
        db.child("int").removeValue()
        db.child("double").removeValue()
        db.child("str").removeValue()
    }
}

extension ViewController{
    func fetchCustomers(){
        db.child("customers").observeSingleEvent(of: .value) { snapshot in
            print("--->\(snapshot)")
            
            do{
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: [])
                let decoder = JSONDecoder()
                let customers:[Customer] = try decoder.decode([Customer].self, from: data)
                self.customers = customers
                DispatchQueue.main.async {
                    self.numberOfCustomers.text = "# of Customers:\(customers.count)"
                }
                
            }catch let error{
                print("--->error:\(error.localizedDescription)")
            }
        }
    }
}

struct Customer:Codable {
    let id:String
    var name:String
    let books:[Book]
    
    var toDic:[String:Any]{
        let booksArray = books.map{ $0.toDic }
        let dic:[String:Any] = ["id":id,"name":name,"books":booksArray]
        return dic
    }
    static var id:Int = 0
}

struct Book:Codable {
    let title:String
    let author:String
    
    var toDic:[String:Any]{
        let dic:[String:Any] = ["title":title,"author":author]
        return dic
    }
}
