package com.fleetbase.mapboxnavigation

import android.content.pm.PackageManager
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.mapbox.geojson.Point
import com.mapbox.maps.ResourceOptionsManager
import com.mapbox.maps.TileStoreUsageMode
import javax.annotation.Nonnull

class MapboxNavigationFreeDriveManager(var mCallerContext: ReactApplicationContext) : SimpleViewManager<MapboxNavigationFreeDriveView>() {
    private var accessToken: String? = null

    init {
        mCallerContext.runOnUiQueueThread {
            try {
                val app = mCallerContext.packageManager.getApplicationInfo(mCallerContext.packageName, PackageManager.GET_META_DATA)
                val bundle = app.metaData
                val accessToken = bundle.getString("MAPBOX_ACCESS_TOKEN")
                this.accessToken = accessToken
                ResourceOptionsManager.getDefault(mCallerContext, accessToken).update {
                    tileStoreUsageMode(TileStoreUsageMode.READ_ONLY)
                }
            } catch (e: PackageManager.NameNotFoundException) {
                e.printStackTrace()
            }
        }
    }

    override fun getName(): String {
        return "MapboxNavigationFreeDrive"
    }

    public override fun createViewInstance(@Nonnull reactContext: ThemedReactContext): MapboxNavigationFreeDriveView {
        return MapboxNavigationFreeDriveView(reactContext, this.accessToken)
    }

    override fun onDropViewInstance(view: MapboxNavigationFreeDriveView) {
        view.onDropViewInstance()
        super.onDropViewInstance(view)
    }

    override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Map<String, String>>? {
        return MapBuilder.of<String, Map<String, String>>(
            "onLocationChange", MapBuilder.of("registrationName", "onLocationChange"),
            "onRouteProgressChange", MapBuilder.of("registrationName", "onRouteProgressChange"),
            "onRouteChange", MapBuilder.of("registrationName", "onRouteChange"),
            "onTrackingStateChange", MapBuilder.of("registrationName", "onTrackingStateChange"),
            "onError", MapBuilder.of("registrationName", "onError"),
            "onManeuverSizeChange", MapBuilder.of("registrationName", "onManeuverSizeChange")
        )
    }

    override fun getCommandsMap(): MutableMap<String, Int> {
        return mutableMapOf(
            "showRouteViaManager" to 1,
            "clearRouteViaManager" to 2,
            "followViaManager" to 3,
            "moveToOverviewViaManager" to 4,
            "fitCameraViaManager" to 5,
            "startNavigationViaManager" to 6,
            "pauseNavigationViaManager" to 7,
            "stopNavigationViaManager" to 8
        )
    }

    override fun receiveCommand(view: MapboxNavigationFreeDriveView, commandId: Int, args: ReadableArray?) {
        when (commandId) {
            1 -> view.showRoute(args?.getArray(0), args?.getArray(1), args?.getArray(2), args?.getArray(3), args?.getInt(4), args?.getString(5), args?.getArray(6))
            2 -> view.clearRoute()
            3 -> view.follow(args?.getArray(0))
            4 -> view.moveToOverview(args?.getArray(0))
            5 -> view.fitCamera(args?.getArray(0))
            6 -> view.startNavigation(args?.getArray(0), args?.getArray(1), args?.getArray(2), args?.getArray(3), args?.getInt(4), args?.getString(5), args?.getArray(6))
            7 -> view.pauseNavigation()
            8 -> view.stopNavigation()
        }
    }

    @ReactProp(name = "showSpeedLimit")
    fun setShowSpeedLimit(view: MapboxNavigationFreeDriveView, showSpeedLimit: Boolean) {
        view.setShowSpeedLimit(showSpeedLimit)
    }

    @ReactProp(name = "speedLimitAnchor")
    fun setSpeedLimitAnchor(view: MapboxNavigationFreeDriveView, speedLimitAnchor: ReadableArray?) {
        view.setSpeedLimitAnchor(speedLimitAnchor)
    }

    @ReactProp(name = "maneuverAnchor")
    fun setManeuverAnchor(view: MapboxNavigationFreeDriveView, maneuverAnchor: ReadableArray?) {
        view.setManeuverAnchor(maneuverAnchor)
    }

    @ReactProp(name = "maneuverRadius")
    fun setManeuverRadius(view: MapboxNavigationFreeDriveView, maneuverRadius: Int) {
        view.setManeuverRadius(maneuverRadius)
    }

    @ReactProp(name = "maneuverBackgroundColor")
    fun setManeuverBackgroundColor(view: MapboxNavigationFreeDriveView, maneuverBackgroundColor: String?) {
        view.setManeuverBackgroundColor(maneuverBackgroundColor)
    }
    
