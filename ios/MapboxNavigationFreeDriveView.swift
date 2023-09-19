import UIKit
import Foundation
import CoreLocation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps
import Turf

// // adapted from https://pspdfkit.com/blog/2017/native-view-controllers-and-react-native/ and https://github.com/mslabenyak/react-native-mapbox-navigation/blob/master/ios/Mapbox/MapboxNavigationView.swift
extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

class MapboxNavigationFreeDriveView: UIView, NavigationMapViewDelegate {
  @objc var followZoomLevel: NSNumber = 16.0
  @objc var onLocationChange: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onTrackingStateChange: RCTDirectEventBlock?
  @objc var onRouteChange: RCTDirectEventBlock?
  @objc var onRouteProgressChange: RCTDirectEventBlock?
  @objc var onManeuverSizeChange: RCTDirectEventBlock?
  @objc var showSpeedLimit: Bool = true {
    didSet {
      if (embedded == true && oldValue != showSpeedLimit) {
        if (showSpeedLimit) {
          showSpeedLimitView()
        } else {
          hideSpeedLimitView()
        }
      }
    }
  }
  @objc var speedLimitAnchor: [NSNumber] = [] {
    didSet {
      if (embedded == true && oldValue.count != speedLimitAnchor.count || oldValue != speedLimitAnchor) {
        setSpeedLimitAnchor()
      }
    }
  }
  @objc var maneuverAnchor: [NSNumber] = [] {
    didSet {
      if (embedded == true && oldValue.count != maneuverAnchor.count || oldValue != maneuverAnchor) {
        setInstructionsViewAnchor()
      }
    }
  }
  @objc var maneuverRadius: NSNumber = 26 {
    didSet {
      applyStyles()
    }
  }
  @objc var maneuverBackgroundColor: NSString = "#303030"
  @objc var userPuckImage: UIImage?
  @objc var userPuckScale: NSNumber = 1.0
  @objc var originImage: UIImage?
  @objc var destinationImage: UIImage?
  @objc var mapPadding: [NSNumber] = []
  @objc var routeColor: NSString = "#56A8FB" {
    didSet {
      applyStyles()
    }
  }
  @objc var routeCasingColor: NSString = "#2F7AC6" {
    didSet {
      applyStyles()
    }
  }
  @objc var routeClosureColor: NSString = "#000000"
  @objc var alternateRouteColor: NSString = "#8694A5" {
    didSet {
      applyStyles()
    }
  }
  @objc var alternateRouteCasingColor: NSString = "#727E8D" {
    didSet {
      applyStyles()
    }
  }
  @objc var traversedRouteColor: NSString? {
    didSet {
      applyStyles()
    }
  }
  @objc var traversedRouteCasingColor: NSString? {
    didSet {
      applyStyles()
    }
  }
  @objc var trafficUnknownColor: NSString = "#56A8FB" {
    didSet {
      applyStyles()
    }
  }
  @objc var trafficLowColor: NSString = "#56A8FB" {
    didSet {
      applyStyles()
    }
  }
  @objc var trafficModerateColor: NSString = "#ff9500" {
    didSet {
      applyStyles()
    }
  }
  @objc var trafficHeavyColor: NSString = "#ff4d4d" {
    didSet {
      applyStyles()
    }
  }
  @objc var trafficSevereColor: NSString = "#8f2447" {
    didSet {
      applyStyles()
    }
  }
  @objc var restrictedRoadColor: NSString = "#000000" {
    didSet {
      applyStyles()
    }
  }
  @objc var routeArrowColor: NSString = "#FFFFFF" {
    didSet {
      applyStyles()
    }
  }
  @objc var routeArrowCasingColor: NSString = "#2D3F53" {
    didSet {
      applyStyles()
    }
  }
  @objc var waypointColor: NSString = "#2F7AC6"
  @objc var waypointRadius: NSNumber = 8
  @objc var waypointOpacity: NSNumber = 1
  @objc var waypointStrokeWidth: NSNumber = 2
  @objc var waypointStrokeOpacity: NSNumber = 1
  @objc var waypointStrokeColor: NSString = "#FFFFFF"
  @objc var fontFamily: NSString?  {
    didSet {
      applyStyles()
    }
  }
  @objc var primaryColour: NSString = "#303030" {
    didSet {
      applyStyles()
    }
  }
  @objc var secondaryColour: NSString = "#707070" {
    didSet {
      applyStyles()
    }
  }
  @objc var primaryTextColour: NSString = "#FFFFFF" {
    didSet {
      applyStyles()
    }
  }
  @objc var secondaryTextColour: NSString = "#9B9B9B" {
    didSet {
      applyStyles()
    }
  }
  @objc var textSizeSmall: NSNumber = 14 {
    didSet {
      applyStyles()
    }
  }
  @objc var textSizeMedium: NSNumber = 16 {
    didSet {
      applyStyles()
    }
  }
  @objc var textSizeLarge: NSNumber = 20 {
    didSet {
      applyStyles()
    }
  }
  @objc var textSizeXLarge: NSNumber = 22 {
    didSet {
      applyStyles()
    }
  }
  @objc var logoVisible: Bool = true {
    didSet {
      if (embedded == true) {
        setLogoPadding()
      }
    }
  }
  @objc var logoPadding: [NSNumber] = [] {
    didSet {
      if (embedded == true && oldValue.count != logoPadding.count || oldValue != logoPadding) {
        setLogoPadding()
      }
    }
  }
  @objc var attributionVisible: Bool = true {
    didSet {
      if (embedded == true) {
        setAttributionPadding()
      }
    }
  }
  @objc var attributionPadding: [NSNumber] = [] {
    didSet {
      if (embedded == true && oldValue.count != attributionPadding.count || oldValue != attributionPadding) {
        setAttributionPadding()
      }
    }
  }
  @objc var mute: Bool = false {
    didSet {
      if (embedded == true) {
        toggleMute(isMuted: mute)
      }
    }
  }
  @objc var darkMode: Bool = false {
    didSet {
      if (embedded == true) {
        if (darkMode) {
          styleManager?.applyStyle(type: .night)
        } else {
          styleManager?.applyStyle(type: .day)
        }
      }
    }
  }
  @objc var debug: Bool = false

  var navigationService: NavigationService!
  var navigationMapView: NavigationMapView!
  var speedLimitView: SpeedLimitView!
  var instructionsCardContainerView: InstructionsCardContainerView!
  var styleManager: MapboxNavigation.StyleManager!
  var voiceController: RouteVoiceController!
  var pointAnnotationManager: PointAnnotationManager?
  var passiveLocationManager: PassiveLocationManager!
  var passiveLocationProvider: PassiveLocationProvider!
  var embedded: Bool
  var embedding: Bool
  var isMapStyleLoaded: Bool = false
  var currentLegIndex: Int = -1
  var currentActiveRoutes: [Route]? = nil
  var currentPreviewRoutes: [Route]? = nil
  var currentRouteResponse: RouteResponse? = nil
  var waypointStyles: [[String: Any]] = []

