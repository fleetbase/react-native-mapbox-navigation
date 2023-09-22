require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
TargetsToChangeToDynamic = ['MapboxMobileEvents', 'Turf', 'MapboxMaps', 'MapboxCoreMaps', 'MapboxCommon', 'MapboxNavigation', 'MapboxCoreNavigation', 'MapboxSpeech', 'Solar-dev', 'MapboxNavigationNative', 'MapboxDirections', 'Polyline']
$RNMBNAV = Object.new

def $RNMBNAV.post_install(installer)
  installer.pod_targets.each do |pod|
    if TargetsToChangeToDynamic.include?(pod.name)
      if pod.send(:build_type) != Pod::BuildType.dynamic_framework
        pod.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
        puts "* [RNMapboxNav] Changed #{pod.name} to `#{pod.send(:build_type)}`"
        fail "* [RNMapboxNav] Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
      end
    end
  end
end

def $RNMBNAV.pre_install(installer)
  installer.aggregate_targets.each do |target|
    target.pod_targets.select { |p| TargetsToChangeToDynamic.include?(p.name) }.each do |mobile_events_target|
      mobile_events_target.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
      puts "* [RNMapboxNav] Changed #{mobile_events_target.name} to #{mobile_events_target.send(:build_type)}"
      fail "* [RNMapboxNav] Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
    end
  end
end

Pod::Spec.new do |s|
  s.name         = 'react-native-mapbox-navigation'
  s.version      = package['version']
  s.summary      = 'React Native Component for Mapbox Navigation'
  s.homepage     = 'https://github.com/fleetbase/react-native-mapbox-navigation.git'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'Fleetbase Pte Ltd.' => 'hello@fleetbase.io' }
  s.platforms    = { :ios => '13.0' }
  s.source       = { :git => 'https://github.com/fleetbase/react-native-mapbox-navigation.git', :tag => 'v' + s.version.to_s }

  s.source_files = 'ios/**/*.{h,m,swift}'
  s.requires_arc = true

  s.dependency 'React-Core'
  s.dependency 'MapboxNavigation', '~> 2.12.0'
end