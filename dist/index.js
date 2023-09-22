"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HelloLog = exports.Hello = exports.TestFunction = void 0;
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
const TestFunction = (x, y) => {
    return x * y;
};
exports.TestFunction = TestFunction;
const Hello = (who) => {
    return `Hello ${who}`;
};
exports.Hello = Hello;
const HelloLog = (who) => {
    return console.log((0, exports.Hello)(who));
};
exports.HelloLog = HelloLog;
exports.default = MapboxNavigation;
