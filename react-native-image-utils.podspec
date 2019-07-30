require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name     = "react-native-image-utils"
  s.version  = package['version']
  s.summary  = package['description']
  s.homepage = "https://github.com/yangga/react-native-image-utils"
  s.license  = package['license']
  s.author   = package['author']
  s.source   = { :git => "https://github.com/yangga/react-native-image-utils", :tag => "v#{s.version}" }

  s.platform = :ios, "8.0"

  #s.preserve_paths = 'README.md', 'LICENSE.md', 'package.json', 'index.js'
  s.source_files   = "ios/**/*.{h,m,mm}"

  s.dependency 'React'
end
