#
# Be sure to run `pod lib lint SwiftAdditions.podspec` to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftAdditions'
  s.module_name      = "Additions"
  s.version          = '1.1.1'
  s.summary          = 'A short description of Additions.'

  s.description      = 'A swift library for syntax sugar, dependency injection and a controlled startup process'

  s.homepage         = 'https://github.com/AdevintaSpain/SwiftAdditions'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Marton Kerekes' => 'kerekes.j.marton@gmail.com' }
  s.source           = { :git => 'git@github.com:AdevintaSpain/SwiftAdditions.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'SwiftAdditions/Classes/**/*'
end
