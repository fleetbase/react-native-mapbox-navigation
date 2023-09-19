import * as React from 'react';
import { Platform, findNodeHandle, requireNativeComponent, UIManager, StyleSheet, Image } from 'react-native';
const MapboxNavigation = (props) => {
    return <RNMapboxNavigation style={styles.container} {...props}/>;
};
const MapboxNavigationFreeDrive = React.forwardRef((props, ref) => {
    const mapboxNavigationFreeDriveRef = React.useRef();
    React.useImperativeHandle(ref, () => ({
        showRoute,
        clearRoute,
        follow,
        moveToOverview,
        fitCamera,
        startNavigation,
        pauseNavigation,
        stopNavigation
    }));
    const showRoute = (origin = [], destination = [], waypoints = [], styles = [], legIndex = -1, cameraType = 'none', padding = []) => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.showRouteViaManager, [origin, destination, waypoints, styles, legIndex, cameraType, padding]);
    };
    const clearRoute = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.clearRouteViaManager, []);
    };
    const follow = (padding = []) => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.followViaManager, [padding]);
    };
    const moveToOverview = (padding = []) => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.moveToOverviewViaManager, [padding]);
    };
    const fitCamera = (padding = []) => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.fitCameraViaManager, [padding]);
    };
    const startNavigation = (origin = [], destination = [], waypoints = [], styles = [], legIndex = -1, cameraType = 'none', padding = []) => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.startNavigationViaManager, [origin, destination, waypoints, styles, legIndex, cameraType, padding]);
    };
    const pauseNavigation = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.pauseNavigationViaManager, []);
    };
    const stopNavigation = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(mapboxNavigationFreeDriveRef.current), UIManager.MapboxNavigationFreeDrive.Commands.stopNavigationViaManager, []);
    };
    const getUserImage = () => {
        if (Platform.OS === 'ios' || !props.userPuckImage) {
            return props.userPuckImage;
        }
        else {
            return (Image.resolveAssetSource(props.userPuckImage) || {}).uri;
        }
    };
    const getOriginImage = () => {
        if (Platform.OS === 'ios' || !props.originImage) {
            return props.originImage;
        }
        else {
            return (Image.resolveAssetSource(props.originImage) || {}).uri;
        }
    };
    const getDestinationImage = () => {
        if (Platform.OS === 'ios' || !props.destinationImage) {
            return props.destinationImage;
        }
        else {
            return (Image.resolveAssetSource(props.destinationImage) || {}).uri;
        }
    };
    return <RNMapboxNavigationFreeDrive ref={mapboxNavigationFreeDriveRef} style={styles.container} {...Object.assign(Object.assign({}, props), { userPuckImage: getUserImage(), originImage: getOriginImage(), destinationImage: getDestinationImage() })}/>;
});
const RNMapboxNavigation = requireNativeComponent('MapboxNavigation', MapboxNavigation);
const RNMapboxNavigationFreeDrive = requireNativeComponent('MapboxNavigationFreeDrive', MapboxNavigationFreeDrive);
const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});
export { MapboxNavigation, MapboxNavigationFreeDrive };
