# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

def shared_pods
	#pod 'TesseractOCRiOS', '4.0.0'
	pod 'TesseractOCRiOS', :path => '~/code/receipt-parser/einzahlungsschein/Tesseract-OCR-iOS'
	pod 'GPUImage', '0.1.7'
end

target 'ESRScanner' do
	shared_pods
end

target 'ESRScannerTests' do
	shared_pods
end