  @objc func showRoute(origin: [NSNumber], destination: [NSNumber], waypoints: [[NSNumber]], styles: [NSDictionary], legIndex: NSNumber, cameraType: NSString, padding: [NSNumber])  {
    if (embedded == false) {
      return
    }

    waypointStyles = (styles as? [[String: Any]]) ?? []

    var routeWaypoints: [Waypoint] = []
    var routeWaypointNames: [String] = []

    if (origin.isEmpty == false) {
      let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
      routeWaypoints.append(originWaypoint)
    }

    if (waypoints.isEmpty == false) {
      for waypoint: [NSNumber] in waypoints {
        if (waypoint.isEmpty == false) {
          routeWaypoints.append(Waypoint(coordinate: CLLocationCoordinate2D(latitude: waypoint[1] as! CLLocationDegrees, longitude: waypoint[0] as! CLLocationDegrees)))
        }
      }
    }

    if (destination.isEmpty == false) {
      let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))
      routeWaypoints.append(destinationWaypoint)
    }

    if (waypointStyles.isEmpty == false) {
      for waypointStyle: [String : Any] in waypointStyles {
        routeWaypointNames.append(((waypointStyle["name"]! as? NSString) ?? "") as String)
      }
    }

    if (routeWaypoints.isEmpty == false) {
      fetchRoutes(routeWaypoints: routeWaypoints, routeWaypointNames: routeWaypointNames, onSuccess: {(routes: [Route]) -> Void in
        self.moveToOverview(padding: padding)
        self.previewRoutes(routes: routes, padding: self.getPadding(padding: padding, useDefault: false))
        self.onRouteChange?([
          "distance": routes.first?.distance ?? 0,
          "expectedTravelTime": routes.first?.expectedTravelTime ?? 0,
          "typicalTravelTime": routes.first?.typicalTravelTime ?? 0
        ])
      })
    }
  }

  @objc func clearRoute() {
    if (embedded == true) {
      clearRouteAndStopActiveGuidance()
    }
  }

  @objc func follow(padding: [NSNumber]) {
    if (embedded == true) {
      setToFollow(padding: getPadding(padding: padding, useDefault: false))
    }
  }

  @objc func moveToOverview(padding: [NSNumber]) {
    if (embedded == true) {
      setToOverview(padding: getPadding(padding: padding, useDefault: false))
    }
  }

  @objc func fitCamera(padding: [NSNumber]) {
    if (embedded == true) {
      setToOverview(padding: getPadding(padding: padding, useDefault: false))
    }
  }

  @objc func startNavigation(origin: [NSNumber], destination: [NSNumber], waypoints: [[NSNumber]], styles: [NSDictionary], legIndex: NSNumber, cameraType: NSString, padding: [NSNumber])  {
    if (embedded == false || embedding == true) {
      return
    }
    
    if (currentActiveRoutes != nil) {
      startActiveGuidance(padding: getPadding(padding: padding, useDefault: false), updateCamera: false)

      if (cameraType == "overview") {
        setToOverview(padding: getPadding(padding: padding, useDefault: false))
      } else {
        setToFollow(padding: getPadding(padding: padding, useDefault: false))
      }
    } else {
      waypointStyles = (styles as? [[String: Any]]) ?? []

      var routeWaypoints: [Waypoint] = []
      var routeWaypointNames: [String] = []

      if (origin.isEmpty == false) {
        let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
        routeWaypoints.append(originWaypoint)
      }

      if (waypoints.isEmpty == false) {
        for waypoint: [NSNumber] in waypoints {
          if (waypoint.isEmpty == false) {
            routeWaypoints.append(Waypoint(coordinate: CLLocationCoordinate2D(latitude: waypoint[1] as! CLLocationDegrees, longitude: waypoint[0] as! CLLocationDegrees)))
          }
        }
      }

      if (destination.isEmpty == false) {
        let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))
        routeWaypoints.append(destinationWaypoint)
      }

      if (waypointStyles.isEmpty == false) {
        for waypointStyle: [String : Any] in waypointStyles {
          routeWaypointNames.append(((waypointStyle["name"]! as? NSString) ?? "") as String)
        }
      }

      fetchRoutes(routeWaypoints: routeWaypoints, routeWaypointNames: routeWaypointNames, onSuccess: {(routes: [Route]) -> Void in
        self.currentActiveRoutes = routes
        self.onRouteChange?([
          "distance": routes.first?.distance ?? 0,
          "expectedTravelTime": routes.first?.expectedTravelTime ?? 0,
          "typicalTravelTime": routes.first?.typicalTravelTime ?? 0
        ])

        self.startActiveGuidance(padding: self.getPadding(padding: padding, useDefault: false), updateCamera: false)
        self.setToFollow(padding: self.getPadding(padding: padding, useDefault: false))
      })
    }
  }

  @objc func pauseNavigation() {
    if (embedded == true) {
      clearActiveGuidance()
      clearMap()

      setToFollow(padding: getPadding(padding: [], useDefault: false))
    }
  }

  @objc func stopNavigation() {
    if (embedded == true) {
      clearRouteAndStopActiveGuidance()
    }
  }
  
  @objc func didUpdatePassiveLocation(_ notification: Notification) {
    guard
      let location = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.locationKey] as? CLLocation,
      let roadName = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.roadNameKey] as? String
    else { return }
    
    speedLimitView?.signStandard = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.signStandardKey] as? SignStandard
    speedLimitView?.speedLimit = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.speedLimitKey] as? Measurement<UnitSpeed>
    speedLimitView?.currentSpeed = location.speed

    onLocationChange?([
      "longitude": location.coordinate.longitude,
      "latitude": location.coordinate.latitude,
      "roadName": roadName,
      "speed": location.speed,
      "bearing": location.course
    ])
  }

  @objc func progressDidChange(_ notification: Notification) {
    guard
      let routeProgress = notification.userInfo?[RouteController.NotificationUserInfoKey.routeProgressKey] as? RouteProgress,
      let location = notification.userInfo?[RouteController.NotificationUserInfoKey.locationKey] as? CLLocation,
      let roadName = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.roadNameKey] as? String
    else { return }

    speedLimitView?.signStandard = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.signStandardKey] as? SignStandard
    speedLimitView?.speedLimit = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.speedLimitKey] as? Measurement<UnitSpeed>
    speedLimitView?.currentSpeed = location.speed

    // Add maneuver arrow
    if (routeProgress.currentLegProgress.followOnStep != nil) {
      navigationMapView?.addArrow(route: routeProgress.route, legIndex: routeProgress.legIndex, stepIndex: routeProgress.currentLegProgress.stepIndex + 1)
    } else {
      navigationMapView?.removeArrow()
    }
        
    if (routeProgress.legIndex != currentLegIndex) {
      navigationMapView?.showWaypoints(on: routeProgress.route, legIndex: routeProgress.legIndex)
    }
        
    // Update the top banner with progress updates
    let distance = routeProgress.currentLegProgress.currentStepProgress.distanceRemaining
    let normalizedDistance = max(distance, 0)
    instructionsCardContainerView?.updateInstructionCard(distance: normalizedDistance, isCurrentCardStep: true)
    instructionsCardContainerView?.isHidden = false
        
    // Update `UserCourseView` to be placed on the most recent location.
    navigationMapView?.moveUserLocation(to: location, animated: true)
        
    // Update the main route line during active navigation when `NavigationMapView.routeLineTracksTraversal` set to `true`
    // and route progress change, by calling `NavigationMapView.updateRouteLine(routeProgress:coordinate:shouldRedraw:)`
    // without redrawing the main route.
    navigationMapView?.updateRouteLine(routeProgress: routeProgress, coordinate: location.coordinate, shouldRedraw: routeProgress.legIndex != currentLegIndex)
    currentLegIndex = routeProgress.legIndex

    onRouteProgressChange?([
      "distanceTraveled": routeProgress.distanceTraveled,
      "distanceRemaining": routeProgress.distanceRemaining,
      "timeTraveled": 0,
      "timeRemaining": routeProgress.durationRemaining,
      "progress": routeProgress.fractionTraveled
    ])

    onLocationChange?([
      "longitude": location.coordinate.longitude,
      "latitude": location.coordinate.latitude,
      "roadName": roadName,
      "speed": location.speed,
      "bearing": location.course
    ])
  }
  
  @objc func updateInstructionsBanner(notification: Notification) {
    guard let routeProgress = notification.userInfo?[RouteController.NotificationUserInfoKey.routeProgressKey] as? RouteProgress else {
      assertionFailure("RouteProgress should be available.")
    
      return
    }
        
    if let visualInstruction = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction {
      instructionsCardContainerView?.updateInstruction(visualInstruction)
      instructionsCardContainerView?.isHidden = false
    }
  }
  
  @objc func rerouted(_ notification: Notification) {
    navigationMapView?.removeWaypoints()
        
    // Update the main route line during active navigation when `NavigationMapView.routeLineTracksTraversal` set to `true`
    // and rerouting happens, by calling `NavigationMapView.updateRouteLine(routeProgress:coordinate:shouldRedraw:)`
    // with `shouldRedraw` as `true`.
    navigationMapView?.updateRouteLine(
      routeProgress: navigationService.routeProgress,
      coordinate: navigationService.router.location?.coordinate,
      shouldRedraw: true
    )

    self.onRouteChange?([
      "distance": navigationService.routeProgress.route.distance,
      "expectedTravelTime": navigationService.routeProgress.route.expectedTravelTime,
      "typicalTravelTime": navigationService.routeProgress.route.typicalTravelTime ?? 0
    ])
  }
    
  @objc func refresh(_ notification: Notification) {
    // Update the main route line during active navigation when `NavigationMapView.routeLineTracksTraversal` set to `true`
    // and route refresh happens, by calling `NavigationMapView.updateRouteLine(routeProgress:coordinate:shouldRedraw:)`
    // with `shouldRedraw` as `true`.
    navigationMapView?.updateRouteLine(
      routeProgress: navigationService.routeProgress,
      coordinate: navigationService.router.location?.coordinate,
      shouldRedraw: true
    )

    self.onRouteChange?([
      "distance": navigationService.routeProgress.route.distance,
      "expectedTravelTime": navigationService.routeProgress.route.expectedTravelTime,
      "typicalTravelTime": navigationService.routeProgress.route.typicalTravelTime ?? 0
    ])
  }

  @objc func navigationCameraStateDidChange(_ notification: Notification) {
    let navigationCameraState = notification.userInfo?[NavigationCamera.NotificationUserInfoKey.state] as? NavigationCameraState
    
    var stateStr: String = "idle"

    if (navigationCameraState != nil) {
      if (navigationCameraState == NavigationCameraState.transitionToFollowing) {
        stateStr = "transitionToFollowing"
      } else if (navigationCameraState == NavigationCameraState.following) {
        stateStr = "following"
      } else if (navigationCameraState == NavigationCameraState.transitionToOverview) {
        stateStr = "transitionToOverview"
      } else if (navigationCameraState == NavigationCameraState.overview) {
        stateStr = "overview"
      }
    }

    onTrackingStateChange?(["state": stateStr])
  }

  func getPadding(padding: [NSNumber], useDefault: Bool) -> UIEdgeInsets? {
    if (padding.indices.count < 4 && !useDefault) {
      return nil
    }
    
    let newPadding = UIEdgeInsets(
      top: padding.indices.contains(0) ? CGFloat(padding[0].floatValue) : (mapPadding.indices.contains(0) ? CGFloat(mapPadding[0].floatValue) : 0),
      left: padding.indices.contains(1) ? CGFloat(padding[1].floatValue) : (mapPadding.indices.contains(1) ? CGFloat(mapPadding[1].floatValue) : 0),
      bottom: padding.indices.contains(2) ? CGFloat(padding[2].floatValue) : (mapPadding.indices.contains(2) ? CGFloat(mapPadding[2].floatValue) : 0),
      right: padding.indices.contains(3) ? CGFloat(padding[3].floatValue) : (mapPadding.indices.contains(3) ? CGFloat(mapPadding[3].floatValue) : 0))

    return newPadding
  }

  func fetchRoutes(routeWaypoints: [Waypoint], routeWaypointNames: [String], onSuccess: @escaping (_ routes: [Route]) -> Void) {
    let options = NavigationRouteOptions(waypoints: routeWaypoints, profileIdentifier: .automobileAvoidingTraffic)
    options.includesAlternativeRoutes = true

    Directions.shared.calculate(options) { [weak self] (session, result) in
      switch result {
        case .failure(let error):
          self?.sendErrorToReact(error: error.localizedDescription)
        case .success(let response):
          guard let routes = response.routes, let strongSelf = self else {
            return
          }

          strongSelf.currentRouteResponse = response

          onSuccess(routes)
        }
      }
  }

  func previewRoutes(routes: [Route], padding: UIEdgeInsets?) {
    pauseNavigation()

    currentPreviewRoutes = routes
    
    let cameraOptions = CameraOptions(padding: padding ?? getPadding(padding: [], useDefault: true))
    
    navigationMapView?.showcase(routes, routesPresentationStyle: RoutesPresentationStyle.all(shouldFit: true, cameraOptions: cameraOptions))
    //navigationMapView?.showRouteDurations(along: routes)
  }

  func startActiveGuidance(padding: UIEdgeInsets?, updateCamera: Bool) {
    currentPreviewRoutes = nil
    let response = currentRouteResponse

    if (response != nil) {
      let locationManager = NavigationLocationManager()
      navigationService = MapboxNavigationService(
        indexedRouteResponse: IndexedRouteResponse(routeResponse: response!, routeIndex: 0),
        credentials: NavigationSettings.shared.directions.credentials,
        locationSource: locationManager
      )

      let credentials = navigationService.credentials
      voiceController = RouteVoiceController(
        navigationService: navigationService,
        accessToken: credentials.accessToken,
        host: credentials.host.absoluteString
      )
      
      toggleMute(isMuted: mute)

      navigationService.start()

      navigationMapView?.mapView.mapboxMap.onNext(event: .styleLoaded, handler: { [weak self] _ in
        guard let self = self else { return }
        
        self.navigationMapView?.routeLineTracksTraversal = true

      let layerExists = self.navigationMapView.mapView.mapboxMap.style.layerExists(withId: "road-intersection")
          
          if (layerExists) {
          self.navigationMapView.show([self.navigationService.route], layerPosition: .below("road-intersection"), legIndex: 0)
        } else {
          self.navigationMapView.show([self.navigationService.route], legIndex: 0)
        }
      })

      let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .active)
      navigationViewportDataSource.options.followingCameraOptions.paddingUpdatesAllowed = false
      navigationViewportDataSource.options.overviewCameraOptions.paddingUpdatesAllowed = false
      navigationViewportDataSource.followingMobileCamera.padding = padding ?? getPadding(padding: [], useDefault: true)
      navigationViewportDataSource.overviewMobileCamera.padding = padding ?? getPadding(padding: [], useDefault: true)
      
      navigationMapView?.navigationCamera.viewportDataSource = navigationViewportDataSource

      NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(_ :)), name: .routeControllerProgressDidChange, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(rerouted(_:)), name: .routeControllerDidReroute, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: .routeControllerDidRefreshRoute, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(updateInstructionsBanner(notification:)), name: .routeControllerDidPassVisualInstructionPoint, object: navigationService.router)

      NotificationCenter.default.removeObserver(self, name: .passiveLocationManagerDidUpdate, object: nil)
      passiveLocationProvider?.stopUpdatingLocation()
      passiveLocationProvider?.stopUpdatingHeading()

      navigationMapView?.mapView.mapboxMap.onNext(event: .styleLoaded) { [weak self] _ in
        guard let self = self else { return }
        self.pointAnnotationManager = self.navigationMapView.mapView.annotations.makePointAnnotationManager()
      }

      if (updateCamera) {
        setToFollow(padding: padding ?? getPadding(padding: [], useDefault: true))
      }
    }
  }
  
  func clearRouteAndStopActiveGuidance() {
    // clear
    currentActiveRoutes = nil
    currentPreviewRoutes = nil
    currentRouteResponse = nil
    currentLegIndex = -1

    clearActiveGuidance()
    clearMap()

    moveToOverview(padding: [])
  }

  func clearActiveGuidance() {
    waypointStyles = []

    navigationService?.stop()

    navigationService = nil

    let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .passive)

    navigationMapView?.navigationCamera.viewportDataSource = navigationViewportDataSource

    instructionsCardContainerView?.isHidden = true

    NotificationCenter.default.removeObserver(self, name: .routeControllerProgressDidChange, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidReroute, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidRefreshRoute, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidPassVisualInstructionPoint, object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didUpdatePassiveLocation),
      name: .passiveLocationManagerDidUpdate,
      object: nil
    )

    passiveLocationProvider?.startUpdatingLocation()
    passiveLocationProvider?.startUpdatingHeading()
  }

  func clearMap() {
    navigationMapView?.unhighlightBuildings()
    navigationMapView?.removeRoutes()
    navigationMapView?.removeRouteDurations()
    navigationMapView?.removeWaypoints()
    navigationMapView?.removeArrow()
    navigationMapView?.removeAlternativeRoutes()
    navigationMapView?.removeContinuousAlternativesRoutes()
    navigationMapView?.removeContinuousAlternativeRoutesDurations()
  }

  func sendErrorToReact(error: String) {
    onError?(["message": error])
  }

  override init(frame: CGRect) {
    self.embedded = false
    self.embedding = false
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if (!embedding && !embedded) {
      embed()
    } else {
      navigationMapView?.frame = bounds
    }
  }
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    // cleanup and teardown any existing resources
    NotificationCenter.default.removeObserver(self, name: .passiveLocationManagerDidUpdate, object: nil)
    NotificationCenter.default.removeObserver(self, name: .navigationCameraStateDidChange, object: navigationMapView?.navigationCamera)
    NotificationCenter.default.removeObserver(self, name: .routeControllerProgressDidChange, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidReroute, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidRefreshRoute, object: nil)
    NotificationCenter.default.removeObserver(self, name: .routeControllerDidPassVisualInstructionPoint, object: nil)
    passiveLocationProvider?.stopUpdatingLocation()
    passiveLocationProvider?.stopUpdatingHeading()
    navigationMapView?.removeFromSuperview()
    speedLimitView?.removeFromSuperview()
  }

  private func embed() {
    guard let parentVC = parentViewController else {
      return
    }

    embedding = true

    navigationMapView = NavigationMapView(frame: bounds)
    navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    navigationMapView.delegate = self

    navigationMapView.routeLineTracksTraversal = true
    navigationMapView.showsCongestionForAlternativeRoutes = true
    navigationMapView.showsRestrictedAreasOnRoute = true
    navigationMapView.routeCasingColor = UIColor(hex: routeCasingColor as String)
    navigationMapView.routeAlternateColor = UIColor(hex: alternateRouteColor as String)
    navigationMapView.routeAlternateCasingColor = UIColor(hex: alternateRouteCasingColor as String)

    if (traversedRouteColor != nil) {
      navigationMapView.traversedRouteColor = UIColor(hex: traversedRouteColor! as String)
    } else {
      navigationMapView.traversedRouteColor = UIColor.clear
    }

    navigationMapView.trafficUnknownColor = UIColor(hex: trafficUnknownColor as String)
    navigationMapView.trafficLowColor = UIColor(hex: trafficLowColor as String)
    navigationMapView.trafficModerateColor = UIColor(hex: trafficModerateColor as String)
    navigationMapView.trafficHeavyColor = UIColor(hex: trafficHeavyColor as String)
    navigationMapView.trafficSevereColor = UIColor(hex: trafficSevereColor as String)
    navigationMapView.routeRestrictedAreaColor = UIColor(hex: restrictedRoadColor as String)
    navigationMapView.maneuverArrowColor = UIColor(hex: routeArrowColor as String)
    navigationMapView.maneuverArrowStrokeColor = UIColor(hex: routeArrowCasingColor as String)
      
    styleManager = MapboxNavigation.StyleManager()
    styleManager.delegate = self
    styleManager.styles = [
      CustomDayStyle(
        routeCasingColor: UIColor(hex: routeCasingColor as String),
        routeAlternateColor: UIColor(hex: alternateRouteColor as String),
        routeAlternateCasingColor: UIColor(hex: alternateRouteCasingColor as String),
        traversedRouteColor: traversedRouteColor != nil ? UIColor(hex: traversedRouteColor! as String) : UIColor.clear,
        trafficUnknownColor: UIColor(hex: trafficUnknownColor as String),
        trafficLowColor: UIColor(hex: trafficLowColor as String),
        trafficModerateColor: UIColor(hex: trafficModerateColor as String),
        trafficHeavyColor: UIColor(hex: trafficHeavyColor as String),
        trafficSevereColor: UIColor(hex: trafficSevereColor as String),
        routeRestrictedAreaColor: UIColor(hex: restrictedRoadColor as String),
        maneuverArrowColor: UIColor(hex: routeArrowColor as String),
        maneuverArrowStrokeColor: UIColor(hex: routeArrowCasingColor as String),
        instructionsCardRadius: CGFloat(maneuverRadius.floatValue),
        fontFamilyName: fontFamily as String?,
        primaryColour: UIColor(hex: primaryColour as String),
        secondaryColour: UIColor(hex: secondaryColour as String),
        primaryTextColour: UIColor(hex: primaryTextColour as String),
        secondaryTextColour: UIColor(hex: secondaryTextColour as String),
        textSizeSmall: CGFloat(textSizeSmall.floatValue),
        textSizeMedium: CGFloat(textSizeMedium.floatValue),
        textSizeLarge: CGFloat(textSizeLarge.floatValue),
        textSizeXLarge: CGFloat(textSizeXLarge.floatValue)
      ),
      CustomNightStyle(
        routeCasingColor: UIColor(hex: routeCasingColor as String),
        routeAlternateColor: UIColor(hex: alternateRouteColor as String),
        routeAlternateCasingColor: UIColor(hex: alternateRouteCasingColor as String),
        traversedRouteColor: traversedRouteColor != nil ? UIColor(hex: traversedRouteColor! as String) : UIColor.clear,
        trafficUnknownColor: UIColor(hex: trafficUnknownColor as String),
        trafficLowColor: UIColor(hex: trafficLowColor as String),
        trafficModerateColor: UIColor(hex: trafficModerateColor as String),
        trafficHeavyColor: UIColor(hex: trafficHeavyColor as String),
        trafficSevereColor: UIColor(hex: trafficSevereColor as String),
        routeRestrictedAreaColor: UIColor(hex: restrictedRoadColor as String),
        maneuverArrowColor: UIColor(hex: routeArrowColor as String),
        maneuverArrowStrokeColor: UIColor(hex: routeArrowCasingColor as String),
        instructionsCardRadius: CGFloat(maneuverRadius.floatValue),
        fontFamilyName: fontFamily as String?,
        primaryColour: UIColor(hex: primaryColour as String),
        secondaryColour: UIColor(hex: secondaryColour as String),
        primaryTextColour: UIColor(hex: primaryTextColour as String),
        secondaryTextColour: UIColor(hex: secondaryTextColour as String),
        textSizeSmall: CGFloat(textSizeSmall.floatValue),
        textSizeMedium: CGFloat(textSizeMedium.floatValue),
        textSizeLarge: CGFloat(textSizeLarge.floatValue),
        textSizeXLarge: CGFloat(textSizeXLarge.floatValue)
      )
    ]
    styleManager.automaticallyAdjustsStyleForTimeOfDay = false
      
    if (darkMode) {
      styleManager.applyStyle(type: .night)
    } else {
      styleManager.applyStyle(type: .day)
    }

    navigationMapView.mapView.ornaments.options.compass.visibility = .hidden
    navigationMapView.mapView.ornaments.options.scaleBar.visibility = .hidden
    navigationMapView.mapView.gestures.options.rotateEnabled = false
    navigationMapView.mapView.gestures.options.pinchPanEnabled = false
    navigationMapView.mapView.gestures.options.pitchEnabled = false

    var puck2DConfiguration = Puck2DConfiguration()
    if (userPuckImage != nil) {
      puck2DConfiguration.topImage = userPuckImage
      puck2DConfiguration.scale = .constant(Double(exactly: userPuckScale)!)
    }
    navigationMapView.userLocationStyle = UserLocationStyle.puck2D(configuration: puck2DConfiguration)

    let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
    navigationViewportDataSource.options.followingCameraOptions.paddingUpdatesAllowed = false
    navigationViewportDataSource.options.overviewCameraOptions.paddingUpdatesAllowed = false
    navigationViewportDataSource.followingMobileCamera.padding = getPadding(padding: [], useDefault: true)
    navigationViewportDataSource.overviewMobileCamera.padding = getPadding(padding: [], useDefault: true)

    navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource

    setToFollow(padding: getPadding(padding: [], useDefault: false))

    addSubview(navigationMapView)

    instructionsCardContainerView = InstructionsCardContainerView()
    
    instructionsCardContainerView.translatesAutoresizingMaskIntoConstraints = false
    instructionsCardContainerView.isHidden = true

    speedLimitView = SpeedLimitView()

    speedLimitView.shouldShowUnknownSpeedLimit = true
    speedLimitView.translatesAutoresizingMaskIntoConstraints = false
    
    if (showSpeedLimit == true) {
      showSpeedLimitView()
    } else {
      hideSpeedLimitView()
    }
      
    let stackView = UIStackView(arrangedSubviews: [instructionsCardContainerView, speedLimitView])
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .leading
    stackView.spacing = 0
    stackView.translatesAutoresizingMaskIntoConstraints = false
      
    addSubview(stackView)
    
    setSpeedLimitAnchor()
    setInstructionsViewAnchor()
      
    setLogoPadding()
    setAttributionPadding()

    passiveLocationManager = PassiveLocationManager()
    passiveLocationProvider = PassiveLocationProvider(locationManager: passiveLocationManager)

    navigationMapView.mapView.location.overrideLocationProvider(with: passiveLocationProvider)
    
    passiveLocationProvider.startUpdatingLocation()
    passiveLocationProvider.startUpdatingHeading()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didUpdatePassiveLocation),
      name: .passiveLocationManagerDidUpdate,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(navigationCameraStateDidChange),
      name: .navigationCameraStateDidChange,
      object: navigationMapView.navigationCamera
    )

    embedding = false
    embedded = true
  }
  
  func applyStyles() {
    styleManager?.styles = [
      CustomDayStyle(
        routeCasingColor: UIColor(hex: routeCasingColor as String),
        routeAlternateColor: UIColor(hex: alternateRouteColor as String),
        routeAlternateCasingColor: UIColor(hex: alternateRouteCasingColor as String),
        traversedRouteColor: traversedRouteColor != nil ? UIColor(hex: traversedRouteColor! as String) : UIColor.clear,
        trafficUnknownColor: UIColor(hex: trafficUnknownColor as String),
        trafficLowColor: UIColor(hex: trafficLowColor as String),
        trafficModerateColor: UIColor(hex: trafficModerateColor as String),
        trafficHeavyColor: UIColor(hex: trafficHeavyColor as String),
        trafficSevereColor: UIColor(hex: trafficSevereColor as String),
        routeRestrictedAreaColor: UIColor(hex: restrictedRoadColor as String),
        maneuverArrowColor: UIColor(hex: routeArrowColor as String),
        maneuverArrowStrokeColor: UIColor(hex: routeArrowCasingColor as String),
        instructionsCardRadius: CGFloat(maneuverRadius.floatValue),
        fontFamilyName: fontFamily as String?,
        primaryColour: UIColor(hex: primaryColour as String),
        secondaryColour: UIColor(hex: secondaryColour as String),
        primaryTextColour: UIColor(hex: primaryTextColour as String),
        secondaryTextColour: UIColor(hex: secondaryTextColour as String),
        textSizeSmall: CGFloat(textSizeSmall.floatValue),
        textSizeMedium: CGFloat(textSizeMedium.floatValue),
        textSizeLarge: CGFloat(textSizeLarge.floatValue),
        textSizeXLarge: CGFloat(textSizeXLarge.floatValue)
      ),
      CustomNightStyle(
        routeCasingColor: UIColor(hex: routeCasingColor as String),
        routeAlternateColor: UIColor(hex: alternateRouteColor as String),
        routeAlternateCasingColor: UIColor(hex: alternateRouteCasingColor as String),
        traversedRouteColor: traversedRouteColor != nil ? UIColor(hex: traversedRouteColor! as String) : UIColor.clear,
        trafficUnknownColor: UIColor(hex: trafficUnknownColor as String),
        trafficLowColor: UIColor(hex: trafficLowColor as String),
        trafficModerateColor: UIColor(hex: trafficModerateColor as String),
        trafficHeavyColor: UIColor(hex: trafficHeavyColor as String),
        trafficSevereColor: UIColor(hex: trafficSevereColor as String),
        routeRestrictedAreaColor: UIColor(hex: restrictedRoadColor as String),
        maneuverArrowColor: UIColor(hex: routeArrowColor as String),
        maneuverArrowStrokeColor: UIColor(hex: routeArrowCasingColor as String),
        instructionsCardRadius: CGFloat(maneuverRadius.floatValue),
        fontFamilyName: fontFamily as String?,
        primaryColour: UIColor(hex: primaryColour as String),
        secondaryColour: UIColor(hex: secondaryColour as String),
        primaryTextColour: UIColor(hex: primaryTextColour as String),
        secondaryTextColour: UIColor(hex: secondaryTextColour as String),
        textSizeSmall: CGFloat(textSizeSmall.floatValue),
        textSizeMedium: CGFloat(textSizeMedium.floatValue),
        textSizeLarge: CGFloat(textSizeLarge.floatValue),
        textSizeXLarge: CGFloat(textSizeXLarge.floatValue)
      )
    ]
    
    styleManager?.currentStyle?.apply()
  }
  
  func setToFollow(padding: UIEdgeInsets?) {
    if (padding != nil) {
      if let navigationViewportDataSource = navigationMapView?.navigationCamera.viewportDataSource as? NavigationViewportDataSource {
        navigationViewportDataSource.options.followingCameraOptions.paddingUpdatesAllowed = false
        navigationViewportDataSource.followingMobileCamera.padding = padding
      }
    }
      
    navigationMapView.navigationCamera.follow()
  }
  
  func setToOverview(padding: UIEdgeInsets?) {
    if (padding != nil) {
      if let navigationViewportDataSource = navigationMapView?.navigationCamera.viewportDataSource as? NavigationViewportDataSource {
        navigationViewportDataSource.options.overviewCameraOptions.paddingUpdatesAllowed = false
        navigationViewportDataSource.overviewMobileCamera.padding = padding
      }
    }
    
    navigationMapView.navigationCamera.moveToOverview()
  }
  
  func setInstructionsViewAnchor() {
    instructionsCardContainerView?.topAnchor.constraint(equalTo: navigationMapView.topAnchor, constant: maneuverAnchor.indices.contains(1) ? CGFloat(maneuverAnchor[1].floatValue) : 20.0).isActive = true
    instructionsCardContainerView?.leadingAnchor.constraint(equalTo: navigationMapView.leadingAnchor, constant: maneuverAnchor.indices.contains(0) ? CGFloat(maneuverAnchor[0].floatValue) : 20.0).isActive = true
    instructionsCardContainerView?.trailingAnchor.constraint(equalTo: navigationMapView.trailingAnchor, constant: -(maneuverAnchor.indices.contains(0) ? CGFloat(maneuverAnchor[0].floatValue) : 20.0)).isActive = true
  }
  
  func setSpeedLimitAnchor() {
    speedLimitView?.topAnchor.constraint(equalTo: navigationMapView.topAnchor, constant: speedLimitAnchor.indices.contains(1) ? CGFloat(speedLimitAnchor[1].floatValue) : 10.0).isActive = true
    speedLimitView?.leadingAnchor.constraint(equalTo: navigationMapView.leadingAnchor, constant: speedLimitAnchor.indices.contains(0) ? CGFloat(speedLimitAnchor[0].floatValue) : 20.0).isActive = true
    speedLimitView?.widthAnchor.constraint(equalToConstant: speedLimitAnchor.indices.contains(2) ? CGFloat(speedLimitAnchor[2].floatValue) : 50.0).isActive = true
    speedLimitView?.heightAnchor.constraint(equalToConstant: speedLimitAnchor.indices.contains(3) ? CGFloat(speedLimitAnchor[3].floatValue) : 50.0).isActive = true
  }

  func showSpeedLimitView() {
    speedLimitView?.isAlwaysHidden = false
    speedLimitView?.isHidden = false
  }

  func hideSpeedLimitView() {
    speedLimitView?.isAlwaysHidden = true
    speedLimitView?.isHidden = true
  }

  func setLogoPadding() {
    if (logoVisible) {
      navigationMapView?.mapView.ornaments.options.logo.margins = CGPoint(
        x: logoPadding.indices.contains(0) ? CGFloat(logoPadding[0].floatValue) : 8.0,
        y: logoPadding.indices.contains(1) ? CGFloat(logoPadding[1].floatValue) : 8.0
      )
      navigationMapView?.mapView.ornaments.logoView.isHidden = false
    } else {
      navigationMapView?.mapView.ornaments.logoView.isHidden = true
    }
  }

  func setAttributionPadding() {
    if (attributionVisible) {
      navigationMapView?.mapView.ornaments.options.attributionButton.margins = CGPoint(
        x: attributionPadding.indices.contains(0) ? CGFloat(attributionPadding[0].floatValue) : 8.0,
        y: attributionPadding.indices.contains(1) ? CGFloat(attributionPadding[1].floatValue) : 8.0
      )
      navigationMapView?.mapView.ornaments.attributionButton.isHidden = false
    } else {
      navigationMapView?.mapView.ornaments.attributionButton.isHidden = true
    }
  }
  
  func toggleMute(isMuted: Bool) {
    voiceController?.speechSynthesizer.muted = isMuted
  }

  func navigationMapView(_ navigationMapView: NavigationMapView, didAdd finalDestinationAnnotation: PointAnnotation, pointAnnotationManager: PointAnnotationManager) {
    var finalDestinationAnnotation = finalDestinationAnnotation

    if (destinationImage != nil) {
      finalDestinationAnnotation.image = .init(image: destinationImage!, name: "marker")
    } else {
      let image = UIImage(named: "default_marker", in: .mapboxNavigation, compatibleWith: nil)!
      finalDestinationAnnotation.image = .init(image: image, name: "marker")
    }
 
    // `PointAnnotationManager` is used to manage `PointAnnotation`s and is also exposed as
    // a property in `NavigationMapView.pointAnnotationManager`. After any modifications to the
    // `PointAnnotation` changes must be applied to `PointAnnotationManager.annotations`
    // array. To remove all annotations for specific `PointAnnotationManager`, set an empty array.
    pointAnnotationManager.annotations = [finalDestinationAnnotation]
  }

  func navigationMapView(_ navigationMapView: NavigationMapView, waypointCircleLayerWithIdentifier identifier: String, sourceIdentifier: String) -> CircleLayer? {
    var circleLayer = CircleLayer(id: identifier)
    circleLayer.source = sourceIdentifier
    let opacity = Exp(.switchCase) {
      Exp(.any) {
        Exp(.get) {
          "waypointCompleted"
        }
      }
      0.6
      Exp(.toNumber) {
        Exp(.get) {
          "opacity"
        }
      }
    }
    let color = Exp(.toColor) {
      Exp(.get) {
        "color"
      }
    }
    let radius = Exp(.toNumber) {
      Exp(.get) {
        "radius"
      }
    }
    let strokeColor = Exp(.toColor) {
      Exp(.get) {
        "strokeColor"
      }
    }
    let strokeOpacity = Exp(.switchCase) {
      Exp(.any) {
        Exp(.get) {
          "waypointCompleted"
        }
      }
      0.6
      Exp(.toNumber) {
        Exp(.get) {
          "strokeOpacity"
        }
      }
    }
    let strokeWidth = Exp(.toNumber) {
      Exp(.get) {
        "strokeWidth"
      }
    }
    circleLayer.circleColor = .expression(color)
    circleLayer.circleOpacity = .expression(opacity)
    circleLayer.circleRadius = .expression(radius)
    circleLayer.circleStrokeColor = .expression(strokeColor)
    circleLayer.circleStrokeOpacity = .expression(strokeOpacity)
    circleLayer.circleStrokeWidth = .expression(strokeWidth)

    return circleLayer
  }
 
  func navigationMapView(_ navigationMapView: NavigationMapView, waypointSymbolLayerWithIdentifier identifier: String, sourceIdentifier: String) -> SymbolLayer? {
    var symbolLayer = SymbolLayer(id: identifier)
    symbolLayer.source = sourceIdentifier
    symbolLayer.textOpacity = .expression(Exp(.switchCase) {
      Exp(.any) {
        Exp(.get) {
          "waypointCompleted"
        }
      }
      0
      0
    })
    
    return symbolLayer
  }

  func navigationMapView(_ navigationMapView: NavigationMapView, shapeFor waypoints: [Waypoint], legIndex: Int) -> FeatureCollection? {
    var features = [Turf.Feature]()
    
    for (waypointIndex, waypoint) in waypoints.enumerated() {
      var feature = Feature(geometry: .point(Point(waypoint.coordinate)))
      feature.properties = [
        "waypointCompleted": .boolean(waypointIndex < legIndex),
        "color": .string(
          ((waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["color"] != nil)
            ? ((waypointStyles[waypointIndex]["color"]! as? NSString) ?? waypointColor)
            : waypointColor) as String),
        "radius": .number(
          Double(exactly: (waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["radius"] != nil)
            ? ((waypointStyles[waypointIndex]["radius"]! as? NSNumber) ?? waypointRadius)
            : waypointRadius)!),
        "opacity": .number(
          Double(exactly: (waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["opacity"] != nil)
            ? ((waypointStyles[waypointIndex]["opacity"]! as? NSNumber) ?? waypointOpacity)
            : waypointOpacity)!),
        "strokeColor": .string(
          ((waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["strokeColor"] != nil)
            ? ((waypointStyles[waypointIndex]["strokeColor"]! as? NSString) ?? waypointStrokeColor)
            : waypointStrokeColor) as String),
        "strokeWidth": .number(
          Double(exactly: (waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["strokeWidth"] != nil)
            ? ((waypointStyles[waypointIndex]["strokeWidth"]! as? NSNumber) ?? waypointStrokeWidth)
            : waypointStrokeWidth)!),
        "strokeOpacity": .number(
          Double(exactly: (waypointStyles.indices.contains(waypointIndex) && waypointStyles[waypointIndex]["strokeOpacity"] != nil)
            ? ((waypointStyles[waypointIndex]["strokeOpacity"]! as? NSNumber) ?? waypointStrokeOpacity)
            : waypointStrokeOpacity)!),
        "name": .number(Double(waypointIndex + 1))
      ]
      features.append(feature)
    }

    return FeatureCollection(features: features)
  }
}