    @ReactProp(name = "followZoomLevel")
    fun setFollowZoomLevel(view: MapboxNavigationFreeDriveView, followZoomLevel: Double) {
        view.setFollowZoomLevel(followZoomLevel)
    }
    
    @ReactProp(name = "userPuckImage")
    fun setUserPuckImage(view: MapboxNavigationFreeDriveView, userPuckImage: String?) {
        view.setUserPuckImage(userPuckImage)
    }
    
    @ReactProp(name = "userPuckScale")
    fun setUserPuckScale(view: MapboxNavigationFreeDriveView, userPuckScale: Double) {
        view.setUserPuckScale(userPuckScale)
    }
    
    @ReactProp(name = "originImage")
    fun setOriginImage(view: MapboxNavigationFreeDriveView, originImage: String?) {
        view.setOriginImage(originImage)
    }
    
    @ReactProp(name = "destinationImage")
    fun setDestinationImage(view: MapboxNavigationFreeDriveView, destinationImage: String?) {
        view.setDestinationImage(destinationImage)
    }
    
    @ReactProp(name = "mapPadding")
    fun setMapPadding(view: MapboxNavigationFreeDriveView, mapPadding: ReadableArray?) {
        view.setMapPadding(mapPadding)
    }
    
    @ReactProp(name = "logoVisible")
    fun setLogoVisible(view: MapboxNavigationFreeDriveView, logoVisible: Boolean) {
        view.setLogoVisible(logoVisible)
    }
    
    @ReactProp(name = "logoPadding")
    fun setLogoPadding(view: MapboxNavigationFreeDriveView, logoPadding: ReadableArray?) {
        view.setLogoPadding(logoPadding)
    }
    
    @ReactProp(name = "attributionVisible")
    fun setAttributionVisible(view: MapboxNavigationFreeDriveView, attributionVisible: Boolean) {
        view.setAttributionVisible(attributionVisible)
    }
    
    @ReactProp(name = "attributionPadding")
    fun setAttributionPadding(view: MapboxNavigationFreeDriveView, attributionPadding: ReadableArray?) {
        view.setAttributionPadding(attributionPadding)
    }
    
    @ReactProp(name = "routeColor")
    fun setRouteColor(view: MapboxNavigationFreeDriveView, routeColor: String) {
        view.setRouteColor(routeColor)
    }
    
    @ReactProp(name = "routeCasingColor")
    fun setRouteCasingColor(view: MapboxNavigationFreeDriveView, routeCasingColor: String) {
        view.setRouteCasingColor(routeCasingColor)
    }
    
    @ReactProp(name = "routeClosureColor")
    fun setRouteClosureColor(view: MapboxNavigationFreeDriveView, routeClosureColor: String) {
        view.setRouteClosureColor(routeClosureColor)
    }
    
    @ReactProp(name = "alternateRouteColor")
    fun setAlternateRouteColor(view: MapboxNavigationFreeDriveView, alternateRouteColor: String) {
        view.setAlternateRouteColor(alternateRouteColor)
    }
    
    @ReactProp(name = "alternateRouteCasingColor")
    fun setAlternateRouteCasingColor(view: MapboxNavigationFreeDriveView, alternateRouteCasingColor: String) {
        view.setAlternateRouteCasingColor(alternateRouteCasingColor)
    }
    
    @ReactProp(name = "traversedRouteColor")
    fun setTraversedRouteColor(view: MapboxNavigationFreeDriveView, traversedRouteColor: String?) {
        view.setTraversedRouteColor(traversedRouteColor)
    }
    
    @ReactProp(name = "traversedRouteCasingColor")
    fun setTraversedRouteCasingColor(view: MapboxNavigationFreeDriveView, traversedRouteCasingColor: String?) {
        view.setTraversedRouteCasingColor(traversedRouteCasingColor)
    }
    
    @ReactProp(name = "trafficUnknownColor")
    fun setTrafficUnknownColor(view: MapboxNavigationFreeDriveView, trafficUnknownColor: String) {
        view.setTrafficUnknownColor(trafficUnknownColor)
    }
    
    @ReactProp(name = "trafficLowColor")
    fun setTrafficLowColor(view: MapboxNavigationFreeDriveView, trafficLowColor: String) {
        view.setTrafficLowColor(trafficLowColor)
    }
    
    @ReactProp(name = "trafficModerateColor")
    fun setTrafficModerateColor(view: MapboxNavigationFreeDriveView, trafficModerateColor: String) {
        view.setTrafficModerateColor(trafficModerateColor)
    }
    
