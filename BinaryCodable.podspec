Pod::Spec.new do |s|
  s.name = 'BinaryCodable'
  s.version = '0.3.1'
  s.license = 'Apache 2.0'
  s.summary = 'Codable-like interfaces for binary representations.'
  s.homepage = 'https://github.com/jverkoey/BinaryCodable'
  s.authors = { 'BinaryCodable authors' => 'jverkoey@gmail.com' }
  s.source = { :git => 'https://github.com/jverkoey/BinaryCodable.git', :tag => s.version }
  s.documentation_url = 'https://github.com/jverkoey/BinaryCodable/'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.swift_versions = ['5.2']

  s.source_files = ['Sources/**/*.swift']
end