class CustomDayStyle: DayStyle {
  private var routeCasingColor: UIColor
  private var routeAlternateColor: UIColor
  private var routeAlternateCasingColor: UIColor
  private var traversedRouteColor: UIColor
  private var trafficUnknownColor: UIColor
  private var trafficLowColor: UIColor
  private var trafficModerateColor: UIColor
  private var trafficHeavyColor: UIColor
  private var trafficSevereColor: UIColor
  private var routeRestrictedAreaColor: UIColor
  private var maneuverArrowColor: UIColor
  private var maneuverArrowStrokeColor: UIColor
  private var instructionsCardRadius: CGFloat
  private var fontFamilyName: String?
  private var primaryColour: UIColor
  private var secondaryColour: UIColor
  private var primaryTextColour: UIColor
  private var secondaryTextColour: UIColor
  private var textSizeSmall: CGFloat
  private var textSizeMedium: CGFloat
  private var textSizeLarge: CGFloat
  private var textSizeXLarge: CGFloat
  
  required init(
    routeCasingColor: UIColor,
    routeAlternateColor: UIColor,
    routeAlternateCasingColor: UIColor,
    traversedRouteColor: UIColor,
    trafficUnknownColor: UIColor,
    trafficLowColor: UIColor,
    trafficModerateColor: UIColor,
    trafficHeavyColor: UIColor,
    trafficSevereColor: UIColor,
    routeRestrictedAreaColor: UIColor,
    maneuverArrowColor: UIColor,
    maneuverArrowStrokeColor: UIColor,
    instructionsCardRadius: CGFloat,
    fontFamilyName: String?,
    primaryColour: UIColor,
    secondaryColour: UIColor,
    primaryTextColour: UIColor,
    secondaryTextColour: UIColor,
    textSizeSmall: CGFloat,
    textSizeMedium: CGFloat,
    textSizeLarge: CGFloat,
    textSizeXLarge: CGFloat
  ) {
    self.routeCasingColor = routeCasingColor
    self.routeAlternateColor = routeAlternateColor
    self.routeAlternateCasingColor = routeAlternateCasingColor
    self.traversedRouteColor = traversedRouteColor
    self.trafficUnknownColor = trafficUnknownColor
    self.trafficLowColor = trafficLowColor
    self.trafficModerateColor = trafficModerateColor
    self.trafficHeavyColor = trafficHeavyColor
    self.trafficSevereColor = trafficSevereColor
    self.routeRestrictedAreaColor = routeRestrictedAreaColor
    self.maneuverArrowColor = maneuverArrowColor
    self.maneuverArrowStrokeColor = maneuverArrowStrokeColor
    self.instructionsCardRadius = instructionsCardRadius
    self.fontFamilyName = fontFamilyName
    self.primaryColour = primaryColour
    self.secondaryColour = secondaryColour
    self.primaryTextColour = primaryTextColour
    self.secondaryTextColour = secondaryTextColour
    self.textSizeSmall = textSizeSmall
    self.textSizeMedium = textSizeMedium
    self.textSizeLarge = textSizeLarge
    self.textSizeXLarge = textSizeXLarge
    
    super.init()
    mapStyleURL = URL(string: StyleURI.light.rawValue)!
    styleType = .day
    statusBarStyle = .darkContent
  }
  
