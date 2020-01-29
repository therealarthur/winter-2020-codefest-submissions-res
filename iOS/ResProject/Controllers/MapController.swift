//
//  ViewController.swift
//  ResProj
//
//  Created by Brian on 1/25/20.
//  Copyright © 2020 Brian. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate {
    private var mapView: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var button: UIButton!
    private var zoomInButton: UIButton!
    private var zoomOutButton: UIButton!
    
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    var delegate: MapControllerDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = .blue
        let camera = GMSCameraPosition.camera(withLatitude: 40.82741405, longitude: -73.87794578, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        makeRemoveButton()
        makeZoomInButton()
        makeZoomOutButton()
        
        // Set heatmap options.
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints,
                                            colorMapSize: 256)
        addHeatmap()
        
        // Set the heatmap to the mapview.
        heatmapLayer.map = mapView
        
        configureNavigationBar()
    }
    
    @objc func handleMenuToggle() {
        delegate?.handleMenuToggle(forMenuOption: nil)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.barStyle = .default
        
        navigationItem.title = "Heatmap"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu_white_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
    }
    
    // Parse JSON data and add it to the heatmap layer.
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        do {
            //        if let dbPath = Bundle.main.url(forResource: "nycData", withExtension: "db", subdirectory: "Data")
            //        {
            //            print("FOUND")
            //            let data = try Data(contentsOf: dbPath)
            //        }
            // Get the data: latitude/longitude positions of police stations.
            if let path = Bundle.main.url(forResource: "Complain-Data-LatLng", withExtension: "json") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    for item in object {
                        let lat = item["lat"]
                        let lng = item["lng"]
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 2.0)
                        list.append(coords)
                    }
                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
    }
    
    @objc
    func removeHeatmap() {
        heatmapLayer.map = nil
        heatmapLayer = nil
        // Disable the button to prevent subsequent calls, since heatmapLayer is now nil.
        button.isEnabled = false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // Add a button to the view.
    func makeRemoveButton() {
        // A button to test removing the heatmap.
        button = UIButton(frame: CGRect(x: 5, y: 150, width: 200, height: 35))
        button.backgroundColor = .blue
        button.alpha = 0.5
        button.setTitle("Remove heatmap", for: .normal)
        button.addTarget(self, action: #selector(removeHeatmap), for: .touchUpInside)
        self.mapView.addSubview(button)
    }
    
    func makeZoomInButton() {
        zoomInButton = UIButton(frame: CGRect(x: 330, y: 770, width: 35, height: 35))
        zoomInButton.backgroundColor = .white
        zoomInButton.setTitleColor(UIColor.black, for: .normal)
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        self.mapView.addSubview((zoomInButton))
    }

    func makeZoomOutButton() {
        zoomOutButton = UIButton(frame: CGRect(x: 330, y: 810, width: 35, height: 35))
        zoomOutButton.backgroundColor = .white
        zoomOutButton.setTitleColor(UIColor.black, for: .normal)
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        self.mapView.addSubview((zoomOutButton))
    }
    
    @objc
    func zoomIn() {
        mapView.animate(with: GMSCameraUpdate.zoom(by: 0.5))
    }
    
    @objc
    func zoomOut() {
        mapView.animate(with: GMSCameraUpdate.zoom(by: -0.5))
    }
}

