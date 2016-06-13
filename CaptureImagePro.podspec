Pod::Spec.new do |s|
s.name         = 'CaptureImagePro'
s.version      = '1.0.0'
s.license      = 'MIT'
s.homepage     = 'https://github.com/slq0378'
s.authors      = {'MrSong' => 'slq0378@163.com'}
s.summary      = '通过AVFoundation自定义相机，可有效降低内存占用'

s.platform     =  :ios, '7.0'
s.source       =  {:git => 'https://github.com/slq0378/CaptureImagePro.git', :tag => s.version}
s.source_files = 'CaptureImagePro/SLQCameraViewController'
s.frameworks   =  'AVFoundation'
s.requires_arc = true

end