#
# Be sure to run `pod lib lint AriesMobileAgent-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AriesMobileAgent-iOS'
  s.version          = '0.1.0'
  s.summary          = 'Aries mobileagent iOS (AMA-i).'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This contains the Aries mobileagent iOS (AMA-i), an open source mobile agent for achieving self sovereign identity (SSI), created as part NGI-Trust eSSIF Lab, with efforts from iGrant.io, unikk.me, MyData etc.
                       DESC

  s.homepage         = 'https://github.com/decentralised-dataexchange/aries-mobileagent-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rebin@igrant.io' => 'rebin@igrant.io' }
  s.source           = { :git => 'https://github.com/decentralised-dataexchange/aries-mobileagent-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AriesMobileAgent-iOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AriesMobileAgent-iOS' => ['AriesMobileAgent-iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
