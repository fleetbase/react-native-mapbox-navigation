#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(MapboxNavigationFreeDriveManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onLocationChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onTrackingStateChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRouteChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRouteProgressChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onManeuverSizeChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(showSpeedLimit, BOOL)
RCT_EXPORT_VIEW_PROPERTY(speedLimitAnchor, NSArray)
RCT_EXPORT_VIEW_PROPERTY(maneuverAnchor, NSArray)
RCT_EXPORT_VIEW_PROPERTY(maneuverRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(maneuverBackgroundColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(followZoomLevel, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(userPuckImage, UIImage)
RCT_EXPORT_VIEW_PROPERTY(userPuckScale, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(originImage, UIImage)
RCT_EXPORT_VIEW_PROPERTY(destinationImage, UIImage)
RCT_EXPORT_VIEW_PROPERTY(mapPadding, NSArray)
RCT_EXPORT_VIEW_PROPERTY(logoVisible, NSArray)
RCT_EXPORT_VIEW_PROPERTY(logoPadding, NSArray)
RCT_EXPORT_VIEW_PROPERTY(attributionVisible, NSArray)
RCT_EXPORT_VIEW_PROPERTY(attributionPadding, NSArray)
RCT_EXPORT_VIEW_PROPERTY(routeColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(routeCasingColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(routeClosureColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(alternateRouteColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(alternateRouteCasingColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(traversedRouteColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(traversedRouteCasingColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(trafficUnknownColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(trafficLowColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(trafficModerateColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(trafficHeavyColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(trafficSevereColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(restrictedRoadColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(waypointColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(waypointRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(waypointOpacity, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(waypointStrokeWidth, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(waypointStrokeOpacity, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(waypointStrokeColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(mute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(darkMode, BOOL)
RCT_EXPORT_VIEW_PROPERTY(debug, BOOL)
RCT_EXPORT_VIEW_PROPERTY(fontFamily, NSString)
RCT_EXPORT_VIEW_PROPERTY(primaryColour, NSString)
RCT_EXPORT_VIEW_PROPERTY(secondaryColour, NSString)
RCT_EXPORT_VIEW_PROPERTY(primaryTextColour, NSString)
RCT_EXPORT_VIEW_PROPERTY(secondaryTextColour, NSString)
RCT_EXPORT_VIEW_PROPERTY(textSizeSmall, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(textSizeMedium, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(textSizeLarge, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(textSizeXLarge, NSNumber)

RCT_EXTERN_METHOD(
  showRouteViaManager: (nonnull NSNumber *)node 
  origin: (NSArray *)origin 
  destination: (NSArray *)destination 
  waypoints: (NSArray *)waypoints 
  styles: (NSDictionaryArray *)styles 
  legIndex: (nonnull NSNumber *)legIndex 
  cameraType: (NSString *)cameraType 
  padding: (NSArray *)padding
)

RCT_EXTERN_METHOD(
  clearRouteViaManager: (nonnull NSNumber *)node
)

RCT_EXTERN_METHOD(
  followViaManager: (nonnull NSNumber *)node
  padding: (NSArray *)padding
)

RCT_EXTERN_METHOD(
  moveToOverviewViaManager: (nonnull NSNumber *)node
  padding: (NSArray *)padding
)

RCT_EXTERN_METHOD(
  fitCameraViaManager: (nonnull NSNumber *)node
  padding: (NSArray *)padding
)

RCT_EXTERN_METHOD(
  startNavigationViaManager: (nonnull NSNumber *)node
  origin: (NSArray *)origin 
  destination: (NSArray *)destination 
  waypoints: (NSArray *)waypoints 
  styles: (NSDictionaryArray *)styles 
  legIndex: (nonnull NSNumber *)legIndex 
  cameraType: (NSString *)cameraType 
  padding: (NSArray *)padding
)

RCT_EXTERN_METHOD(
  pauseNavigationViaManager: (nonnull NSNumber *)node
)

RCT_EXTERN_METHOD(
  stopNavigationViaManager: (nonnull NSNumber *)node
)

@end