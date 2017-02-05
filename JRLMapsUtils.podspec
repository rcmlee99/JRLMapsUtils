#
# Be sure to run `pod lib lint JRLMapsUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JRLMapsUtils'
  s.version          = '0.1.0'
  s.summary          = 'This open-source utilities library contains classes that are useful for a wide range of map applications
'
  s.description      = 'ViewController classes for map applications'

  s.homepage         = 'https://github.com/rcmlee99/JRLMapsUtils'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'rcmlee99' => 'rcmlee99@gmail.com' }
  s.source           = { :git => 'https://github.com/rcmlee99/JRLMapsUtils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'JRLMapsUtils/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'JRLMapsUtils' => ['JRLMapsUtils/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'GooglePlaces'
  s.dependency 'GoogleMaps'
  s.dependency 'JRLUtils'
end
