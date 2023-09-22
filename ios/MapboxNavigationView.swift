import MapboxCoreNavigation
import MapboxDirections
import MapboxMaps
import MapboxNavigation

// // adapted from https://pspdfkit.com/blog/2017/native-view-controllers-and-react-native/ and https://github.com/mslabenyak/react-native-mapbox-navigation/blob/master/ios/Mapbox/MapboxNavigationView.swift
// extension UIView {
//   var parentViewController: UIViewController? {
//     var parentResponder: UIResponder? = self
//     while parentResponder != nil {
//       parentResponder = parentResponder!.next
//       if let viewController = parentResponder as? UIViewController {
//         return viewController
//       }
//     }
//     return nil
//   }
// }

class MapboxNavigationView: UIView, NavigationMapViewDelegate, NavigationViewControllerDelegate {
  var navigationMapView: NavigationMapView!
  var navigationRouteOptions: NavigationRouteOptions!
  var embedded: Bool
  var embedding: Bool

  @objc var origin: NSArray = []
  @objc var destination: NSArray = []
  @objc var shouldSimulateRoute: Bool = false
  @objc var showsEndOfRouteFeedback: Bool = false
  @objc var hideStatusView: Bool = false
  @objc var mute: Bool = false

  @objc var onLocationChange: RCTDirectEventBlock?
  @objc var onRouteProgressChange: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onCancelNavigation: RCTDirectEventBlock?
  @objc var onArrive: RCTDirectEventBlock?

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

    if navigationMapView == nil && !embedding && !embedded {
      embed()
    } else {
      navigationMapView?.frame = bounds
    }
  }

  override func removeFromSuperview() {
    super.removeFromSuperview()
    // cleanup and teardown any existing resources
    navigationMapView?.removeFromSuperview()
  }

  private func embed() {
    embedding = true

    navigationMapView = NavigationMapView(frame: bounds)
    navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    navigationMapView.delegate = self
    navigationMapView.userLocationStyle = .puck2D()

    let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
    navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
    navigationViewportDataSource.followingMobileCamera.zoom = 13.0
    navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource

    addSubview(navigationMapView)

    embedding = false
    embedded = true
  }

  func navigationViewController(
    _ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress,
    with location: CLLocation, rawLocation: CLLocation
  ) {
    onLocationChange?([
      "longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude,
    ])
    onRouteProgressChange?([
      "distanceTraveled": progress.distanceTraveled,
      "durationRemaining": progress.durationRemaining,
      "fractionTraveled": progress.fractionTraveled,
      "distanceRemaining": progress.distanceRemaining,
    ])
  }

  func navigationViewControllerDidDismiss(
    _ navigationViewController: NavigationViewController, byCanceling canceled: Bool
  ) {
    if !canceled {
      return
    }
    onCancelNavigation?(["message": ""])
  }

  func navigationViewController(
    _ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint
  ) -> Bool {
    onArrive?(["message": ""])
    return true
  }
}
