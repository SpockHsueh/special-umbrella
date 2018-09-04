//
//  ViewController.swift
//  FireBase_AppWorks_6
//
//  Created by Spoke on 2018/9/3.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    
    @IBOutlet weak var articleTitleTxt: UITextField!
    @IBOutlet weak var articleContent: UITextView!
    @IBOutlet weak var addFriendTxt: UITextField!
    
    let client = APIClient()
    var ref: DatabaseReference!
    let tagItem = ["表特", "八卦", "就可", "生活"]
    var articleTag = "表特"
    var selectTag = "表特"
    let authorId = "Develop_iOS_test_com"
    var tag: String?
    let decoder = JSONDecoder()
    var articleData = ArticleData()
    var articleArray: [String] = []
    var mycheckFriend = [Any]()
    var mycheckFriendDic = [String:Bool]()
    var personcheckFriendDic = [String:Bool]()
    var myFriend = ""
    var myJSONData: Data?

    

    override func viewDidLoad() {
        super.viewDidLoad()

        client.findUser { (data, error) in
            print(data!)
            print(error)
        }
        
        ref = Database.database().reference()
        
        friendRequest()

    }
    
    func friendRequest() {
        ref.child("user/\(authorId)/checkFriend").observe(.childAdded) { (snapshot) in
                print(snapshot.key)
                self.friendRequestAlert(message: "\(snapshot.key) 要加您為好友")
            self.myFriend = (snapshot.key as? String)!
            }
    }
    
    @IBAction func showFriend(_ sender: Any) {
        ref.child("user/\(authorId)")
            .queryOrdered(byChild: "friend")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? [String: Any] else { return }
                print(value)
                guard let dictionary = value["friend"] as? [String: Bool] else { return }
                print("myFriend: \(dictionary)")

            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    
    @IBAction func addFriend(_ sender: Any) {

        if addFriendTxt.text == "" {
            showAlertWith(message: "Please enter the UserID")
            
        } else {
            getMyCheckFriend()
        }
    }
    
    func getMyCheckFriend() {
        ref.child("user/\(authorId)")
            .queryOrdered(byChild: "checkFriend")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? [String: Any] else { return }
                guard let dictionary = value["checkFriend"] as? [String: Bool] else { return }
                
                    print("myFriend \(dictionary)")
                self.mycheckFriendDic = dictionary
                
                self.mycheckFriendDic["\(self.addFriendTxt.text!)"] = true
                    print(self.mycheckFriendDic)
                self.selfAddFriend()

            }) { (error) in
                print(error.localizedDescription)
        }
        
        ref.child("user/\(addFriendTxt.text!)")
            .queryOrdered(byChild: "checkFriend")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? [String: Any] else { return }
                guard let dictionary = value["checkFriend"] as? [String: Bool] else { return }
                
                print("personFriend \(dictionary)")
                self.personcheckFriendDic = dictionary
                
                self.personcheckFriendDic["\(self.authorId)"] = false
                print(self.personcheckFriendDic)
                self.persinAddFriend()

            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    
    func getPersonCheckFriend() {
        ref.child("user/\(addFriendTxt.text!)")
            .queryOrdered(byChild: "checkFriend")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? [String: Any] else { return }
                guard let dictionary = value["checkFriend"] as? [String: Bool] else { return }
                
                print("personFriend \(dictionary)")
                self.personcheckFriendDic = dictionary
                
                self.personcheckFriendDic["\(self.authorId)"] = false
                print(self.personcheckFriendDic)
                
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func persinAddFriend() {
        
        print(personcheckFriendDic)
        ref.child("user/\(addFriendTxt.text!)/checkFriend").setValue(personcheckFriendDic) {
            
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Self successfully!")
            }
        }
    }
    
    
    func selfAddFriend() {
        
        ref.child("user/\(authorId)/checkFriend").setValue(mycheckFriendDic) {
                
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Self successfully!")
                }
        }
    }
    
    @IBAction func showArticle(_ sender: Any) {

        ref.child("article")
            .queryOrdered(byChild: "author").queryEqual(toValue: authorId)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let value = snapshot.value as? [String: Any] else { return }
                var page = 1
                print("------------------------")
                print("ShowArticle")
                for code in value.keys {

                    print("第\(page)筆資料")
                    guard let dictionary = value["\(code)"] as? [String: Any] else { return }
                    print("tag: \(dictionary["tag"] as! String)")
                    print("title:  \(dictionary["title"] as! String)")
                    print("authorId: \(dictionary["author"] as! String)")
                    print("created_time: \(dictionary["created_time"])")
                    print("content: \(dictionary["content"] as! String)")
                    print("-----")
                    page += 1
                }
                print("------------------------")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func showTag(_ sender: Any) {
        
        ref.child("article")
            .queryOrdered(byChild: "tag").queryEqual(toValue: selectTag)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value as? [String: Any] else { return }
                print(value)
                var page = 1
                print("------------------------")
                print("ShowTagArticle")
                for code in value.keys {
                    print(code)
                    print("第\(page)比資料")
                    guard let dictionary = value["\(code)"] as? [String: Any] else { return }
                    print("tag: \(dictionary["tag"] as! String)")
                    print("title:  \(dictionary["title"] as! String)")
                    print("authorId: \(dictionary["author"] as! String)")
                    print("created_time: \(dictionary["created_time"])")
                    print("content: \(dictionary["content"] as! String)")
                    print("-----")
                    page += 1
                }
                print("------------------------")

            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    
    @IBAction func searchTag(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        selectTag = tagItem[index]
    }
    
    
    @IBAction func articleTag(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        articleTag = tagItem[index]
    }
    
    
    @IBAction func articlepost(_ sender: Any) {
        
            if articleTitleTxt.text == "" && articleContent.text == "" {
                showAlertWith(message: "Please enter your Title and Content")
                
            } else {
                
                let articleKey = ref.child("article").childByAutoId().key

                ref.child("article/\(articleKey)").setValue([
                    "title": "\(articleTitleTxt.text!)",
                    "content": "\(articleContent.text!)",
                    "tag": articleTag as NSString,
                    "author": authorId,
                    "created_time": Date().millisecondsSince1970]) {
                        
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        self.showAlertWith(message: "Data could not be saved")
                        print("Data could not be saved: \(error).")
                    } else {
                        self.showAlertWith(title: "Successee", message: "Successfully saved!")
                        self.cleanScreen()
                        print("Data saved successfully!")
                    }
                }
            }
        }
    

    
    func showAlertWith(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func friendRequestAlert(title: String = "Friend Request", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.ref.child("user/\(self.authorId)/friend/\(self.myFriend)").setValue(true) {
                
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Self successfully!")
                }
            }
            
        }
        let cancle = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancle)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func cleanScreen() {
        articleTitleTxt.text = ""
        articleContent.text = ""
        addFriendTxt.text = ""
    }

    
}

extension Date {
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}



class ArticleData: NSObject {
    var author: String?
    var content: String?
    var created_time: String?
    var tag: String?
    var title: String?
}
