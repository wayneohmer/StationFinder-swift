//
//  StationDotsView.swift
//  MapboxStationFinder-Swift
//
//  Created by Wayne Ohmer on 5/13/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//


class StationDotsView: UIView {

    var lines:[String]?

    convenience init(lines:[String]){
        self.init(frame: CGRectMake(0, 0, 38, 25))
        self.backgroundColor = UIColor.clearColor()
        self.lines = lines
    }

    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let lineColors = ["Blue","Green","Orange","Red","Silver","Yellow"]
        let fillColors:[UIColor] = [
            UIColor(red: 0.01, green: 0.56, blue: 0.84, alpha: 1), //Blue
            UIColor(red: 0, green: 0.68, blue: 0.3, alpha: 1), //Green
            UIColor(red: 0.89, green: 054, blue: 0.0, alpha: 1), //Orange
            UIColor(red: 0.75, green: 0.08, blue: 0.22, alpha: 1), //Red
            UIColor(red: 0.64, green: 0.65, blue: 0.64, alpha: 1), //Silver
            UIColor(red: 0.99, green: 0.85, blue: 0.1, alpha: 1)] //Yellow

        for i in 0 ... 5 {
            var left:CGFloat = CGFloat(i*13+1)
            var top:CGFloat = 1.0

            if (i >= 3){
                left -= 39.0
                top = 14.0
            }

            var fillColor:UIColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 0.4)

            if (contains(self.lines!,{$0 == lineColors[i]})){
                fillColor = fillColors[i]
            }
            let rectangle = CGRectMake(left, top, CGFloat(10.0), CGFloat(10.0))
            CGContextSetFillColorWithColor(ctx, fillColor.CGColor)
            CGContextFillEllipseInRect(ctx, rectangle)
        }
     }
}
