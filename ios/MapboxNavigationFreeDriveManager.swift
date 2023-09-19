@objc(MapboxNavigationFreeDriveManager)
class MapboxNavigationFreeDriveManager: RCTViewManager {
  override func view() -> UIView! {
    return MapboxNavigationFreeDriveView();
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc func showRouteViaManager(_ node: NSNumber, origin: [NSNumber], destination: [NSNumber], waypoints: [[NSNumber]], styles: [NSDictionary], legIndex: NSNumber, cameraType: NSString, padding: [NSNumber]) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.showRoute(origin: origin, destination: destination, waypoints: waypoints, styles: styles, legIndex: legIndex, cameraType: cameraType, padding: padding)
    }
  }

  @objc func clearRouteViaManager(_ node: NSNumber) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.clearRoute()
    }
  }

  @objc func followViaManager(_ node: NSNumber, padding: [NSNumber]) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.follow(padding: padding)
    }
  }

  @objc func moveToOverviewViaManager(_ node: NSNumber, padding: [NSNumber]) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.moveToOverview(padding: padding)
    }
  }

  @objc func fitCameraViaManager(_ node: NSNumber, padding: [NSNumber]) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.fitCamera(padding: padding)
    }
  }

  @objc func startNavigationViaManager(_ node: NSNumber, origin: [NSNumber], destination: [NSNumber], waypoints: [[NSNumber]], styles: [NSDictionary], legIndex: NSNumber, cameraType: NSString, padding: [NSNumber]) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.startNavigation(origin: origin, destination: destination, waypoints: waypoints, styles: styles, legIndex: legIndex, cameraType: cameraType, padding: padding)
    }
  }

  @objc func pauseNavigationViaManager(_ node: NSNumber) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.pauseNavigation()
    }
  }

  @objc func stopNavigationViaManager(_ node: NSNumber) {
    DispatchQueue.main.async {
      let mapboxNavigationFreeDriveView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationFreeDriveView
      
      mapboxNavigationFreeDriveView.stopNavigation()
    }
  }
}
