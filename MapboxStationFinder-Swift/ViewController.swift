//
//  ViewController.swift
//  MapboxStationFinder-Swift
//
//  Created by Wayne Ohmer on 5/7/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RMMapViewDelegate, StationFilterDelegate {

    var mapView:RMMapView?
    var selectedLines:NSMutableSet = NSMutableSet(array:["Blue","Green","Orange","Red","Silver","Yellow"])
    var stationAnnotations:NSMutableSet = NSMutableSet()

    //MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        RMConfiguration.sharedInstance().accessToken = "pk.eyJ1Ijoid2F5bmVvaG1lciIsImEiOiJqcHpkUFlVIn0.Ckoh0O9yUJ1E8WoFC8nhhg"
        let tileSource:RMMapboxSource = RMMapboxSource(mapID: "mapbox.emerald")
        self.mapView = RMMapView(frame: self.view.bounds, andTilesource: tileSource)
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.910003,-77.015533)
        self.mapView!.zoom = 11
        self.mapView!.centerCoordinate = center
        self.view.addSubview(self.mapView!)
        self.mapView!.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        let southWest:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.560314,-77.370506)
        let northEast:CLLocationCoordinate2D = CLLocationCoordinate2DMake(39.357147,-76.793182)
        self.mapView!.setConstraintsSouthWest(southWest,northEast: northEast)
        self.mapView!.delegate = self
        self.loadStations()
    }

    //MARK: - User Interface Handlers

    @IBAction func filterButtonPressed(sender: UIBarButtonItem) {
        var filterVC = FilterTableViewController(style: .Grouped)
        filterVC.selectedLines = self.selectedLines
        filterVC.title = "Filter Lines"
        filterVC.delegate = self

        var nav = UINavigationController(rootViewController: filterVC)
        nav.modalTransitionStyle = UIModalTransitionStyle.CoverVertical

        self.presentViewController(nav, animated: true, completion: nil)
    }

    func annotationShouldBeHidden(annotation:RMAnnotation) -> Bool{
        // annotation.userInfo["lines"] causes the compiler to segmentation fault so I made a separate variable
        let userInfo = annotation.userInfo as! NSDictionary
        let stationLineColors = NSSet(array: userInfo["lines"] as! [String])
        return !stationLineColors.intersectsSet(self.selectedLines as Set<NSObject>)
    }


    //MARK:- Data Loading Methods

    func loadStations(){
        let jsonPath:String = NSBundle.mainBundle().pathForResource("stations", ofType: "geojson")!

        if (!NSFileManager.defaultManager().fileExistsAtPath(jsonPath)){
            println("Error! Could not find stations.geojson file.")
            return
        }
        let data:NSData? = NSData(contentsOfFile: jsonPath)
        var error:NSError?
        let jsonDict:NSDictionary = NSJSONSerialization.JSONObjectWithData(data!,options: nil, error:&error) as! NSDictionary
        let stationFeatures = jsonDict["features"] as! NSArray

        //Using trailing closures for dispatch_async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)){
            //We need to specify the type of every dictionary element
            for feature in stationFeatures as! [NSDictionary] {
                let featureGeometry = feature["geometry"] as! NSDictionary
                if (featureGeometry["type"] as! NSString == "Point"){
                    //using a closure to convert the "coordinates" array into a CLLocationCoordinate2D
                    let coordinate:CLLocationCoordinate2D = {let points = featureGeometry["coordinates"] as! [CLLocationDegrees]
                        let thisCoordinate = CLLocationCoordinate2D(latitude: points[1], longitude: points[0])
                        return thisCoordinate
                        }()
                    let properties = feature["properties"] as! NSDictionary
                    var stationAnnotation:RMAnnotation! = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: properties["title"] as! String )
                    stationAnnotation.userInfo = properties
                    self.stationAnnotations.addObject(stationAnnotation)

                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView!.addAnnotation(stationAnnotation)
                    }
                }
            }
        }
    }


    //MARK: - RMMapViewDelegate methods

    func mapView(mapView: RMMapView!, layerForAnnotation annotation:RMAnnotation) -> RMMapLayer {
        // annotation.userInfo["lines"] causes the compiler to segmentation fault so I made a separate variable
        let userInfo = annotation.userInfo as! NSDictionary
        let metroBlue = UIColor(red: 0.01, green: 0.22, blue: 0.41, alpha: 1)
        var marker = RMMarker(mapboxMarkerImage: "rail-metro", tintColor: metroBlue)
        marker.canShowCallout = true
        marker.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
        let lines = userInfo["lines"] as! [String]
        let dots = StationDotsView(lines: lines)
        marker.leftCalloutAccessoryView = dots
        marker.hidden = self.annotationShouldBeHidden(annotation)
        return marker
    }

    func tapOnCalloutAccessoryControl(control: UIControl!, forAnnotation annotation: RMAnnotation!, onMap map: RMMapView!) {
        // annotation.userInfo["url"] causes the compiler to segmentation fault so I made a separate variable
        let userInfo = annotation.userInfo as! NSDictionary
        let urlString = userInfo["url"] as! String
        let webVC = WebViewController()
        webVC.stationURL = NSURL(string: urlString)
        webVC.title = userInfo["title"] as? String

        let nav = UINavigationController(rootViewController: webVC)
        nav.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(nav, animated: true, completion: nil)
    }

    //MARK: - Station Loader Delegate Methods

    func didUpdateLines(selectedLines:NSMutableSet){
        self.selectedLines = selectedLines
        //Hide visible Annotations. layerForAnnotation function will hide off screen annotations when they would become visible
        for annotation in self.mapView!.visibleAnnotations as! [RMAnnotation]{
            annotation.layer.hidden = self.annotationShouldBeHidden(annotation)
        }
    }
}