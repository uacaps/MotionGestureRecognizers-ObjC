Pod::Spec.new do |s|
  s.name         = "MotionGestureRecognizers-ObjC"
  s.version      = "1.0.0"
  s.summary      = "This is a wrapper for Leap Motion that adds gesture recognizers as easy to use as they are in iOS"
  s.homepage     = "https://github.com/uacaps/MotionGestureRecognizers-ObjC"
  s.license      = { :type => 'UA', :file => 'LICENSE' }
  s.author       = { "uacaps" => "care@cs.ua.edu" }
  s.source       = { :git => "https://github.com/uacaps/MotionGestureRecognizers-ObjC.git", :tag => "1.0.0" }
  s.platform     = :osx
  s.source_files = 'Classes/*.{h,m}'
  s.requires_arc = true
end