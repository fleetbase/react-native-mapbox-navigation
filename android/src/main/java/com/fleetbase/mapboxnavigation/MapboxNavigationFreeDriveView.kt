package com.fleetbase.mapboxnavigation

import android.annotation.SuppressLint
import android.content.res.Configuration
import android.content.res.Resources
import android.location.Location
import android.location.LocationManager
import android.view.LayoutInflater
import android.view.View
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.Toast
import android.graphics.Color
import android.net.Uri
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.Arguments
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.views.imagehelper.ResourceDrawableIdHelper
import com.mapbox.api.directions.v5.DirectionsCriteria
import com.mapbox.api.directions.v5.models.Bearing
import com.mapbox.api.directions.v5.models.RouteOptions
import com.mapbox.api.directions.v5.models.DirectionsRoute
import com.mapbox.bindgen.Expected
import com.mapbox.geojson.Point
import com.mapbox.maps.EdgeInsets
import com.mapbox.maps.MapView
import com.mapbox.maps.MapboxMap
import com.mapbox.maps.Style
import com.mapbox.maps.plugin.LocationPuck2D
import com.mapbox.maps.plugin.animation.camera
import com.mapbox.maps.plugin.locationcomponent.LocationComponentPlugin
import com.mapbox.maps.plugin.locationcomponent.OnIndicatorPositionChangedListener
import com.mapbox.maps.plugin.locationcomponent.location
import com.mapbox.maps.plugin.compass.compass
import com.mapbox.maps.plugin.scalebar.scalebar
import com.mapbox.maps.plugin.gestures.*
import com.mapbox.maps.plugin.attribution.*
import com.mapbox.maps.plugin.logo.*
import com.mapbox.navigation.base.ExperimentalMapboxNavigationAPI
import com.mapbox.navigation.base.ExperimentalPreviewMapboxNavigationAPI
import com.mapbox.navigation.base.TimeFormat
import com.mapbox.navigation.base.extensions.applyDefaultNavigationOptions
import com.mapbox.navigation.base.extensions.applyLanguageAndVoiceUnitOptions
import com.mapbox.navigation.base.options.NavigationOptions
import com.mapbox.navigation.base.route.NavigationRoute
import com.mapbox.navigation.base.route.NavigationRouterCallback
import com.mapbox.navigation.base.route.RouterCallback
import com.mapbox.navigation.base.route.RouterFailure
import com.mapbox.navigation.base.route.RouterOrigin
import com.mapbox.navigation.base.route.RouteAlternativesOptions
import com.mapbox.navigation.core.MapboxNavigation
import com.mapbox.navigation.core.MapboxNavigationProvider
import com.mapbox.navigation.core.directions.session.RoutesObserver
import com.mapbox.navigation.core.formatter.MapboxDistanceFormatter
import com.mapbox.navigation.core.replay.MapboxReplayer
import com.mapbox.navigation.core.replay.ReplayLocationEngine
import com.mapbox.navigation.core.replay.route.ReplayProgressObserver
import com.mapbox.navigation.core.replay.route.ReplayRouteMapper
import com.mapbox.navigation.core.routealternatives.NavigationRouteAlternativesObserver
import com.mapbox.navigation.core.routealternatives.RouteAlternativesError
import com.mapbox.navigation.core.trip.session.LocationMatcherResult
import com.mapbox.navigation.core.trip.session.LocationObserver
import com.mapbox.navigation.core.trip.session.RouteProgressObserver
import com.mapbox.navigation.core.trip.session.VoiceInstructionsObserver
import com.fleetbase.mapboxnavigation.databinding.NavigationViewBinding
import com.mapbox.navigation.base.trip.model.RouteLegProgress
import com.mapbox.navigation.base.trip.model.RouteProgress
import com.mapbox.navigation.core.arrival.ArrivalObserver
import com.mapbox.navigation.ui.base.util.MapboxNavigationConsumer
import com.mapbox.navigation.ui.maneuver.api.MapboxManeuverApi
import com.mapbox.navigation.ui.maneuver.view.MapboxManeuverView
import com.mapbox.navigation.ui.maps.camera.NavigationCamera
import com.mapbox.navigation.ui.maps.camera.data.MapboxNavigationViewportDataSource
import com.mapbox.navigation.ui.maps.camera.data.debugger.MapboxNavigationViewportDataSourceDebugger
import com.mapbox.navigation.ui.maps.camera.lifecycle.NavigationBasicGesturesHandler
import com.mapbox.navigation.ui.maps.camera.state.NavigationCameraState
import com.mapbox.navigation.ui.maps.camera.transition.NavigationCameraTransitionOptions
import com.mapbox.navigation.ui.maps.location.NavigationLocationProvider
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowApi
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowView
import com.mapbox.navigation.ui.maps.route.arrow.model.RouteArrowOptions
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineApi
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineView
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineOptions
import com.mapbox.navigation.ui.maps.route.line.model.RouteLineColorResources
import com.mapbox.navigation.ui.maps.route.line.model.RouteLineResources
import com.mapbox.navigation.ui.maps.route.line.model.RouteLine
import com.mapbox.navigation.ui.maps.route.RouteLayerConstants
import com.mapbox.navigation.ui.tripprogress.api.MapboxTripProgressApi
import com.mapbox.navigation.ui.tripprogress.model.DistanceRemainingFormatter
import com.mapbox.navigation.ui.tripprogress.model.EstimatedTimeToArrivalFormatter
import com.mapbox.navigation.ui.tripprogress.model.PercentDistanceTraveledFormatter
import com.mapbox.navigation.ui.tripprogress.model.TimeRemainingFormatter
import com.mapbox.navigation.ui.tripprogress.model.TripProgressUpdateFormatter
import com.mapbox.navigation.ui.tripprogress.view.MapboxTripProgressView
import com.mapbox.navigation.ui.voice.api.MapboxSpeechApi
import com.mapbox.navigation.ui.voice.api.MapboxVoiceInstructionsPlayer
import com.mapbox.navigation.ui.voice.model.SpeechAnnouncement
import com.mapbox.navigation.ui.voice.model.SpeechError
import com.mapbox.navigation.ui.voice.model.SpeechValue
import com.mapbox.navigation.ui.voice.model.SpeechVolume
import com.mapbox.navigation.ui.shield.model.RouteShieldCallback
import com.mapbox.navigation.ui.speedlimit.api.MapboxSpeedLimitApi
import com.mapbox.navigation.ui.speedlimit.model.SpeedLimitFormatter
import com.mapbox.navigation.ui.speedlimit.view.MapboxSpeedLimitView
import com.mapbox.navigation.ui.status.model.Status
import com.mapbox.navigation.ui.status.model.StatusFactory
import com.mapbox.navigation.ui.status.view.MapboxStatusView
import java.util.Locale
import java.util.concurrent.TimeUnit
import com.facebook.react.uimanager.events.RCTEventEmitter

@OptIn(ExperimentalMapboxNavigationAPI::class)
class MapboxNavigationFreeDriveView(private val context: ThemedReactContext, private val accessToken: String?) : FrameLayout(context.baseContext) {
    private companion object {
        private const val BUTTON_ANIMATION_DURATION = 1500L
    }

