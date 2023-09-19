/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */
type Coordinate = [number, number];
type Padding = [number, number, number, number];

type OnLocationChangeEvent = {
  nativeEvent?: {
    latitude: number;
    longitude: number;
    roadName: string;
    speed: number;
    bearing: number;
  };
};

type OnTrackingStateChangeEvent = {
  nativeEvent?: {
    state: string
  }
}

type OnRouteChangeEvent = {
  nativeEvent?: {
    distance: number;
    expectedTravelTime: number;
    typicalTravelTime: number;
  }
}

type OnRouteProgressChangeEvent = {
  nativeEvent?: {
    distanceTraveled: number;
    distanceRemaining: number;
    timeTraveled: number;
    timeRemaining: number;
    progress: number;
  };
};

type OnErrorEvent = {
  nativeEvent?: {
    message?: string;
  };
};

type OnManeuverSizeChangeEvent = {
  nativeEvent?: {
    width?: number;
    height?: number;
  };
}

export interface IMapboxNavigationProps {
  origin: Coordinate;
  destination: Coordinate;
  shouldSimulateRoute?: boolean;
  onLocationChange?: (event: OnLocationChangeEvent) => void;
  onRouteProgressChange?: (event: OnRouteProgressChangeEvent) => void;
  onError?: (event: OnErrorEvent) => void;
  onCancelNavigation?: () => void;
  onArrive?: () => void;
  showsEndOfRouteFeedback?: boolean;
  hideStatusView?: boolean;
  mute?: boolean;
}

export interface IMapboxNavigationFreeDriveProps {
  onLocationChange?: (event: OnLocationChangeEvent) => void;
  onTrackingStateChange?: (event: OnTrackingStateChangeEvent) => void;
  onRouteChange?: (event: OnRouteChangeEvent) => void;
  onRouteProgressChange?: (event: OnRouteProgressChangeEvent) => void;
  onError?: (event: OnErrorEvent) => void;
  onManeuverSizeChange?: (event: OnManeuverSizeChangeEvent) => void;
  showSpeedLimit?: boolean;
  speedLimitAnchor?: Padding;
  maneuverAnchor?: Padding;
  maneuverRadius?: number;
  maneuverBackgroundColor?: string;
  followZoomLevel?: number;
  userPuckImage?: number;
  userPuckScale?: number;
  destinationImage?: number;
  originImage?: number;
  mapPadding?: Padding;
  logoVisible?: boolean;
  logoPadding?: Coordinate;
  attributionVisible?: boolean;
  attributionPadding?: Coordinate;
  routeColor?: string;
  routeCasingColor?: string;
  routeClosureColor?: string;
  alternateRouteColor?: string;
  alternateRouteCasingColor?: string;
  traversedRouteColor?: string;
  traversedRouteCasingColor?: string;
  trafficUnknownColor?: string;
  trafficLowColor?: string;
  trafficModerateColor?: string;
  trafficHeavyColor?: string;
  trafficSevereColor?: string;
  restrictedRoadColor?: string;
  waypointColor?: string;
  waypointRadius?: number;
  waypointOpacity?: number;
  waypointStrokeWidth?: number;
  waypointStrokeOpacity?: number;
  waypointStrokeColor?: string;
  mute?: boolean;
  darkMode?: boolean;
  debug?: boolean;
  fontFamily?: string;
  primaryColour?: string;
  secondaryColour?: string;
  primaryTextColour?: string;
  secondaryTextColour?: string;
  textSizeSmall?: number;
  textSizeMedium?: number;
  textSizeLarge?: number;
  textSizeXLarge?: number;
}