    @ReactProp(name = "trafficHeavyColor")
    fun setTrafficHeavyColor(view: MapboxNavigationFreeDriveView, trafficHeavyColor: String) {
        view.setTrafficHeavyColor(trafficHeavyColor)
    }
    
    @ReactProp(name = "trafficSevereColor")
    fun setTrafficSevereColor(view: MapboxNavigationFreeDriveView, trafficSevereColor: String) {
        view.setTrafficSevereColor(trafficSevereColor)
    }
    
    @ReactProp(name = "restrictedRoadColor")
    fun setRestrictedRoadColor(view: MapboxNavigationFreeDriveView, restrictedRoadColor: String) {
        view.setRestrictedRoadColor(restrictedRoadColor)
    }
    
    @ReactProp(name = "waypointColor")
    fun setWaypointColor(view: MapboxNavigationFreeDriveView, waypointColor: String) {
        view.setWaypointColor(waypointColor)
    }
    
    @ReactProp(name = "waypointRadius")
    fun setWaypointRadius(view: MapboxNavigationFreeDriveView, waypointRadius: Int) {
        view.setWaypointRadius(waypointRadius)
    }
    
    @ReactProp(name = "waypointOpacity")
    fun setWaypointOpacity(view: MapboxNavigationFreeDriveView, waypointOpacity: Int) {
        view.setWaypointOpacity(waypointOpacity)
    }
    
    @ReactProp(name = "waypointStrokeWidth")
    fun setWaypointStrokeWidth(view: MapboxNavigationFreeDriveView, waypointStrokeWidth: Int) {
        view.setWaypointStrokeWidth(waypointStrokeWidth)
    }
    
    @ReactProp(name = "waypointStrokeOpacity")
    fun setWaypointStrokeOpacity(view: MapboxNavigationFreeDriveView, waypointStrokeOpacity: Int) {
        view.setWaypointStrokeOpacity(waypointStrokeOpacity)
    }
    
    @ReactProp(name = "waypointStrokeColor")
    fun setWaypointStrokeColor(view: MapboxNavigationFreeDriveView, waypointStrokeColor: String) {
        view.setWaypointStrokeColor(waypointStrokeColor)
    }
    
    @ReactProp(name = "mute")
    fun setMute(view: MapboxNavigationFreeDriveView, mute: Boolean) {
        view.setMute(mute)
    }
    
    @ReactProp(name = "darkMode")
    fun setDarkMode(view: MapboxNavigationFreeDriveView, darkMode: Boolean) {
        view.setDarkMode(darkMode)
    }
    
    @ReactProp(name = "debug")
    fun setDebug(view: MapboxNavigationFreeDriveView, debug: Boolean) {
        view.setDebug(debug)
    }

    @ReactProp(name = "fontFamily")
    fun setFontFamily(view: MapboxNavigationFreeDriveView, fontFamily: String?) {
        view.setFontFamily(fontFamily)
    }

    @ReactProp(name = "primaryColour")
    fun setPrimaryColour(view: MapboxNavigationFreeDriveView, primaryColour: String) {
        view.setPrimaryColour(primaryColour)
    }

    @ReactProp(name = "secondaryColour")
    fun setSecondaryColour(view: MapboxNavigationFreeDriveView, secondaryColour: String) {
        view.setSecondaryColour(secondaryColour)
    }

    @ReactProp(name = "primaryTextColour")
    fun setPrimaryTextColour(view: MapboxNavigationFreeDriveView, primaryTextColour: String) {
        view.setPrimaryTextColour(primaryTextColour)
    }

    @ReactProp(name = "secondaryTextColour")
    fun setSecondaryTextColour(view: MapboxNavigationFreeDriveView, secondaryTextColour: String) {
        view.setSecondaryTextColour(secondaryTextColour)
    }

    @ReactProp(name = "textSizeSmall")
    fun setTextSizeSmall(view: MapboxNavigationFreeDriveView, textSizeSmall: Double) {
        view.setTextSizeSmall(textSizeSmall)
    }

    @ReactProp(name = "textSizeMedium")
    fun setTextSizeMedium(view: MapboxNavigationFreeDriveView, textSizeMedium: Double) {
        view.setTextSizeMedium(textSizeMedium)
    }
    
    @ReactProp(name = "textSizeLarge")
    fun setTextSizeLarge(view: MapboxNavigationFreeDriveView, textSizeLarge: Double) {
        view.setTextSizeLarge(textSizeLarge)
    }
    
    @ReactProp(name = "textSizeXLarge")
    fun setTextSizeXLarge(view: MapboxNavigationFreeDriveView, textSizeXLarge: Double) {
        view.setTextSizeXLarge(textSizeXLarge)
    }
}
