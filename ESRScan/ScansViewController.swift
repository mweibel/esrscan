//
//  Scans view controller
//
//  Copyright © 2015 Michael Weibel. All rights reserved.
//  License: MIT
//

import UIKit

class ScansViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var topToolbar: UIToolbar!
    // handling of tableView within extension TableView.swift
    @IBOutlet var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"

    var activityIndicator: ActivityIndicator?
    var scans = Scans()
    var disco : Discover?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        trackView("ScansViewController")
        self.disco = Discover.sharedInstance

        if self.disco?.connection != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        if scans.count() == 0 {
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }

    func performImageRecognition(rawImage: UIImage, autoCrop: Bool = true) {
        trackEvent("Scan", action: "Image captured", label: nil, value: nil)

        let image = preprocessImage(rawImage, autoCrop: false)
        
        let ocr = OCR.init()
        ocr.recognise(image)

        let text = ocr.recognisedText()
        let textArr = text.componentsSeparatedByString("\n").filter{
            // make sure only valid strings in the array go in.
            $0.containsString(">") && $0.characters.count > 35 && $0.characters.count <= 53
        }
        trackEvent("Scan", action: "Possible ESR Codes", label: nil, value: textArr.count)
        if textArr.count > 0 {
            let esrCode = textArr[textArr.count-1]
            do {
                let esrCode = try ESR.parseText(esrCode)
                self.scans.addScan(esrCode)
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.tableView!.reloadData()

                if !esrCode.amountCheckDigitValid() {
                    trackEvent("Scan", action: "Parse success", label: "Parse error: amount", value: nil)
                }
                if !esrCode.refNumCheckDigitValid() {
                    trackEvent("Scan", action: "Parse success", label: "Parse error: refNum", value: nil)
                }
                if esrCode.amountCheckDigitValid() && esrCode.refNumCheckDigitValid() {
                    trackEvent("Scan", action: "Parse success", label: "No error", value: nil)
                }

                self.disco?.connection?.sendRequest(esrCode.dictionary(), callback: { status in
                    if status == true {
                        trackEvent("Scan", action: "ESR transmitted", label: nil, value: nil)
                        esrCode.transmitted = true
                        self.tableView.reloadData()
                    }
                })
            } catch ESRError.AngleNotFound {
                trackCaughtException("AngleNotFound in string '\(esrCode)'")
                retryOrShowAlert(rawImage, autoCrop: autoCrop,
                    title: NSLocalizedString("Scan failed", comment: "Scan failed title in alert view"),
                    message: NSLocalizedString("Error scanning ESR code, please try again", comment: "Error message")
                )
            } catch let error {
                trackCaughtException("Error scanning ESR Code in string '\(esrCode)': \(error)")
                retryOrShowAlert(rawImage, autoCrop: autoCrop,
                    title: NSLocalizedString("Scan failed", comment: "Scan failed title in alert view"),
                    message: NSLocalizedString("Error scanning ESR code, please try again", comment: "Error message")
                )
            }
        } else {
            trackCaughtException("Error finding ESR Code on picture with width '\(rawImage.size.width)' and height '\(rawImage.size.height)'")
            retryOrShowAlert(rawImage, autoCrop: autoCrop,
                title: NSLocalizedString("Scan failed", comment: "Scan failed title in alert view"),
                message: NSLocalizedString("Error finding ESR code on picture, please try again", comment: "Error message")
            )
        }

        activityIndicator?.hide()
    }

    func retryOrShowAlert(rawImage: UIImage, autoCrop: Bool, title: String, message: String) {
        if autoCrop {
            return performImageRecognition(rawImage, autoCrop: false)
        }
        return showAlert(title, message: message)
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let actionOk = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK Button on alert view"),
            style: .Default,
            handler: nil
        )
        alertController.addAction(actionOk)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func takePhoto(sender: AnyObject) {
        let imagePickerActionSheet = UIAlertController(title: NSLocalizedString("Snap/Use Photo", comment: "Title for menu which appears when clicking the camera button."),
            message: nil, preferredStyle: .ActionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Menu-item title for taking a photo using the camera."),
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }

        let libraryButton = UIAlertAction(title: NSLocalizedString("Choose existing", comment: "Menu-item title for choosing an existing photo from the library."),
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)

        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button"),
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }

    @IBAction func clearTextView(sender: AnyObject) {
        let alertCtrl = UIAlertController.init(
            title: NSLocalizedString("Clear scans", comment: "Button for clearing the scanned items"),
            message: NSLocalizedString("Are you sure you want to remove the scans?", comment:"Message if its ok to clear the scans"),
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alertCtrl.addAction(UIAlertAction(
            title: NSLocalizedString("Yes", comment: "Button for confirming that clearing the scans is ok."),
            style: .Default,
            handler: {
                (action: UIAlertAction!) in
                    self.scans.clear()
                    self.tableView!.reloadData()
                    self.navigationItem.leftBarButtonItem?.enabled = false
            }
        ))

        alertCtrl.addAction(UIAlertAction(
            title: NSLocalizedString("No", comment: "No button"),
            style: .Default,
            handler: nil
        ))

        presentViewController(alertCtrl, animated: true, completion: nil)
    }

    @IBAction func shareTextView(sender: AnyObject) {
        trackEvent("Share Button", action: "Click", label: nil, value: nil)
        let activtyCtrl = UIActivityViewController.init(activityItems: [self.scans.string()], applicationActivities: nil)
        self.presentViewController(activtyCtrl, animated: true, completion: nil)
    }
}