  required init() {
    fatalError("init() has not been implemented")
  }
  
  override func apply() {
    super.apply()
    
    let traitCollection = UIScreen.main.traitCollection
    
    let fontSmall = fontFamilyName != nil ? (UIFont(name: fontFamilyName!, size: textSizeSmall) ?? UIFont.systemFont(ofSize: textSizeSmall)) : UIFont.systemFont(ofSize: textSizeSmall)
    let fontMedium = fontFamilyName != nil ? (UIFont(name: fontFamilyName!, size: textSizeMedium) ?? UIFont.systemFont(ofSize: textSizeMedium)) : UIFont.systemFont(ofSize: textSizeMedium)
    let fontLarge = fontFamilyName != nil ? (UIFont(name: fontFamilyName!, size: textSizeLarge) ?? UIFont.systemFont(ofSize: textSizeLarge)) : UIFont.systemFont(ofSize: textSizeLarge)
    let fontXLarge = fontFamilyName != nil ? (UIFont(name: fontFamilyName!, size: textSizeXLarge) ?? UIFont.systemFont(ofSize: textSizeXLarge)) : UIFont.systemFont(ofSize: textSizeXLarge)
    
    NavigationMapView.appearance(for: traitCollection).routeCasingColor = routeCasingColor
    NavigationMapView.appearance(for: traitCollection).routeAlternateColor = routeAlternateColor
    NavigationMapView.appearance(for: traitCollection).routeAlternateCasingColor = routeAlternateCasingColor
    NavigationMapView.appearance(for: traitCollection).traversedRouteColor = traversedRouteColor
    NavigationMapView.appearance(for: traitCollection).trafficUnknownColor = trafficUnknownColor
    NavigationMapView.appearance(for: traitCollection).trafficLowColor = trafficLowColor
    NavigationMapView.appearance(for: traitCollection).trafficModerateColor = trafficModerateColor
    NavigationMapView.appearance(for: traitCollection).trafficHeavyColor = trafficHeavyColor
    NavigationMapView.appearance(for: traitCollection).trafficSevereColor = trafficSevereColor
    NavigationMapView.appearance(for: traitCollection).routeRestrictedAreaColor = routeRestrictedAreaColor
    NavigationMapView.appearance(for: traitCollection).maneuverArrowColor = maneuverArrowColor
    NavigationMapView.appearance(for: traitCollection).maneuverArrowStrokeColor = maneuverArrowStrokeColor
    
    InstructionsCardContainerView.appearance(for: traitCollection).customBackgroundColor = primaryColour
    InstructionsCardContainerView.appearance(for: traitCollection).highlightedBackgroundColor = primaryColour
    InstructionsCardContainerView.appearance(for: traitCollection).separatorColor = secondaryColour
    InstructionsCardContainerView.appearance(for: traitCollection).highlightedSeparatorColor = secondaryColour
    InstructionsCardContainerView.appearance(for: traitCollection).cornerRadius = instructionsCardRadius
    InstructionsCardContainerView.appearance(for: traitCollection).clipsToBounds = true
    
    LanesView.appearance(for: traitCollection).backgroundColor = secondaryColour
    
    LaneView.appearance(for: traitCollection).primaryColor = primaryTextColour
    LaneView.appearance(for: traitCollection).primaryColorHighlighted = primaryTextColour
    LaneView.appearance(for: traitCollection).secondaryColor = secondaryTextColour
    LaneView.appearance(for: traitCollection).secondaryColorHighlighted = secondaryTextColour
    
    ManeuverView.appearance(for: traitCollection).backgroundColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection).primaryColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection).primaryColorHighlighted = primaryTextColour
    ManeuverView.appearance(for: traitCollection).secondaryColor = secondaryTextColour
    ManeuverView.appearance(for: traitCollection).secondaryColorHighlighted = secondaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).tintColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).primaryColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).primaryColorHighlighted = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).secondaryColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).secondaryColorHighlighted = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).tintColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).primaryColorHighlighted = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = primaryTextColour
    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).secondaryColorHighlighted = primaryTextColour
    
    DistanceLabel.appearance(for: traitCollection).font = fontSmall
    DistanceLabel.appearance(for: traitCollection).normalFont = fontSmall
    DistanceLabel.appearance(for: traitCollection).unitFont = fontSmall
    DistanceLabel.appearance(for: traitCollection).valueFont = fontSmall
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).font = fontSmall
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalFont = fontSmall
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).unitFont = fontSmall
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).valueFont = fontSmall
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColor = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColorHighlighted = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalTextColor = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).unitTextColor = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).unitTextColorHighlighted = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).valueTextColor = secondaryTextColour
    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).valueTextColorHighlighted = secondaryTextColour
    
    DistanceRemainingLabel.appearance(for: traitCollection).font = fontSmall
    DistanceRemainingLabel.appearance(for: traitCollection).normalFont = fontSmall
    DistanceRemainingLabel.appearance(for: traitCollection).textColor = secondaryTextColour
    DistanceRemainingLabel.appearance(for: traitCollection).textColorHighlighted = secondaryTextColour
    DistanceRemainingLabel.appearance(for: traitCollection).normalTextColor = secondaryTextColour
    
    PrimaryLabel.appearance(for: traitCollection).font = fontXLarge
    PrimaryLabel.appearance(for: traitCollection).normalFont = fontXLarge
    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColor = primaryTextColour
    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColorHighlighted = primaryTextColour
    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalTextColor = primaryTextColour
    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).font = fontXLarge
    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalFont = fontXLarge
    
    InstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).font = fontLarge
    InstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalFont = fontLarge
    InstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).normalTextColor = primaryTextColour
    InstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColor = primaryTextColour
    InstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardView.self]).textColorHighlighted = primaryTextColour
    
    NextBannerView.appearance(for: traitCollection).backgroundColor = secondaryColour
    NextBannerView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsCardContainerView.self]).backgroundColor = secondaryColour
    
    NextInstructionLabel.appearance(for: traitCollection).font = fontMedium
    NextInstructionLabel.appearance(for: traitCollection).normalFont = fontMedium
    NextInstructionLabel.appearance(for: traitCollection).textColor = primaryTextColour
    NextInstructionLabel.appearance(for: traitCollection).textColorHighlighted = primaryTextColour
    NextInstructionLabel.appearance(for: traitCollection).normalTextColor = primaryTextColour
    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).font = fontMedium
    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).normalFont = fontMedium
    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).textColor = primaryTextColour
    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).textColorHighlighted = primaryTextColour
    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).normalTextColor = primaryTextColour
  }
}

