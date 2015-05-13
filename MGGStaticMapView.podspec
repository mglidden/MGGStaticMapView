Pod::Spec.new do |s|
  s.name         = 'MGGStaticMapView'
  s.version      = '1.0.3'
  s.license      = 'Apache V2'
  s.summary      = 'Drop-in replacement for MKMapView that uses a snapshotter to reduce memory usage.'
  s.homepage     = 'https://github.com/mglidden/MGGStaticMapView'
  s.authors      = { 'Mason Glidden' => 'mason@masonglidden.com' }
  s.source       = { :git => 'https://github.com/mglidden/MGGStaticMapView.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.platform     = :ios
  s.ios.deployment_target = '7.0'

  s.public_header_files = 'MGGStaticMapView/Source/**/MGGStaticMapView.h'
  s.source_files = 'MGGStaticMapView/Source/**/*.{h,m}'
end
