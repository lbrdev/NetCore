Pod::Spec.new do |spec|
  spec.name = 'NetCore'
  spec.version = '1.0.1'
  spec.summary = 'Simple wrapper for networking wit Alamofire and Stubs'
  spec.description = 'Use this framework to increase speed of networking development.'
  spec.homepage = 'https://github.com/lbrdev/NetCore'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = 'Ihor Kandaurov'
  spec.platform = :ios, '13.0'
  spec.source = { :git => 'https://github.com/lbrdev/NetCore.git', :tag => spec.version }
  spec.source_files = 'Sources/**/*.{swift}'
  spec.ios.deployment_target = '13.0'
  spec.swift_version = '5'
  spec.dependency 'Alamofire'
  #spec.dependency 'OHHTTPStubs', '~> 9.1.0'
  spec.dependency 'OHHTTPStubs/Swift'
end