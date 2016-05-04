Pod::Spec.new do |s|
  s.name         = "NativeJSON"
  s.version      = "0.2.3"
  s.summary      = "Native JSON is a full featured cross platform JSON library written entirely in Swift"
  s.homepage     = "https://github.com/vdka/JSON"
  s.license      = { :type => "MIT" }
  s.author       = { "Ethan Jackwitz" => "ethanjackwitz@gmail.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/vdka/JSON.git", :tag => s.version.to_s }
  s.source_files = 'Sources/*'
end
