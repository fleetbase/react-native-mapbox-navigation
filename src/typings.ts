import { StyleProp, ViewStyle } from 'react-native';
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
        state: string;
    };
};

type OnRouteChangeEvent = {
    nativeEvent?: {
        distance: number;
        expectedTravelTime: number;
        typicalTravelTime: number;
    };
};

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
};

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
    style?: StyleProp<ViewStyle>;
}