Pod::Spec.new do |s|

  s.name         = "JSON"
  s.version      = "0.16.3"
  s.summary      = "The fastest type-safe native Swift JSON parser available."

  s.description  = <<-DESC
  FastParse is a ground-up implementation of JSON serialisation and parsing that
  avoids casting to and from AnyObject. When transforming directly to models,
  FastParse is 5x faster than Foundation.JSONSerialization. It is NOT just Another
  Swift JSON Package.
                   DESC

  s.homepage     = "https://github.com/vdka/JSON"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = "Ethan Jackwitz"
  s.ios.deployment_target = "8.0" # Because we're using frameworks
  s.source       = { :git => "https://github.com/vdka/JSON.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*.swift"

end
