"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const React = require("react");
const react_native_1 = require("react-native");
const MapboxNavigation = (props) => {
    return <RNMapboxNavigation style={styles.container} {...props}/>;
};
const RNMapboxNavigation = (0, react_native_1.requireNativeComponent)('MapboxNavigation');
const styles = react_native_1.StyleSheet.create({
    container: {
        flex: 1,
    },
});
exports.default = MapboxNavigation;
