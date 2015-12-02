//
//  CommentViewController.swift
//  Sigfood
//
//  Created by Kett, Oliver on 16.11.15.
//  Copyright © 2015 Kett, Oliver. All rights reserved.
//

import UIKit
import CoreData

class CommentViewController: UITableViewController {
    
    var menu: Menu?
    var data = [Comment]()
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = menu?.mainCourse
        
        let fetchRequest = NSFetchRequest(entityName: "Comment")
        fetchRequest.predicate = NSPredicate(format: "menuRef = %@", menu!)
        do {
            data = try context.executeFetchRequest(fetchRequest) as! [Comment]
        } catch {
            Log("Error fetching Comments: \(error)")
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data.count == 0 {
            return 1
        } else {
            return self.data.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment")!
        
        // we write at least one comment
        if self.data.count == 0 {
            cell.textLabel!.text = "Noch kein Kommentar vorhanden!"
            cell.detailTextLabel!.text = String()
            return cell
        } else {
            let comment = data[indexPath.row]
            
            let formatter = NSDateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("yMMMMd")
            let date = formatter.stringFromDate(NSDate(timeIntervalSince1970: Double(comment.timestamp!)))
            
            cell.textLabel!.text = comment.text!
            cell.detailTextLabel!.text = "\(comment.nickname!) am \(date)"

            return cell
        }
    }
}