class CustomNightStyle: CustomDayStyle {
  required init(
    routeCasingColor: UIColor,
    routeAlternateColor: UIColor,
    routeAlternateCasingColor: UIColor,
    traversedRouteColor: UIColor,
    trafficUnknownColor: UIColor,
    trafficLowColor: UIColor,
    trafficModerateColor: UIColor,
    trafficHeavyColor: UIColor,
    trafficSevereColor: UIColor,
    routeRestrictedAreaColor: UIColor,
    maneuverArrowColor: UIColor,
    maneuverArrowStrokeColor: UIColor,
    instructionsCardRadius: CGFloat,
    fontFamilyName: String?,
    primaryColour: UIColor,
    secondaryColour: UIColor,
    primaryTextColour: UIColor,
    secondaryTextColour: UIColor,
    textSizeSmall: CGFloat,
    textSizeMedium: CGFloat,
    textSizeLarge: CGFloat,
    textSizeXLarge: CGFloat
  ) {
    super.init(
      routeCasingColor: routeCasingColor,
      routeAlternateColor: routeAlternateColor,
      routeAlternateCasingColor: routeAlternateCasingColor,
      traversedRouteColor: traversedRouteColor,
      trafficUnknownColor: trafficUnknownColor,
      trafficLowColor: trafficLowColor,
      trafficModerateColor: trafficModerateColor,
      trafficHeavyColor: trafficHeavyColor,
      trafficSevereColor: trafficSevereColor,
      routeRestrictedAreaColor: routeRestrictedAreaColor,
      maneuverArrowColor: maneuverArrowColor,
      maneuverArrowStrokeColor: maneuverArrowStrokeColor,
      instructionsCardRadius: instructionsCardRadius,
      fontFamilyName: fontFamilyName,
      primaryColour: primaryColour,
      secondaryColour: secondaryColour,
      primaryTextColour: primaryTextColour,
      secondaryTextColour: secondaryTextColour,
      textSizeSmall: textSizeSmall,
      textSizeMedium: textSizeMedium,
      textSizeLarge: textSizeLarge,
      textSizeXLarge: textSizeXLarge
    )
    mapStyleURL = URL(string: StyleURI.dark.rawValue)!
    styleType = .night
    statusBarStyle = .lightContent
  }
  
