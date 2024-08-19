Pod::Spec.new do |s|
  s.name         = "RNHeartbeat"
  s.version      = "2.0.4"
  s.summary      = "A bridge for React Native and Heartbeat."
  s.description  = <<-DESC
                   This library is indented for Topaz customers integrating the Heartbeat with React Native app
                   DESC
  s.homepage     = "https://www.topaz.com.br/ofd/"
  s.license      = "MIT"
  s.author             = { "OFD Mobile" => "ofd-mobile@StefaniniLATAM.onmicrosoft.com" }
  s.platform     = :ios, "10.3"
  s.source       = { :git => "" }
  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true

  s.static_framework = true

  s.dependency "React"
  s.dependency "OFDCamera"
  s.dependency "Heartbeat"
end