    private var followZoomLevel: Double = 16.0
    private var showSpeedLimit: Boolean = true
    private var speedLimitAnchor: Array<Double>? = null
    private var maneuverAnchor: Array<Double>? = null
    private var maneuverRadius: Int = 26
    private var maneuverBackgroundColor: String = "#303030"
    private var userPuckImage: String? = null
    private var userPuckScale: Double = 1.0
    private var destinationImage: String? = null
    private var originImage: String? = null
    private var mapPadding: Array<Double>? = null
    private var routeColor: String = "#56A8FB"
    private var routeCasingColor: String = "#2F7AC6"
    private var routeClosureColor: String = "#000000"
    private var alternateRouteColor: String = "#8694A5"
    private var alternateRouteCasingColor: String = "#727E8D"
    private var traversedRouteColor: String? = null
    private var traversedRouteCasingColor: String? = null
    private var trafficUnknownColor: String = "#56A8FB"
    private var trafficLowColor: String = "#56A8FB"
    private var trafficModerateColor: String = "#ff9500"
    private var trafficHeavyColor: String = "#ff4d4d"
    private var trafficSevereColor: String = "#8f2447"
    private var restrictedRoadColor: String = "#000000"
    private var routeArrowColor: String = "#FFFFFF"
    private var routeArrowCasingColor: String = "#2D3F53"
    private var waypointColor: String = "#2F7AC6"
    private var waypointRadius: Int = 8
    private var waypointOpacity: Int = 1
    private var waypointStrokeWidth: Int = 2
    private var waypointStrokeOpacity: Int = 1
    private var waypointStrokeColor: String = "#FFFFFF"
    private var logoVisible: Boolean = true
    private var logoPadding: Array<Double>? = null
    private var attributionVisible: Boolean = true
    private var attributionPadding: Array<Double>? = null
    private var mute: Boolean = false
    private var darkMode: Boolean = false
    private var debug: Boolean = false
    private var fontFamily: String? = null
    private var primaryColour: String = "#303030"
    private var secondaryColour: String = "#707070"
    private var primaryTextColour: String = "#FFFFFF"
    private var secondaryTextColour: String = "#9B9B9B"
    private var textSizeSmall: Double = 14.0
    private var textSizeMedium: Double = 16.0
    private var textSizeLarge: Double = 20.0
    private var textSizeXLarge: Double = 22.0

    private var isMapStyleLoaded: Boolean = false
    private var currentOrigin: Point? = null
    private var currentDestination: Point? = null
    private var currentWaypoints: Array<Point>? = null
    private var currentLegIndex: Int = -1
    private var currentActiveRoutes: List<NavigationRoute>? = null
    private var currentPreviewRoutes: List<NavigationRoute>? = null

    /**
     * Bindings to the example layout.
     */
    private var binding: NavigationViewBinding =
        NavigationViewBinding.inflate(LayoutInflater.from(context), this, true)

    /**
     * Mapbox Maps entry point obtained from the [MapView].
     * You need to get a new reference to this object whenever the [MapView] is recreated.
     */
    private lateinit var mapboxMap: MapboxMap

    /**
     * Mapbox Navigation entry point. There should only be one instance of this object for the app.
     * You can use [MapboxNavigationProvider] to help create and obtain that instance.
     */
    private lateinit var mapboxNavigation: MapboxNavigation

    /**
     * Used to execute camera transitions based on the data generated by the [viewportDataSource].
     * This includes transitions from route overview to route following and continuously updating the camera as the location changes.
     */
    private lateinit var navigationCamera: NavigationCamera

    /**
     * Produces the camera frames based on the location and routing data for the [navigationCamera] to execute.
     */
    private lateinit var viewportDataSource: MapboxNavigationViewportDataSource

    /**
     * Generates updates for the [MapboxManeuverView] to display the upcoming maneuver instructions
     * and remaining distance to the maneuver point.
     */
    private lateinit var maneuverApi: MapboxManeuverApi
    
    /**
     * Generates updates for the [routeLineView] with the geometries and properties of the routes that should be drawn on the map.
     */
    private lateinit var routeLineApi: MapboxRouteLineApi

    /**
     * Draws route lines on the map based on the data from the [routeLineApi]
     */
    private lateinit var routeLineView: MapboxRouteLineView

    /**
     * Generates updates for the [routeArrowView] with the geometries and properties of maneuver arrows that should be drawn on the map.
     */
    private lateinit var routeArrowApi: MapboxRouteArrowApi

    /**
     * Draws maneuver arrows on the map based on the data [routeArrowApi].
     */
    private lateinit var routeArrowView: MapboxRouteArrowView

    /**
     * Extracts message that should be communicated to the driver about the upcoming maneuver.
     * When possible, downloads a synthesized audio file that can be played back to the driver.
     */
    private lateinit var speechApi: MapboxSpeechApi

    /**
     * Plays the synthesized audio files with upcoming maneuver instructions
     * or uses an on-device Text-To-Speech engine to communicate the message to the driver.
     */
    private lateinit var voiceInstructionsPlayer: MapboxVoiceInstructionsPlayer
    
    /**
     * The data in the [MapboxSpeedLimitView] is formatted by different formatting implementations.
     * Below is the default formatter using default options but you can use your own formatting
     * classes.
     */
    private lateinit var speedLimitFormatter: SpeedLimitFormatter

    /**
     * API used for formatting speed limit related data.
     */
    private lateinit var speedLimitApi: MapboxSpeedLimitApi

    /*
     * Below are generated camera padding values to ensure that the route fits well on screen while
     * other elements are overlaid on top of the map (including instruction view, buttons, etc.)
     */
    private val pixelDensity = Resources.getSystem().displayMetrics.density
    private val routeClickPadding = 30 * pixelDensity
    private val overviewPadding: EdgeInsets by lazy {
        EdgeInsets(
            0.0,
            0.0,
            0.0,
            0.0
        )
    }
    private val landscapeOverviewPadding: EdgeInsets by lazy {
        EdgeInsets(
            0.0,
            0.0,
            0.0,
            0.0
        )
    }
    private val followingPadding: EdgeInsets by lazy {
        EdgeInsets(
            0.0,
            0.0,
            0.0,
            0.0
        )
    }
    private val landscapeFollowingPadding: EdgeInsets by lazy {
        EdgeInsets(
            0.0,
            0.0,
            0.0,
            0.0
        )
    }

    /**
     * [NavigationLocationProvider] is a utility class that helps to provide location updates generated by the Navigation SDK
     * to the Maps SDK in order to update the user location indicator on the map.
     */
    private val navigationLocationProvider = NavigationLocationProvider()
    
