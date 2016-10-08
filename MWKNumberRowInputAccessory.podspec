Pod::Spec.new do |s|
  s.name             = "MWKNumberRowInputAccessory"
  s.version          = "1.0.0"
  s.license          = "MIT"
  s.summary          = "iOS keyboard persistent number row input accessory view with a native look and feel."
  s.description      = <<-DESC
  iOS keyboard input accessory view that adds a persistent number row with native look and feel. Convenient entry of street addresses and more. 
  DESC
  s.homepage         = "https://github.com/mwkirk/MWKNumberRowInputAccessory"
  s.author           = "Mark Kirk"
  s.social_media_url = "https://twitter.com/postmodjackass"
  s.platform         = :ios, "8.0"
  s.source           = { :git => "https://github.com/mwkirk/MWKNumberRowInputAccessory.git", :tag => "#{s.version}" }
  s.source_files     = "Src/*.{h,m}"
  s.resources        = "Src/Assets/Artwork.xcassets", "Src/Assets/images/*.png"
  s.frameworks       = "Foundation"
  s.requires_arc     = true
end
