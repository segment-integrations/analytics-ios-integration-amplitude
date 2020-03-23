Pod::Spec.new do |s|
  s.name             = "Segment-Amplitude"
  s.version          = "3.0.1"
  s.summary          = "Amplitude Integration for Segment's analytics-ios library."

  s.description      = <<-DESC
                       Analytics for iOS provides a single API that lets you
                       integrate with over 100s of tools.

                       This is the Amplitude integration for the iOS library.
                       DESC

  s.homepage         = "http://segment.com/"
  s.license          =  { :type => 'MIT' }
  s.author           = { "Segment" => "friends@segment.com" }
  s.source           = { :git => "https://github.com/segment-integrations/analytics-ios-integration-amplitude.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/segment'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'

  s.dependency 'Analytics', '~> 3.7.0'
  s.dependency 'Amplitude-iOS', '~> 4.8.0'
end