    /**
     * The [RouteShieldCallback] will be invoked with an appropriate result for Api call
     * [MapboxManeuverApi.getRoadShields]
     */
    private val roadShieldCallback = RouteShieldCallback { shields ->
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).renderManeuverWith(shields)
    }

    /**
     * Based on whether the synthesized audio file is available, the callback plays the file
     * or uses the fall back which is played back using the on-device Text-To-Speech engine.
     */
    private val speechCallback = MapboxNavigationConsumer<Expected<SpeechError, SpeechValue>> { expected ->
        expected.fold(
            { error ->
                // play the instruction via fallback text-to-speech engine
                voiceInstructionsPlayer.play(
                    error.fallback,
                    voiceInstructionsPlayerCallback
                )
            },
            { value ->
                // play the sound file from the external generator
                voiceInstructionsPlayer.play(
                    value.announcement,
                    voiceInstructionsPlayerCallback
                )
            }
        )
    }

    /**
     * When a synthesized audio file was downloaded, this callback cleans up the disk after it was played.
     */
    private val voiceInstructionsPlayerCallback = MapboxNavigationConsumer<SpeechAnnouncement> { value ->
        // remove already consumed file to free-up space
        speechApi.clean(value)
    }
    
    /**
     * Observes when a new voice instruction should be played.
     */
    private val voiceInstructionsObserver = VoiceInstructionsObserver { voiceInstructions ->
        speechApi.generate(voiceInstructions, speechCallback)
    }

    /**
     * The SDK triggers [NavigationRouteAlternativesObserver] when available alternatives change.
     */
    private val alternativesObserver = object : NavigationRouteAlternativesObserver {
        override fun onRouteAlternatives(
            routeProgress: RouteProgress,
            alternatives: List<NavigationRoute>,
            routerOrigin: RouterOrigin
        ) {
            // Set the suggested alternatives
            val updatedRoutes = mutableListOf<NavigationRoute>()
            updatedRoutes.add(routeProgress.navigationRoute) // only primary route should persist
            updatedRoutes.addAll(alternatives) // all old alternatives should be replaced by the new ones
            mapboxNavigation.setNavigationRoutes(updatedRoutes)

            val status = StatusFactory.buildStatus(
                message = "Alternative available", 
                duration = 2000L
            )
            binding.statusView.render(status)
        }

        override fun onRouteAlternativesError(error: RouteAlternativesError) {
            // no impl
        }
    }

    /**
     * Gets notified with location updates.
     *
     * Exposes raw updates coming directly from the location services
     * and the updates enhanced by the Navigation SDK (cleaned up and matched to the road).
     */
    private val locationObserver = object : LocationObserver {
        var firstLocationUpdateReceived = false

        override fun onNewRawLocation(rawLocation: Location) {
            // not handled
        }

        override fun onNewLocationMatcherResult(locationMatcherResult: LocationMatcherResult) {
            val enhancedLocation = locationMatcherResult.enhancedLocation
            // update location puck's position on the map
            navigationLocationProvider.changePosition(
                location = enhancedLocation,
                keyPoints = locationMatcherResult.keyPoints
            )

            // update camera position to account for new location
            viewportDataSource.onLocationChanged(enhancedLocation)
            viewportDataSource.evaluate()

            // if this is the first location update the activity has received,
            // it's best to immediately move the camera to the current user location
            if (!firstLocationUpdateReceived) {
                firstLocationUpdateReceived = true

                navigationCamera.requestNavigationCameraToOverview(
                    stateTransitionOptions = NavigationCameraTransitionOptions.Builder()
                        .maxDuration(0) // instant transition
                        .build()
                )
            }

            val speedLimitValue = speedLimitApi.updateSpeedLimit(locationMatcherResult.speedLimit)
            binding.speedLimitView.render(speedLimitValue)

            // location event
            val event = Arguments.createMap()
            event.putDouble("longitude", enhancedLocation.longitude)
            event.putDouble("latitude", enhancedLocation.latitude)

            if (enhancedLocation.hasBearing()) {
                event.putFloat("bearing", enhancedLocation.getBearing())
            }

            if (enhancedLocation.hasSpeed()) {
                event.putFloat("speed", enhancedLocation.getSpeed())
            }

            context
                .getJSModule(RCTEventEmitter::class.java)
                .receiveEvent(id, "onLocationChange", event)
        }
    }
    
    /**
     * Gets notified with progress along the currently active route.
     */
    private val routeProgressObserver = RouteProgressObserver { routeProgress ->
        // update the camera position to account for the progressed fragment of the route
        viewportDataSource.onRouteProgressChanged(routeProgress)
        viewportDataSource.evaluate()

        routeLineApi.updateWithRouteProgress(routeProgress) { result ->
            mapboxMap.getStyle()?.apply {
                routeLineView.renderRouteLineUpdate(this, result)
            }
        }

        // RouteArrow: The next maneuver arrows are driven by route progress events.
        // Generate the next maneuver arrow update data and pass it to the view class
        // to visualize the updates on the map.
        val arrowUpdate = routeArrowApi.addUpcomingManeuverArrow(routeProgress)
        mapboxMap.getStyle()?.apply {
            // Render the result to update the map.
            routeArrowView.renderManeuverUpdate(this, arrowUpdate)
        }

        val maneuvers = maneuverApi.getManeuvers(routeProgress)
        maneuvers.fold(
            { error ->
                Toast.makeText(
                    context,
                    error.errorMessage,
                    Toast.LENGTH_SHORT
                ).show()
            },
            {
                maneuvers.onValue { maneuverList ->
                    maneuverApi.getRoadShields(maneuverList, roadShieldCallback)
                }
                binding.maneuverContainer.visibility = View.VISIBLE
                binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).renderManeuvers(maneuvers)
            }
        )

        // route progress change event
        val event = Arguments.createMap()
        event.putFloat("distanceTraveled", routeProgress.distanceTraveled)
        event.putFloat("distanceRemaining", routeProgress.distanceRemaining)
        event.putDouble("timeTraveled", 0)
        event.putDouble("timeRemaining", routeProgress.durationRemaining)
        event.putFloat("progress", routeProgress.fractionTraveled)

        context
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onRouteProgressChange", event)
    }

    /**
     * Gets notified whenever the tracked routes change.
     *
     * A change can mean:
     * - routes get changed with [MapboxNavigation.setRoutes]
     * - routes annotations get refreshed (for example, congestion annotation that indicate the live traffic along the route)
     * - driver got off route and a reroute was executed
     */
    private val routesObserver = RoutesObserver { routeUpdateResult ->
        val navigationRoutes = routeUpdateResult.navigationRoutes

        if (navigationRoutes.isNotEmpty()) {
            routeLineApi.setNavigationRoutes(
                navigationRoutes,
                // alternative metadata is available only in active guidance.
                mapboxNavigation.getAlternativeMetadataFor(navigationRoutes)
            ) { value ->
                mapboxMap.getStyle()?.apply {
                    routeLineView.renderRouteDrawData(this, value)
                }
            }

            // update the camera position to account for the new route
            viewportDataSource.onRouteChanged(routeUpdateResult.routes.first())
            viewportDataSource.evaluate()

            val status = StatusFactory.buildStatus(
                message = "Route updated",
                duration = 2000L
            )
            binding.statusView.render(status)
        } else {
            // remove route line from the map
            mapboxMap.getStyle()?.let { style ->
                routeLineApi.clearRouteLine { value ->
                    routeLineView.renderClearRouteLineValue(
                        style,
                        value
                    )
                }
            }

            // remove the route reference from camera position evaluations
            viewportDataSource.clearRouteData()
            viewportDataSource.evaluate()
            navigationCamera.requestNavigationCameraToOverview()
        }

        // route change event
        val event = Arguments.createMap()
        event.putDouble("distance", routeUpdateResult.routes.first().distance())
        event.putDouble("expectedTravelTime", routeUpdateResult.routes.first().duration())
        event.putDouble("typicalTravelTime", routeUpdateResult.routes.first().durationTypical())

        context
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onRouteChange", event)
    }

    private val onPositionChangedListener = OnIndicatorPositionChangedListener { point ->
        val result = routeLineApi.updateTraveledRouteLine(point)
        
        mapboxMap.getStyle()?.apply {
            // Render the result to update the map.
            routeLineView.renderRouteLineUpdate(this, result)
        }
    }

    /**
     * Click on any point of the alternative route on the map to make it primary.
     */
    private val mapClickListener = OnMapClickListener { point ->
        routeLineApi.findClosestRoute(
            point,
            mapboxMap,
            routeClickPadding
        ) {
            val routeFound = it.value?.navigationRoute
            // if we clicked on some route that is not primary,
            // we make this route primary and all the others - alternative
            if (routeFound != null && routeFound != routeLineApi.getPrimaryNavigationRoute()) {
                val reOrderedRoutes = routeLineApi.getNavigationRoutes()
                    .filter { navigationRoute -> navigationRoute != routeFound }
                    .toMutableList()
                    .also { list ->
                        list.add(0, routeFound)
                    }
                mapboxNavigation.setNavigationRoutes(reOrderedRoutes)
            }
        }

        false
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        onCreate()
    }

    override fun requestLayout() {
        super.requestLayout()
        post(measureAndLayout)
    }

    private val measureAndLayout = Runnable {
        measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        layout(left, top, right, bottom)
    }

    private fun sendErrorToReact(error: String?) {
        val event = Arguments.createMap()
        event.putString("error", error)
        context
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onError", event)
    }

    private fun getPadding(padding: Array<Double>?): EdgeInsets {
        val mainPadding = this.mapPadding
        var top = if (padding != null) {
            if (padding!!.size > 0) {
                padding!!.get(0) * pixelDensity
            } else if (mainPadding != null && mainPadding!!.size > 0) {
                mainPadding!!.get(0) * pixelDensity
            } else {
                0.0
            }
        } else if (mainPadding != null) {
            if (mainPadding!!.size > 0) {
                mainPadding!!.get(0) * pixelDensity
            } else {
                0.0
            }
        } else {
            0.0
        }
        var left = if (padding != null) {
            if (padding!!.size > 1) {
                padding!!.get(1) * pixelDensity
            } else if (mainPadding != null && mainPadding!!.size > 1) {
                mainPadding!!.get(1) * pixelDensity
            } else {
                0.0
            }
        } else if (mainPadding != null) {
            if (mainPadding!!.size > 1) {
                mainPadding!!.get(1) * pixelDensity
            } else {
                0.0
            }
        } else {
            0.0
        }
        var bottom = if (padding != null) {
            if (padding!!.size > 2) {
                padding!!.get(2) * pixelDensity
            } else if (mainPadding != null && mainPadding!!.size > 2) {
                mainPadding!!.get(2) * pixelDensity
            } else {
                0.0
            }
        } else if (mainPadding != null) {
            if (mainPadding!!.size > 2) {
                mainPadding!!.get(2) * pixelDensity
            } else {
                0.0
            }
        } else {
            0.0
        }
        var right = if (padding != null) {
            if (padding!!.size > 3) {
                padding!!.get(3) * pixelDensity
            } else if (mainPadding != null && mainPadding!!.size > 3) {
                mainPadding!!.get(3) * pixelDensity
            } else {
                0.0
            }
        } else if (mainPadding != null) {
            if (mainPadding!!.size > 3) {
                mainPadding!!.get(3) * pixelDensity
            } else {
                0.0
            }
        } else {
            0.0
        }

        return EdgeInsets(
            top,
            left,
            bottom,
            right
        )
    }
    
    private fun updateLogoPadding() {
        val padding = this.logoPadding

        if (padding != null) {
            binding.mapView.logo.updateSettings {
                marginLeft = if (padding!!.size > 0) (padding!!.get(0).toFloat() * pixelDensity) else 0.0f
                marginBottom = if (padding!!.size > 1) (padding!!.get(1).toFloat() * pixelDensity) else 0.0f
                position = Gravity.BOTTOM or Gravity.LEFT
            }
        } else {
            binding.mapView.logo.updateSettings {
                marginLeft = 0.0f
                marginBottom = 0.0f
                position = Gravity.BOTTOM or Gravity.LEFT
            }
        }
    }
    
    private fun updateAttributionPadding() {
        val padding = this.attributionPadding

        if (padding != null) {
            binding.mapView.attribution.updateSettings {
                marginBottom = if (padding!!.size > 1) (padding!!.get(1).toFloat() * pixelDensity) else 0.0f
                marginRight = if (padding!!.size > 0) (padding!!.get(0).toFloat() * pixelDensity) else 0.0f
                position = Gravity.BOTTOM or Gravity.RIGHT
            }
        } else {
            binding.mapView.attribution.updateSettings {
                marginBottom = 0.0f
                marginRight = 0.0f
                position = Gravity.BOTTOM or Gravity.RIGHT
            }
        }
    }

    private fun toggleDarkMode(isDarkMode: Boolean) {
        if (isMapStyleLoaded && isDarkMode != this.darkMode) {
            binding.mapView.getMapboxMap().loadStyleUri(
                if (isDarkMode) Style.DARK else Style.LIGHT
            ) {
            }
        }

        this.darkMode = isDarkMode
    }

    private fun toggleMute(mute: Boolean) {
        this.mute = mute

        if (::voiceInstructionsPlayer.isInitialized) {
            if (mute) {
                voiceInstructionsPlayer.volume(SpeechVolume(0f))

                val status = StatusFactory.buildStatus(
                    message = "Voice OFF", 
                    duration = 2000L,
                    icon = R.drawable.mapbox_ic_sound_off
                )
                binding.statusView.render(status)
            } else {
                voiceInstructionsPlayer.volume(SpeechVolume(1f))

                val status = StatusFactory.buildStatus(
                    message = "Voice ON", 
                    duration = 2000L,
                    icon = R.drawable.mapbox_ic_sound_on
                )
                binding.statusView.render(status)
            }
        }
    }

    private fun toggleSpeedLimit(show: Boolean) {
        this.showSpeedLimit = show

        if (show) {
            binding.speedLimitView.visibility = View.VISIBLE
        } else {
            binding.speedLimitView.visibility = View.GONE
        }
    }

    private fun updateSpeedLimitAnchor(anchor: Array<Double>?) {
        this.speedLimitAnchor = anchor

        if (anchor != null) {
            (binding.speedLimitView.layoutParams as ConstraintLayout.LayoutParams).apply {
                marginStart = if (anchor!!.size > 0) (anchor!!.get(0) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                topMargin = if (anchor!!.size > 1) (anchor!!.get(1) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                marginEnd = if (anchor!!.size > 2) (anchor!!.get(2) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                bottomMargin = if (anchor!!.size > 3) (anchor!!.get(3) * pixelDensity).toInt() else 0
            }
        } else {
            (binding.speedLimitView.layoutParams as ConstraintLayout.LayoutParams).apply {
                marginStart = (20 * pixelDensity).toInt()
                topMargin = (20* pixelDensity).toInt()
                marginStart = (20 * pixelDensity).toInt()
                bottomMargin = 0
            }
        }
    }


    private fun updateManeuverAnchor(anchor: Array<Double>?) {
        this.maneuverAnchor = anchor

        if (anchor != null) {
            (binding.maneuverContainer.layoutParams as ConstraintLayout.LayoutParams).apply {
                marginStart = if (anchor!!.size > 0) (anchor!!.get(0) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                topMargin = if (anchor!!.size > 1) (anchor!!.get(1) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                marginEnd = if (anchor!!.size > 2) (anchor!!.get(2) * pixelDensity).toInt() else (20 * pixelDensity).toInt()
                bottomMargin = if (anchor!!.size > 3) (anchor!!.get(3) * pixelDensity).toInt() else 0
            }
        } else {
            (binding.maneuverContainer.layoutParams as ConstraintLayout.LayoutParams).apply {
                marginStart = (20 * pixelDensity).toInt()
                topMargin = (20* pixelDensity).toInt()
                marginStart = (20 * pixelDensity).toInt()
                bottomMargin = 0
            }
        }
    }

    private fun updateManeuverRadius(radius: Int) {
        binding.maneuverContainer.setRadius(radius.toFloat())
    }

    private fun updateManeuverBackgroundColor(color: String) {
        binding.maneuverContainer.setCardBackgroundColor(Color.parseColor(color))
    }

    @OptIn(ExperimentalPreviewMapboxNavigationAPI::class)
    private fun addDebug() {
        // debugging
        val debugger = MapboxNavigationViewportDataSourceDebugger(
            context,
            binding.mapView,
            layerAbove = "road-label"
        ).apply {
            enabled = true
        }
        viewportDataSource.debugger = debugger
        navigationCamera.debugger = debugger
    }

    @SuppressLint("MissingPermission")
    fun onCreate() {
        if (accessToken == null) {
            sendErrorToReact("Mapbox access token is not set")
            return
        }

        mapboxMap = binding.mapView.getMapboxMap()

        updateLogoPadding()
        updateAttributionPadding()

        // initialize the location puck
        binding.mapView.location.apply {
            val puckImage = userPuckImage

            if (puckImage != null) {
                val contentUri = Uri.parse(puckImage!!)

                locationPuck = LocationPuck2D(
                    bearingImage = ResourceDrawableIdHelper.getInstance().getResourceDrawable(context, contentUri.getPath())
                )
            } else {
                locationPuck = LocationPuck2D(
                    bearingImage = ContextCompat.getDrawable(
                        context,
                        R.drawable.mapbox_navigation_puck_icon
                    )
                )
            }
            
            setLocationProvider(navigationLocationProvider)

            enabled = true
        }

        binding.mapView.location.addOnIndicatorPositionChangedListener(onPositionChangedListener)

        binding.mapView.compass.enabled = false
        binding.mapView.scalebar.enabled = false
        binding.mapView.gestures.pitchEnabled = false
        binding.mapView.gestures.rotateEnabled = false

        // initialize Mapbox Navigation
        mapboxNavigation = if (MapboxNavigationProvider.isCreated()) {
            MapboxNavigationProvider.retrieve()
        } else {
            MapboxNavigationProvider.create(
                NavigationOptions.Builder(context)
                    .accessToken(accessToken)
                    .routeAlternativesOptions(
                        RouteAlternativesOptions.Builder()
                            .intervalMillis(TimeUnit.MINUTES.toMillis(3))
                            .build()
                    )
                    .build()
            )
        }

        // initialize Navigation Camera
        viewportDataSource = MapboxNavigationViewportDataSource(mapboxMap)
        
        navigationCamera = NavigationCamera(
            mapboxMap,
            binding.mapView.camera,
            viewportDataSource
        )
        
        viewportDataSource.followingPadding = getPadding(null)
        //viewportDataSource.options.followingFrameOptions.centerUpdatesAllowed = true
        //viewportDataSource.options.followingFrameOptions.zoomUpdatesAllowed = true
        //viewportDataSource.options.followingFrameOptions.bearingUpdatesAllowed = true
        //viewportDataSource.options.followingFrameOptions.paddingUpdatesAllowed = false
        //viewportDataSource.options.followingFrameOptions.minZoom = followZoomLevel
        //viewportDataSource.options.followingFrameOptions.maxZoom = followZoomLevel
        viewportDataSource.overviewPadding = getPadding(null)
        //viewportDataSource.options.overviewFrameOptions.paddingUpdatesAllowed = false

        // set the animations lifecycle listener to ensure the NavigationCamera stops
        // automatically following the user location when the map is interacted with
        binding.mapView.camera.addCameraAnimationsLifecycleListener(
            NavigationBasicGesturesHandler(navigationCamera)
        )
        
        navigationCamera.registerNavigationCameraStateChangeObserver { navigationCameraState ->
            var stateStr = "idle"

            if (navigationCameraState != null) {
                if (navigationCameraState == NavigationCameraState.TRANSITION_TO_FOLLOWING) {
                    stateStr = "transitionToFollowing"
                } else if (navigationCameraState == NavigationCameraState.FOLLOWING) {
                    stateStr = "following"
                } else if (navigationCameraState == NavigationCameraState.TRANSITION_TO_OVERVIEW) {
                    stateStr = "transitionToOverview"
                } else if (navigationCameraState == NavigationCameraState.OVERVIEW) {
                    stateStr = "overview"
                }
            }

            val event = Arguments.createMap()
            event.putString("state", stateStr)
            context
                .getJSModule(RCTEventEmitter::class.java)
                .receiveEvent(id, "onTrackingStateChange", event)
        }
        
        // add debug
        if (this.debug) {
            addDebug()
        }

        // load map style
        mapboxMap.loadStyleUri(
            if (this.darkMode) Style.DARK else Style.LIGHT
        ) {
            isMapStyleLoaded = true
        }

        // speed limit
        speedLimitFormatter = SpeedLimitFormatter(context)
        speedLimitApi = MapboxSpeedLimitApi(speedLimitFormatter)

        if (this.showSpeedLimit) {
            binding.speedLimitView.visibility = View.VISIBLE
        } else {
            binding.speedLimitView.visibility = View.GONE
        }

        /**
         * The instructions are hardcoded in English in [route] property.
         * If you request routes via SDK (see [FetchARouteActivity]),
         * you can specify any language here (for example, `Locale.getDefault().getLanguageTag()`)
         * and the returned voice instructions will be in the corresponding language.
         */
        speechApi = MapboxSpeechApi(
            context,
            accessToken,
            Locale.getDefault().toLanguageTag()
        )
        /**
         * The instructions are hardcoded in English in [route] property.
         * If you request routes via SDK (see [FetchARouteActivity]),
         * you can specify any language here (for example, `Locale.getDefault().getLanguageTag()`)
         * and the returned voice instructions will be in the corresponding language.
         */
        voiceInstructionsPlayer = MapboxVoiceInstructionsPlayer(
            context,
            accessToken,
            Locale.getDefault().toLanguageTag()
        )
        
        // make sure to use the same DistanceFormatterOptions across different features
        val distanceFormatterOptions = mapboxNavigation.navigationOptions.distanceFormatterOptions

        // initialize maneuver api that feeds the data to the top banner maneuver view
        maneuverApi = MapboxManeuverApi(
            MapboxDistanceFormatter(distanceFormatterOptions)
        )

        // initialize route line, the withRouteLineBelowLayerId is specified to place
        // the route line below road labels layer on the map
        // the value of this option will depend on the style that you are using
        // and under which layer the route line should be placed on the map layers stack
        val originIcon = originImage
        val destinationIcon = destinationImage
        val mapboxRouteLineOptions = MapboxRouteLineOptions.Builder(context)
            .withVanishingRouteLineEnabled(true)
            .withRouteLineResources(RouteLineResources.Builder()
                .routeLineColorResources(RouteLineColorResources.Builder()
                    .routeDefaultColor(Color.parseColor(routeColor))
                    .routeCasingColor(Color.parseColor(routeCasingColor))
                    .routeClosureColor(Color.parseColor(routeClosureColor))
                    .restrictedRoadColor(Color.parseColor(restrictedRoadColor))
                    .routeLineTraveledColor(if (traversedRouteColor.isNullOrBlank()) Color.TRANSPARENT else Color.parseColor(traversedRouteColor))
                    .routeLineTraveledCasingColor(if (traversedRouteCasingColor.isNullOrBlank()) Color.TRANSPARENT else Color.parseColor(traversedRouteCasingColor))
                    .routeUnknownCongestionColor(Color.parseColor(trafficUnknownColor))
                    .routeLowCongestionColor(Color.parseColor(trafficLowColor))
                    .routeModerateCongestionColor(Color.parseColor(trafficModerateColor))
                    .routeHeavyCongestionColor(Color.parseColor(trafficHeavyColor))
                    .routeSevereCongestionColor(Color.parseColor(trafficSevereColor))
                    .alternativeRouteDefaultColor(Color.parseColor(alternateRouteColor))
                    .alternativeRouteCasingColor(Color.parseColor(alternateRouteCasingColor))
                    .alternativeRouteClosureColor(Color.parseColor(routeClosureColor))
                    .alternativeRouteRestrictedRoadColor(Color.parseColor(restrictedRoadColor))
                    .alternativeRouteUnknownCongestionColor(Color.parseColor(alternateRouteColor))
                    .alternativeRouteLowCongestionColor(Color.parseColor(alternateRouteColor))
                    .alternativeRouteModerateCongestionColor(Color.parseColor(trafficModerateColor))
                    .alternativeRouteHeavyCongestionColor(Color.parseColor(trafficHeavyColor))
                    .alternativeRouteSevereCongestionColor(Color.parseColor(trafficSevereColor))
                    .inActiveRouteLegsColor(if (traversedRouteColor.isNullOrBlank()) Color.TRANSPARENT else Color.parseColor(traversedRouteColor))
                    .build()
                )
                .originWaypointIcon(if (originIcon != null) {
                    val contentUri = Uri.parse(originIcon!!)
    
                    ResourceDrawableIdHelper.getInstance().getResourceDrawableId(context, contentUri.getPath())
                } else {
                    R.drawable.mapbox_ic_route_origin
                })
                .destinationWaypointIcon(if (destinationIcon != null) {
                    val contentUri = Uri.parse(destinationIcon!!)
    
                    ResourceDrawableIdHelper.getInstance().getResourceDrawableId(context, contentUri.getPath())
                } else {
                    R.drawable.mapbox_ic_route_destination
                })
                .build()
            )
            .withRouteLineBelowLayerId("road-label")
            .displayRestrictedRoadSections(true)
            .build()

        routeLineApi = MapboxRouteLineApi(mapboxRouteLineOptions)
        routeLineView = MapboxRouteLineView(mapboxRouteLineOptions)

        routeArrowApi = MapboxRouteArrowApi()
        routeArrowView = MapboxRouteArrowView(RouteArrowOptions.Builder(context)
            .withAboveLayerId(RouteLayerConstants.TOP_LEVEL_ROUTE_LINE_LAYER_ID)
            .withArrowColor(Color.parseColor(routeArrowColor))
            .withArrowCasingColor(Color.parseColor(routeArrowCasingColor))
            .build())

        // register event listeners
        mapboxNavigation.registerLocationObserver(locationObserver)

        // start the trip session to being receiving location updates in free drive
        // and later when a route is set also receiving route progress updates
        mapboxNavigation.startTripSession()

        binding.mapView.gestures.addOnMapClickListener(mapClickListener)

        //binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateUpcomingManeuversVisibility(View.GONE)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updatePrimaryManeuverTextAppearance(R.style.PrimaryManeuverTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateSecondaryManeuverTextAppearance(R.style.SecondaryManeuverTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateSubManeuverTextAppearance(R.style.SubManeuverTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateStepDistanceTextAppearance(R.style.StepDistanceTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateUpcomingPrimaryManeuverTextAppearance(R.style.UpcomingPrimaryManeuverTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateUpcomingSecondaryManeuverTextAppearance(R.style.UpcomingSecondaryManeuverTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).updateUpcomingManeuverStepDistanceTextAppearance(R.style.UpcomingManeuverStepDistanceTextAppearance)
        binding.maneuverContainer.findViewById<MapboxManeuverView>(R.id.maneuverView).addOnLayoutChangeListener { view, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom ->
            var hasChanged = false

            if (view.height != oldBottom - oldTop) {
                hasChanged = true
            }
            if (view.width != oldRight - oldLeft) {
                hasChanged = true
            }

            if (hasChanged) {
                val event = Arguments.createMap()
                event.putInt("width", (view.width / pixelDensity).toInt())
                event.putInt("height", (view.height / pixelDensity).toInt())
                context
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onManeuverSizeChange", event)
            }
        }
    }

    private fun fetchRoutes(routeWaypoints: List<Point>, routeWaypointNames: List<String>, onSuccess: (routes: List<NavigationRoute>) -> Unit) {
        val originLocation = navigationLocationProvider.lastLocation
        val originPoint = originLocation?.let {
            Point.fromLngLat(it.longitude, it.latitude)
        } ?: return
        var bearings = mutableListOf<Bearing?>()
        var layers = mutableListOf<Int?>()

        bearings.add(Bearing.builder()
            .angle(originLocation.bearing.toDouble())
            .degrees(45.0)
            .build())
        layers.add(mapboxNavigation.getZLevel())

        for (ii in 1 until routeWaypoints.size) {
            bearings.add(null)
            layers.add(null)
        }

        mapboxNavigation.requestRoutes(
            RouteOptions.builder()
                .applyDefaultNavigationOptions()
                .applyLanguageAndVoiceUnitOptions(context)
                .coordinatesList(routeWaypoints)
                .bearingsList(bearings.toList())
                .waypointNamesList(routeWaypointNames)
                .layersList(layers.toList())
                .alternatives(true)
                .build(),
            object : NavigationRouterCallback {
                override fun onRoutesReady(
                    routes: List<NavigationRoute>,
                    routerOrigin: RouterOrigin
                ) {
                    if (routes.isEmpty()) {
                        sendErrorToReact("No route found")
                        return;
                    }
                    
                    onSuccess.invoke(routes)
                }

                override fun onFailure(
                    reasons: List<RouterFailure>,
                    routeOptions: RouteOptions
                ) {
                    sendErrorToReact("Error finding route $reasons")
                }

                override fun onCanceled(routeOptions: RouteOptions, routerOrigin: RouterOrigin) {
                    // no impl
                }
            }
        )
    }

    private fun previewRoutes(routes: List<NavigationRoute>) {
        pauseActiveGuidance()

        this.currentPreviewRoutes = routes

        // Mapbox navigation doesn't have a special state for route preview.
        // Preview state is managed by an application.
        // Display the routes you received on the map.
        routeLineApi.setNavigationRoutes(routes) { value ->
            mapboxMap.getStyle()?.apply {
                routeLineView.renderRouteDrawData(this, value)
                // update the camera position to account for the new route
                viewportDataSource.onRouteChanged(routes.first())
                viewportDataSource.evaluate()
                navigationCamera.requestNavigationCameraToOverview()
            }
        }
    }

    private fun startActiveGuidance(updateCamera: Boolean) {
        this.currentPreviewRoutes = null
        val routes = this.currentActiveRoutes

        if (routes != null) {
            // Set routes to switch navigator from free drive to active guidance state.
            // In active guidance navigator emits your route progress, voice and banner instructions, etc.
            mapboxNavigation.setNavigationRoutes(routes)
            mapboxNavigation.registerRoutesObserver(routesObserver)
            mapboxNavigation.registerRouteProgressObserver(routeProgressObserver)
            mapboxNavigation.registerVoiceInstructionsObserver(voiceInstructionsObserver)
            mapboxNavigation.registerRouteAlternativesObserver(alternativesObserver)

            if (updateCamera) {
                navigationCamera.requestNavigationCameraToFollowing()
            }
        }
    }

    private fun pauseActiveGuidance() {
        clearActiveGuidance()
        clearMap()

        navigationCamera.requestNavigationCameraToOverview()
    }

    private fun clearRouteAndStopActiveGuidance() {
        // clear
        this.currentActiveRoutes = null
        this.currentPreviewRoutes = null

        clearActiveGuidance()
        clearMap()

        navigationCamera.requestNavigationCameraToOverview()
    }

    private fun clearActiveGuidance() {
        mapboxNavigation.setNavigationRoutes(emptyList())
        mapboxNavigation.unregisterRoutesObserver(routesObserver)
        mapboxNavigation.unregisterRouteProgressObserver(routeProgressObserver)
        mapboxNavigation.unregisterVoiceInstructionsObserver(voiceInstructionsObserver)
        mapboxNavigation.unregisterRouteAlternativesObserver(alternativesObserver)
        viewportDataSource.clearRouteData()
        viewportDataSource.evaluate()
        binding.maneuverContainer.visibility = View.GONE
    }

    private fun clearMap() {
        mapboxMap.getStyle()?.let { style ->
            routeLineApi.clearRouteLine { value ->
                routeLineView.renderClearRouteLineValue(
                    style,
                    value
                )
            }
        }

        val arrowUpdate = routeArrowApi.clearArrows()
        mapboxMap.getStyle()?.apply {
            // Render the result to update the map.
            routeArrowView.render(this, arrowUpdate)
        }
    }

    private fun onDestroy() {
        try {
            routeLineApi.cancel()
            routeLineView.cancel()
            maneuverApi.cancel()
            speechApi.cancel()
            voiceInstructionsPlayer.shutdown()
            binding.mapView.location.removeOnIndicatorPositionChangedListener(onPositionChangedListener)
            MapboxNavigationProvider.destroy()
        } catch (ex: Exception) {
            sendErrorToReact(ex.toString())
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()

        try {
            mapboxNavigation.unregisterLocationObserver(locationObserver)
            mapboxNavigation.unregisterRoutesObserver(routesObserver)
            mapboxNavigation.unregisterRouteProgressObserver(routeProgressObserver)
            mapboxNavigation.unregisterVoiceInstructionsObserver(voiceInstructionsObserver)
            mapboxNavigation.unregisterRouteAlternativesObserver(alternativesObserver)
            binding.mapView.location.removeOnIndicatorPositionChangedListener(onPositionChangedListener)
        } catch (ex: Exception) {
            sendErrorToReact(ex.toString())
        }
    }

    fun onDropViewInstance() {
        this.onDestroy()
    }

    fun showRoute(origin: ReadableArray?, destination: ReadableArray?, waypoints: ReadableArray?, styles: ReadableArray?, legIndex: Int?, cameraType: String?, padding: ReadableArray?)  {
        try {
            var routeWaypoints = mutableListOf<Point>()
            var routeWaypointNames = mutableListOf<String>()

            if (origin != null) {
                currentOrigin = Point.fromLngLat(origin.getDouble(0), origin.getDouble(1))
                routeWaypoints.add(Point.fromLngLat(origin.getDouble(0), origin.getDouble(1)))
            }

            if (waypoints != null) {
                var newCurrentWaypoints = mutableListOf<Point>()

                for (ii in 0 until waypoints.size()) {
                    val waypoint = waypoints.getArray(ii)

                    if (waypoint != null) {
                        newCurrentWaypoints.add(Point.fromLngLat(waypoint.getDouble(0), waypoint.getDouble(1)))
                        routeWaypoints.add(Point.fromLngLat(waypoint.getDouble(0), waypoint.getDouble(1)))
                    }
                }

                currentWaypoints = newCurrentWaypoints.toTypedArray()
            }

            if (destination != null) {
                currentDestination = Point.fromLngLat(destination.getDouble(0), destination.getDouble(1))
                routeWaypoints.add(Point.fromLngLat(destination.getDouble(0), destination.getDouble(1)))
            }

            if (styles != null) {
                for (ii in 0 until styles.size()) {
                    val style = styles.getMap(ii)

                    if (style != null) {
                        if (style.hasKey("name")) {
                            routeWaypointNames.add(style.getString("name")!!)
                        }
                    }
                }
            }

            currentLegIndex = if (legIndex != null) legIndex!! else -1

            fetchRoutes(routeWaypoints.toList(), routeWaypointNames.toList()) { routes -> 
                moveToOverview(padding)
                previewRoutes(routes)
            }
        } catch (ex: Exception) {
            sendErrorToReact(ex.toString())
        }
    }

    fun clearRoute() {
        clearRouteAndStopActiveGuidance()
    }

    fun startNavigation(origin: ReadableArray?, destination: ReadableArray?, waypoints: ReadableArray?, styles: ReadableArray?, legIndex: Int?, cameraType: String?, padding: ReadableArray?) {
        if (this.currentActiveRoutes != null) {
            startActiveGuidance(false)

            if (cameraType != null && cameraType!! == "overview") {
                moveToOverview(padding)
            } else {
                follow(padding)
            }
        } else {
            try {
                var routeWaypoints = mutableListOf<Point>()
                var routeWaypointNames = mutableListOf<String>()
    
                if (origin != null) {
                    currentOrigin = Point.fromLngLat(origin.getDouble(0), origin.getDouble(1))
                    routeWaypoints.add(Point.fromLngLat(origin.getDouble(0), origin.getDouble(1)))
                }
    
                if (waypoints != null) {
                    var newCurrentWaypoints = mutableListOf<Point>()
    
                    for (ii in 0 until waypoints.size()) {
                        val waypoint = waypoints.getArray(ii)
    
                        if (waypoint != null) {
                            newCurrentWaypoints.add(Point.fromLngLat(waypoint.getDouble(0), waypoint.getDouble(1)))
                            routeWaypoints.add(Point.fromLngLat(waypoint.getDouble(0), waypoint.getDouble(1)))
                        }
                    }
    
                    currentWaypoints = newCurrentWaypoints.toTypedArray()
                }
    
                if (destination != null) {
                    currentDestination = Point.fromLngLat(destination.getDouble(0), destination.getDouble(1))
                    routeWaypoints.add(Point.fromLngLat(destination.getDouble(0), destination.getDouble(1)))
                }
    
                if (styles != null) {
                    for (ii in 0 until styles.size()) {
                        val style = styles.getMap(ii)
    
                        if (style != null) {
                            if (style.hasKey("name")) {
                                routeWaypointNames.add(style.getString("name")!!)
                            }
                        }
                    }
                }
    
                currentLegIndex = if (legIndex != null) legIndex!! else -1
    
                fetchRoutes(routeWaypoints.toList(), routeWaypointNames.toList()) { routes -> 
                    this.currentActiveRoutes = routes

                    startActiveGuidance(false)
                    follow(padding)
                }
            } catch (ex: Exception) {
                sendErrorToReact(ex.toString())
            }
        }
    }
    
    fun pauseNavigation() {
        pauseActiveGuidance()
    }

    fun stopNavigation() {
        clearRouteAndStopActiveGuidance()
    }
    
    fun follow(padding: ReadableArray?) {
        var newPadding = mutableListOf<Double>()

        if (padding != null) {
            for (ii in 0 until padding!!.size()) {
                newPadding.add(padding!!.getDouble(ii))
            }
        }

        viewportDataSource.followingPadding = getPadding(newPadding.toTypedArray())

        navigationCamera.requestNavigationCameraToFollowing()
    }
    
    fun moveToOverview(padding: ReadableArray?) {
        var newPadding = mutableListOf<Double>()

        if (padding != null) {
            for (ii in 0 until padding!!.size()) {
                newPadding.add(padding!!.getDouble(ii))
            }
        }

        viewportDataSource.overviewPadding = getPadding(newPadding.toTypedArray())

        navigationCamera.requestNavigationCameraToOverview()
    }
    
    fun fitCamera(padding: ReadableArray?) {
        var newPadding = mutableListOf<Double>()

        if (padding != null) {
            for (ii in 0 until padding!!.size()) {
                newPadding.add(padding!!.getDouble(ii))
            }
        }

        viewportDataSource.overviewPadding = getPadding(newPadding.toTypedArray())

        navigationCamera.requestNavigationCameraToOverview()
    }
    
    fun setShowSpeedLimit(showSpeedLimit: Boolean) {
        toggleSpeedLimit(showSpeedLimit)
    }

    fun setSpeedLimitAnchor(speedLimitAnchor: ReadableArray?) {
        if (speedLimitAnchor != null) {
            var newAnchor = mutableListOf<Double>()

            for (ii in 0 until speedLimitAnchor.size()) {
                newAnchor.add(speedLimitAnchor.getDouble(ii))
            }

            updateSpeedLimitAnchor(newAnchor.toTypedArray())
        } else {
            updateSpeedLimitAnchor(null)
        }
    }
    
    fun setManeuverAnchor(maneuverAnchor: ReadableArray?) {
        if (maneuverAnchor != null) {
            var newAnchor = mutableListOf<Double>()

            for (ii in 0 until maneuverAnchor.size()) {
                newAnchor.add(maneuverAnchor.getDouble(ii))
            }

            updateManeuverAnchor(newAnchor.toTypedArray())
        } else {
            updateManeuverAnchor(null)
        }
    }

    fun setManeuverRadius(maneuverRadius: Int) {
        updateManeuverRadius(maneuverRadius)
    }

    fun setManeuverBackgroundColor(maneuverBackgroundColor: String?) {
        if (maneuverBackgroundColor != null) {
            updateManeuverBackgroundColor(maneuverBackgroundColor)
        }
    }
    
    fun setFollowZoomLevel(followZoomLevel: Double) {
        this.followZoomLevel = followZoomLevel
    }
    
    fun setUserPuckImage(userPuckImage: String?) {
        this.userPuckImage = userPuckImage
    }
    
    fun setUserPuckScale(userPuckScale: Double) {
        this.userPuckScale = userPuckScale
    }
    
    fun setOriginImage(originImage: String?) {
        this.originImage = originImage
    }
    
    fun setDestinationImage(destinationImage: String?) {
        this.destinationImage = destinationImage
    }
    
    fun setMapPadding(mapPadding: ReadableArray?) {
        if (mapPadding != null) {
            var newPadding = mutableListOf<Double>()

            for (ii in 0 until mapPadding!!.size()) {
                newPadding.add(mapPadding!!.getDouble(ii))
            }

            this.mapPadding = newPadding.toTypedArray()
        } else {
            this.mapPadding = null
        }
    }
    
    fun setLogoVisible(logoVisible: Boolean) {
        this.logoVisible = logoVisible

        binding.mapView.logo.updateSettings {
            enabled = logoVisible
        }
    }
    
    fun setLogoPadding(logoPadding: ReadableArray?) {
        if (logoPadding != null) {
            var newPadding = mutableListOf<Double>()

            for (ii in 0 until logoPadding!!.size()) {
                newPadding.add(logoPadding!!.getDouble(ii))
            }

            this.logoPadding = newPadding.toTypedArray()
        } else {
            this.logoPadding = null
        }

        updateLogoPadding()
    }
    
    fun setAttributionVisible(attributionVisible: Boolean) {
        this.attributionVisible = attributionVisible

        binding.mapView.attribution.updateSettings {
            enabled = attributionVisible
        }
    }
    
    fun setAttributionPadding(attributionPadding: ReadableArray?) {
        if (attributionPadding != null) {
            var newPadding = mutableListOf<Double>()

            for (ii in 0 until attributionPadding!!.size()) {
                newPadding.add(attributionPadding!!.getDouble(ii))
            }

            this.attributionPadding = newPadding.toTypedArray()
        } else {
            this.attributionPadding = null
        }

        updateAttributionPadding()
    }
    
    fun setRouteColor(routeColor: String) {
        this.routeColor = routeColor
    }
    
    fun setRouteCasingColor(routeCasingColor: String) {
        this.routeCasingColor = routeCasingColor
    }
    
    fun setRouteClosureColor(routeClosureColor: String) {
        this.routeClosureColor = routeClosureColor
    }
    
    fun setAlternateRouteColor(alternateRouteColor: String) {
        this.alternateRouteColor = alternateRouteColor
    }
    
    fun setAlternateRouteCasingColor(alternateRouteCasingColor: String) {
        this.alternateRouteCasingColor = alternateRouteCasingColor
    }
    
    fun setTraversedRouteColor(traversedRouteColor: String?) {
        this.traversedRouteColor = traversedRouteColor
    }
    
    fun setTraversedRouteCasingColor(traversedRouteCasingColor: String?) {
        this.traversedRouteCasingColor = traversedRouteCasingColor
    }
    
    fun setTrafficUnknownColor(trafficUnknownColor: String) {
        this.trafficUnknownColor = trafficUnknownColor
    }
    
    fun setTrafficLowColor(trafficLowColor: String) {
        this.trafficLowColor = trafficLowColor
    }
    
    fun setTrafficModerateColor(trafficModerateColor: String) {
        this.trafficModerateColor = trafficModerateColor
    }
    
    fun setTrafficHeavyColor(trafficHeavyColor: String) {
        this.trafficHeavyColor = trafficHeavyColor
    }
    
    fun setTrafficSevereColor(trafficSevereColor: String) {
        this.trafficSevereColor = trafficSevereColor
    }
    
    fun setRestrictedRoadColor(restrictedRoadColor: String) {
        this.restrictedRoadColor = restrictedRoadColor
    }
    
    fun setWaypointColor(waypointColor: String) {
        this.waypointColor = waypointColor
    }
    
    fun setWaypointRadius(waypointRadius: Int) {
        this.waypointRadius = waypointRadius
    }
    
    fun setWaypointOpacity(waypointOpacity: Int) {
        this.waypointOpacity = waypointOpacity
    }
    
    fun setWaypointStrokeWidth(waypointStrokeWidth: Int) {
        this.waypointStrokeWidth = waypointStrokeWidth
    }
    
    fun setWaypointStrokeOpacity(waypointStrokeOpacity: Int) {
        this.waypointStrokeOpacity = waypointStrokeOpacity
    }
    
    fun setWaypointStrokeColor(waypointStrokeColor: String) {
        this.waypointStrokeColor = waypointStrokeColor
    }

    fun setMute(mute: Boolean) {
        toggleMute(mute)
    }
    
    fun setDarkMode(darkMode: Boolean) {
        toggleDarkMode(darkMode)
    }
    
    fun setDebug(debug: Boolean) {
        this.debug = debug
    }

    fun setFontFamily(fontFamily: String?) {
        this.fontFamily = fontFamily
    }

    fun setPrimaryColour(primaryColour: String) {
        this.primaryColour = primaryColour
    }

    fun setSecondaryColour(secondaryColour: String) {
        this.secondaryColour = secondaryColour
    }

    fun setPrimaryTextColour(primaryTextColour: String) {
        this.primaryTextColour = primaryTextColour
    }

    fun setSecondaryTextColour(secondaryTextColour: String) {
        this.secondaryTextColour = secondaryTextColour
    }

    fun setTextSizeSmall(textSizeSmall: Double) {
        this.textSizeSmall = textSizeSmall
    }

    fun setTextSizeMedium(textSizeMedium: Double) {
        this.textSizeMedium = textSizeMedium
    }
    
    fun setTextSizeLarge(textSizeLarge: Double) {
        this.textSizeLarge = textSizeLarge
    }
    
    fun setTextSizeXLarge(textSizeXLarge: Double) {
        this.textSizeXLarge = textSizeXLarge
    }
}