  required init() {
    fatalError("init() has not been implemented")
  }
  
  override func apply() {
    super.apply()
  }
}

extension MapboxNavigationFreeDriveView: StyleManagerDelegate {
    
  public func location(for styleManager: MapboxNavigation.StyleManager) -> CLLocation? {
    let passiveLocationProvider = navigationMapView?.mapView.location.locationProvider as? PassiveLocationProvider
    return passiveLocationProvider?.locationManager.location ?? CLLocationManager().location
  }
    
  public func styleManager(_ styleManager: MapboxNavigation.StyleManager, didApply style: MapboxNavigation.Style) {
    if navigationMapView?.mapView.mapboxMap.style.uri?.rawValue != style.mapStyleURL.absoluteString {
      navigationMapView?.mapView.mapboxMap.style.uri = StyleURI(url: style.mapStyleURL)
    }
  }
}

extension Bundle {
  static func infoPlistValue(forKey key: String) -> Any? {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) else {
      return nil
    }
    
    return value
  }
}

extension UIColor {
  convenience init(hex: String) {
    let hexString: String = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = UInt64()
    Scanner(string: hexString).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hexString.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }

  var RGBAString: String {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return "rgba(0,0,0,1)"
    }
    
    return "rgba(\(Double(red * 255)),\(Double(green * 255)),\(Double(blue * 255)),\(Double(alpha)))"
  }
}
