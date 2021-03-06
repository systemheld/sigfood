//
//  ViewController.swift
//  Sigfood
//
//  Created by Kett, Oliver on 30.09.14.
//  Copyright (c) 2014 Kett, Oliver. All rights reserved.
//

// todo: 
// * upload fotos and write comments

import UIKit
import CoreData
import JGProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var buttonDate: UIButton!
    
    // pull to refresh
    var refreshControl = UIRefreshControl()
    
    // now
    var date = NSDate()
    let oneDayinSeconds: Double = 24 * 60 * 60
    // store users chosen locale for date formatting in header
    let calendar = NSCalendar.currentCalendar()
    let formatter = NSDateFormatter()
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext // CoreData
    var data = [Menu]()
    var imageID: Int = 0
    
    // initialize loading animation bevore first use
    var loadingAnimation = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl.tintColor = UIColor(red: 0.016, green: 0.710, blue: 0.788, alpha: 1.00)
        self.refreshControl.addTarget(self, action: #selector(ViewController.forceUpdateDatabase), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        //setup date format with users
        self.formatter.locale = NSLocale.currentLocale()
        self.formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("E ddMMyy", options: 0, locale: NSLocale.currentLocale())
        
        cleanDatabaseForThreshold(7)
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
    @IBAction func buttonSetDateToToday(sender: UIButton, forEvent event: UIEvent) {
        self.date = NSDate()
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
            let cell: UITableViewCell
            let weekday = self.calendar.component(.Weekday, fromDate: self.date)
            if (weekday == 1) || (weekday == 7) {
                cell = tableView.dequeueReusableCellWithIdentifier("weekendCell")!
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
            }
            return cell
        }
        
        // if we have dishes
        let cell = tableView.dequeueReusableCellWithIdentifier("sigfoodCell") as! SigfoodTableViewCell
        let row = self.data[indexPath.row]
        
        cell.mainCourseLabel.text = row.mainCourse
        cell.priceGuest.text = row.priceGuest
        cell.priceStud.text = row.priceStudent
        cell.priceStaff.text = row.priceEmployee
        
        let emojiGenerator = EmojiImageGenerator()
        if row.veggie == true {
            cell.veggie.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.apple, size: 64.0)
        } else {
            cell.veggie.image = UIImage()
        }
        if row.beef == true {
            cell.beef.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.cow, size: 64.0)
        } else {
            cell.beef.image = UIImage()
        }
        if row.withoutPork == true {
            cell.pork.image = emojiGenerator.prohibitedImage(EmojiImageGenerator.emoji.pig, size: 64.0)
        } else {
            cell.pork.image = UIImage()
        }
        
        if row.image != nil {
            cell.foodImage.image = UIImage(data: row.image!)
        } else {
            cell.foodImage.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_questionmark, size: 512.0)
        }
        cell.foodImage.clipsToBounds = true
        cell.foodImage.contentMode = .ScaleAspectFill
        
        if row.score?.doubleValue > 0.5 {
            cell.star1.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.star, size: 64.0)
        } else {
            cell.star1.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_star, size: 64.0)
        }
        if row.score?.doubleValue > 1.5 {
            cell.star2.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.star, size: 64.0)
        } else {
            cell.star2.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_star, size: 64.0)
        }
        if row.score?.doubleValue > 2.5 {
            cell.star3.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.star, size: 64.0)
        } else {
            cell.star3.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_star, size: 64.0)
        }
        if row.score?.doubleValue > 3.5 {
            cell.star4.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.star, size: 64.0)
        } else {
            cell.star4.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_star, size: 64.0)
        }
        if row.score?.doubleValue > 4.5 {
            cell.star5.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.star, size: 64.0)
        } else {
            cell.star5.image = emojiGenerator.imageWithEmoji(EmojiImageGenerator.emoji.white_star, size: 64.0)
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
    
    // MARK: fetch and update Database
    
    // there should be a cleaner way to do this
    func forceUpdateDatabase() {
        updateUITableView(force: true)
        self.refreshControl.endRefreshing()
    }
    
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
                self.buttonDate.setTitle(self.formatter.stringFromDate(self.date), forState: .Normal)
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
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mainCourse", ascending: true)]
            
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
            //SwiftSpinner.show("loading")
            self.loadingAnimation.showInView(self.view)
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
        guard let data = NSData(contentsOfURL: url) else {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                // SwiftSpinner.hide()
                self.loadingAnimation.dismissAnimated(true)
                let alert = UIAlertController(
                    title: NSLocalizedString("error.httpfetch.title", comment: "There was an error fetching data from sigfood.de (title)"),
                    message: NSLocalizedString("error.httpfetch.message", comment: "There was an error fetching data from sigfood.de (message)"),
                    preferredStyle: .Alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("error.httpfetch.button", comment: "There was an error fetching data from sigfood.de (Confirm Button)"), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        
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
            
            // veggie, Beef, without Pork
            if mensaessen[index].element?.attributes["vegetarisch"] == "true" {
                dish.veggie = true
            } else {
                dish.veggie = false
            }
            if mensaessen[index].element?.attributes["rind"] == "true" {
                dish.beef = true
            } else {
                dish.beef = false
            }
            if mensaessen[index].element?.attributes["moslem"] == "true" {
                dish.withoutPork = true
            } else {
                dish.withoutPork = false
            }
            
            // score
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
            // SwiftSpinner.hide()
            self.loadingAnimation.dismissAnimated(true)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func cleanDatabaseForThreshold(threshold: Double) {
        Log("threshold is \(String(threshold))")
        let thresholdInSeconds = threshold * self.oneDayinSeconds
        let calendar = NSCalendar.currentCalendar()
        
        let threshold = calendar.components([.Year, .Month, .Day], fromDate: self.date.dateByAddingTimeInterval(-thresholdInSeconds))
        let normalizedThreshold = calendar.dateFromComponents(threshold)
        
        let fetchRequest = NSFetchRequest(entityName: "Menu")
        fetchRequest.predicate = NSPredicate(format: "date < %@", normalizedThreshold!)
        
        do {
            let result = try self.context.executeFetchRequest(fetchRequest) as! [Menu]
            result.forEach({ dish in
                self.context.deleteObject(dish)
            })
            try self.context.save()
        } catch {
            Log("Error: \(error)")
        }
    }
}

