require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-mapbox-navigation'
  s.version      = package['version']
  s.summary      = 'React Native Component for Mapbox Navigation'
  s.homepage     = 'https://github.com/fleetbase/react-native-mapbox-navigation.git'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'Fleetbase Pte Ltd.' => 'hello@fleetbase.io' }
  s.platforms    = { :ios => '12.0' }
  s.source       = { :git => 'https://github.com/fleetbase/react-native-mapbox-navigation.git', :tag => 'v' + s.version.to_s }

  s.source_files = 'ios/**/*.{h,m,swift}'
  s.requires_arc = true

  s.dependency 'React-Core'
  s.dependency 'MapboxNavigation', '~> 2.14.0'
end