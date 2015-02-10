#
# Be sure to run `pod lib lint APMultiMenu.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "APMultiMenu"
  s.version          = "0.4.1"
  s.summary          = "APMultiMenu is a viewcontroller container for slideout menus"
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
