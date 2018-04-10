#
#  Be sure to run `pod spec lint Zanyer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "Zanyer"
  s.version      = "0.0.3"
  s.summary      = "A singleton of player"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = "A singleton of player,Including the remote control center."

  s.homepage     = "https://github.com/Yvent/Zanyer"
  s.license      = "MIT"
  s.author             = { "Yvent" => "Yvente@163.com" }


  s.source       = { :git => "https://github.com/Yvent/Zanyer.git", :tag => "0.0.3"}


  s.source_files  = "Zanyer/*"

  s.platform     = :ios, "9.0"

  s.ios.deployment_target = "9.0"

  #s.resources          = "Zanyer/Zanyer.bundle"

  
end
