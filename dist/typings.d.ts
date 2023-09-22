import { StyleProp, ViewStyle } from 'react-native';
/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */
type Coordinate = [number, number];
type OnLocationChangeEvent = {
    nativeEvent?: {
        latitude: number;
        longitude: number;
        roadName: string;
        speed: number;
        bearing: number;
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
export {};
