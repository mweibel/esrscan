# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

def shared_pods
	pod 'GPUImage', '0.1.7'
	pod 'Alamofire', '~> 3.0'

	# We need the fix introduced by https://github.com/gali8/Tesseract-OCR-iOS/commit/c7fcaaa0f03773cb8f86dedef72abc106c0c61df
	# until TesseractOCRiOS does update its version.
	# Till then, we stick with this explicit revision rather than an official version tag.
	pod 'TesseractOCRiOS', :git => 'https://github.com/gali8/Tesseract-OCR-iOS.git', :commit => 'b4edaf737b9495b6d609375c1ff2875be9acdb47'
end

target 'ESRScan' do
	shared_pods
	pod 'Google/Analytics'
end

target 'ESRScanTests' do
	shared_pods
end

