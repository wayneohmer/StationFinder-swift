//
//  FilterTableViewController.swift
//  MapboxStationFinder-Swift
//
//  Created by Wayne Ohmer on 5/13/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//


class FilterTableViewController: UITableViewController {

    //MARK: View Lifecycle Methods


    internal var selectedLines:NSMutableSet?
    var lineColors:[String] = ["Blue","Green","Orange","Red","Silver","Yellow"]
    var delegate:StationFilterDelegate?

    override func viewDidLoad() {
        self.tableView.registerClass( UITableViewCell.self,forCellReuseIdentifier:"Cell")
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed:")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    //MARK: User Interface Handlers

    func donePressed(sender:UIBarButtonItem){
        self.delegate!.didUpdateLines(self.selectedLines!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: Table view delegate methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lineColors.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath:indexPath) as! UITableViewCell
        let lineColor = self.lineColors[indexPath.row] as String
        cell.textLabel!.text = lineColor

        if (self.selectedLines!.containsObject(lineColor)){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select the lines to display on map"
    }

    override func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let lineColor:String = self.lineColors[indexPath.row]
        
        let isCurrentlySelected:Bool = self.selectedLines!.containsObject(lineColor)

        if isCurrentlySelected {
            cell!.accessoryType = .None
            self.selectedLines?.removeObject(lineColor)
        }else{
            cell!.accessoryType = .Checkmark
            self.selectedLines?.addObject(lineColor)
        }
        cell!.selected = false

    }

}

protocol StationFilterDelegate{
    func didUpdateLines(selectedLines:NSMutableSet)
}
