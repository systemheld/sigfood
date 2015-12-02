//
//  ViewController.swift
//  Sigfood
//
//  Created by Kett, Oliver on 30.09.14.
//  Copyright (c) 2014 Kett, Oliver. All rights reserved.
//

// todo: 
// * delete menu older than 14 days
// * mark food without pork and veggie food
// * upload fotos and write comments

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // pull to refresh
    var refreshControl = UIRefreshControl()
    
    // now
    var date = NSDate()
    let oneDayinSeconds: Double = 24 * 60 * 60
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext // CoreData
    var data = [Menu]()
    var imageID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl.tintColor = UIColor(red: 0.016, green: 0.710, blue: 0.788, alpha: 1.00)
        self.refreshControl.addTarget(self, action: "forceUpdateDatabase", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        updateUITableView(force: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPrevious(sender: AnyObject) {
        self.date = self.date.dateByAddingTimeInterval(-oneDayinSeconds)
        updateUITableView(force: false)
    }
    
    @IBAction func showNext(sender: AnyObject) {
        self.date = self.date.dateByAddingTimeInterval(oneDayinSeconds)
        updateUITableView(force: false)
    }
    
    // MARK: TableView delegate
    // UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // we display one row even if there are no dishes
        if self.data.count == 0 {
            return 1
        } else {
            return data.count
        }
    }
    
    // here be dragons
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // no dishes found
        if self.data == [] {
            return tableView.dequeueReusableCellWithIdentifier("emptyCell")!
        }
        
        // if we have dishes
        let cell = tableView.dequeueReusableCellWithIdentifier("sigfoodCell") as! SigfoodTableViewCell
        let row = self.data[indexPath.row]
        
        cell.mainCourseLabel.text = row.mainCourse
        cell.priceGuest.text = row.priceGuest
        cell.priceStud.text = row.priceStudent
        cell.priceStaff.text = row.priceEmployee
        
        if row.image != nil {
            cell.foodImage.image = UIImage(data: row.image!)
        } else {
            cell.foodImage.image = UIImage(named: "nopictureavailable.png")
        }
        cell.foodImage.clipsToBounds = true
        cell.foodImage.contentMode = .ScaleAspectFill
        
        if row.score?.doubleValue > 0.5 {
            cell.star1.image = UIImage(named: "observe.png)")
        } else {
            cell.star1.image = UIImage(named: "observe-grey.png")
        }
        if row.score?.doubleValue > 1.5 {
            cell.star2.image = UIImage(named: "observe.png)")
        } else {
            cell.star2.image = UIImage(named: "observe-grey.png")
        }
        if row.score?.doubleValue > 2.5 {
            cell.star3.image = UIImage(named: "observe.png)")
        } else {
            cell.star3.image = UIImage(named: "observe-grey.png")
        }
        if row.score?.doubleValue > 3.5 {
            cell.star4.image = UIImage(named: "observe.png)")
        } else {
            cell.star4.image = UIImage(named: "observe-grey.png")
        }
        if row.score?.doubleValue > 4.5 {
            cell.star5.image = UIImage(named: "observe.png)")
        } else {
            cell.star5.image = UIImage(named: "observe-grey.png")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // if we display only one single cell
        if self.data.count == 0 {
            self.tableView.separatorStyle = .None
            return self.view.bounds.width
        } else {
            self.tableView.separatorStyle = .SingleLine
            // fixed size for now ...
            // try this: https://www.youtube.com/watch?v=rgazh3vixQw
            return 120
            //return tableView.bounds.size.height / CGFloat(self.data.count)
        }
    }
    
    // MARK: Image loading
    @IBAction func showImage(sender: AnyObject) {
        let buttonPos = sender.convertPoint(CGPointZero, toView: self.tableView)
        let row = self.tableView.indexPathForRowAtPoint(buttonPos)?.row
        let imageID = self.data[row!].imageID?.integerValue
        if imageID > 0 {
            // there should be a better way to say the SigfoodImageViewController what the imageID is ...
            performSegueWithIdentifier("picture", sender: imageID)
        }
    }
    
    // MARK: Segue
    // load comments on tap
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "comments" {
            if let row = tableView.indexPathForCell(sender as! UITableViewCell)?.row {
                // we give the CommentVC the current menu and he fetches the comments for it itself
                (segue.destinationViewController as! CommentViewController).menu = data[row]
            }
        } else if segue.identifier == "picture" {
            // there should be a better way to say the SigfoodImageViewController what the imageID is ...
            let sender = sender as! Int
            if sender > 0 {
                (segue.destinationViewController as! SigfoodImageViewController).imageID = sender
            }
            self.imageID = 0
        }
    }
    
    // there should be a cleaner way to do this
    func forceUpdateDatabase() {
        updateUITableView(force: true)
        self.refreshControl.endRefreshing()
    }
    
    // MARK: fetch and update Database
    func updateUITableView(force force: Bool) {
        // set force to true to update every time
        NSOperationQueue().addOperationWithBlock {
            self.data = self.fetchDatabase()
            if force {
                Log("Update forced: delete everything!")
                for dish in self.data {
                    self.context.deleteObject(dish)
                }
                self.data.removeAll()
            }
            if self.data.count == 0 {
                self.updateDatabase()
                self.data = self.fetchDatabase()
            }
            
            // back on the main Queue we update the header and load the Cells
            NSOperationQueue.mainQueue().addOperationWithBlock {
                // update header
                self.navItem.title = "\(NSCalendar.currentCalendar().component(.Day, fromDate: self.date)).\(NSCalendar.currentCalendar().component(.Month, fromDate: self.date)).\(NSCalendar.currentCalendar().component(.Year, fromDate: self.date))"
                // reload tableView
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDatabase() -> [Menu] {
        let result: [Menu]
        do {
            let calendar = NSCalendar.currentCalendar()
            
            let today = calendar.components([.Year, .Month, .Day], fromDate: self.date)
            let normalizedToday = calendar.dateFromComponents(today)
            
            let tomorrow = calendar.components([.Year, .Month, .Day], fromDate: self.date.dateByAddingTimeInterval(self.oneDayinSeconds))
            let normalizedTomorrow = calendar.dateFromComponents(tomorrow)
            
            let fetchRequest = NSFetchRequest(entityName: "Menu")
            fetchRequest.predicate = NSPredicate(format: "(date > %@) AND (date < %@)", normalizedToday!, normalizedTomorrow!)
            
            result = try self.context.executeFetchRequest(fetchRequest) as! [Menu]
            return result
        } catch {
            Log("Error loading Data from DB: \(error)")
            return []
        }
    }
    
    func updateDatabase() {
        // we are going to fetch data, so we give some feedback
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            SwiftSpinner.show("loading")
        }
        
        let year = NSCalendar.currentCalendar().component(.Year, fromDate: self.date).description
        var month = NSCalendar.currentCalendar().component(.Month, fromDate: self.date).description as NSString
        if month.doubleValue < 10 {
            month = "0\(month)"
        }
        var day = NSCalendar.currentCalendar().component(.Day, fromDate: self.date).description as NSString
        if day.doubleValue < 10 {
            day = "0\(day)"
        }
        
        let url = NSURL(string: "https://www.sigfood.de/?do=api.gettagesplan&datum=\(year)-\(month)-\(day)")!
        Log("url: \(url)")
        guard let data = NSData(contentsOfURL: url) else { return }
        
        let mensaessen = SWXMLHash.parse(data)["Mensa"]["Tagesmenue"]["Mensaessen"]
        
        for index in 0..<mensaessen.all.count {
            // need a better word than "row"
            let dish = NSEntityDescription.insertNewObjectForEntityForName("Menu", inManagedObjectContext: self.context) as! Menu
            dish.date = self.date
            
            // and it's content
            let mainCourse = mensaessen[index]["hauptgericht"]["bezeichnung"].element?.text?.htmlDecodedString() ?? ""
            let garnish = mensaessen[index]["beilage"]["bezeichnung"].element?.text?.htmlDecodedString() ?? ""
            if garnish != "" {
                if mainCourse.containsString(" mit ") {
                    dish.mainCourse =  "\(mainCourse) und \(garnish)"
                } else {
                    dish.mainCourse =  "\(mainCourse) mit \(garnish)"
                }
            } else {
                dish.mainCourse = mainCourse
            }
            
            if let averageScore = mensaessen[index]["hauptgericht"]["bewertung"]["schnitt"].element?.text {
                dish.score = NSString(string: averageScore).doubleValue
            } else {
                dish.score = 0
            }
            
            // price without garnish
            // we need to parse the price declared in cents
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            formatter.locale = NSLocale(localeIdentifier: "de_DE")
            
            // students
            if let priceStudent = mensaessen[index]["hauptgericht"]["preisstud"].element?.text  {
                dish.priceStudent = formatter.stringFromNumber(NSString(string: priceStudent).doubleValue/100) ?? "0,00 €"
            }
            // employees
            if let priceEmployee = mensaessen[index]["hauptgericht"]["preisbed"].element?.text {
                dish.priceEmployee = formatter.stringFromNumber(NSString(string: priceEmployee).doubleValue/100) ?? "0,00 €"
            }
            // employees
            if let priceGuest = mensaessen[index]["hauptgericht"]["preisgast"].element?.text {
                dish.priceGuest = formatter.stringFromNumber(NSString(string: priceGuest).doubleValue/100) ?? "0,00 €"
            }
            
            // check if we have food pictures
            if mensaessen[index]["hauptgericht"]["bild"].all.count > 0 {
                var pictures = [Int]()
                for picture in mensaessen[index]["hauptgericht"]["bild"] {
                    // check if Id is an Int
                    if let id = Int((picture.element?.attributes["id"])!) {
                        pictures.append(id)
                    }
                }
                // assign picture and overwrite default one here ...
                if pictures.count >= 1 {
                    let random_id = Int(arc4random_uniform(UInt32(pictures.count)))
                    dish.imageID = pictures[random_id]
                    let url = NSURL(string: "https://www.sigfood.de/?do=getimage&bildid=\(pictures[random_id])&width=256")
                    if let image = NSData(contentsOfURL: url!) {
                        dish.image = image
                    } else {
                        Log("download failed: \(url)")
                    }
                }
            }
            
            // check for comments
            if mensaessen[index]["hauptgericht"]["kommentar"].all.count > 0 {
                for comment in mensaessen[index]["hauptgericht"]["kommentar"] {
                    guard let text = comment["text"].element?.text else { continue }
                    guard let nick = comment["nick"].element?.text else { continue }
                    let timestamp = NSString(string: (comment["timestamp"].element?.text!)!).doubleValue as NSTimeInterval
                    let newComment = NSEntityDescription.insertNewObjectForEntityForName("Comment", inManagedObjectContext: self.context) as! Comment
                    newComment.text = text.htmlDecodedString()
                    newComment.nickname = nick.htmlDecodedString()
                    newComment.timestamp = timestamp
                    // assign Comment to Menu
                    // menuRef is Type Menu, commentRef is Type NSSet(Comment)
                    // so we can only assign one-way
                    newComment.menuRef = dish
                }
            }
        }
        do {
            try self.context.save()
        } catch {
            Log("Error saving: \(error)")
        }
        
        // disable loading animation
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            SwiftSpinner.hide()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

}

