Pod::Spec.new do |s|
  s.name             = "APMultiMenu"
  s.version          = "0.6.3"
  s.summary          = "APMultiMenu is a viewcontroller container for left and right slideout menus"
  s.description      = <<-DESC
                       APMultiMenu is a ViewController Container that currently supports left and right slide out menus
                       DESC
  s.homepage         = "https://github.com/aadeshp/APMultiMenu"
  s.license          = 'MIT'
  s.author           = { "Aadesh Patel" => "aadeshp95@gmail.com" }
  s.source           = { :git => "https://github.com/aadeshp/APMultiMenu.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'APMultiMenu'
end
