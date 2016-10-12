
Pod::Spec.new do |s|

s.name         = "BaseRefreshControl"
s.version      = "0.0.4"
s.summary      = "Base kit to make custom UIRefresh."

s.homepage     = "https://github.com/asaday/BaseRefreshControl"
s.license     = { :type => "MIT" }
s.author       = { "asaday" => "" }

s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/asaday/BaseRefreshControl.git", :tag => s.version }
s.source_files  = "classes/**/*.{swift,h,m}"
s.requires_arc = true


s.xcconfig = {
    'SWIFT_VERSION' => '3.0'
  }

end
