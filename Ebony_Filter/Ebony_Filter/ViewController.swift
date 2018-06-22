//
//  ViewController.swift
//  Ebony_Filter
//
//  Created by Landry Achia Ndong on 2018-06-12.
//  Copyright © 2018 Landry Achia Ndong. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController,  UINavigationControllerDelegate {

    //outlet for image to be filtered
    @IBOutlet weak var imageToFilter: UIImageView!
    
    //outlet for slider to manipulate intensity as slider is dragged
    @IBOutlet weak var filterIntensity: UISlider!
    
    //outlet for change filter button
    @IBOutlet weak var changeFilterButton: UIButton!
    
    //outlet to save filtered image to user images
    @IBOutlet weak var saveFilteredImageButton: UIButton!
    //property to store UIImage containing the image selected by user from photo album
    var currentImage: UIImage!
    
    //context from CoreImage Framework to handle rendering of the image for Wakanda Filter
    let imageContext = CIContext()
    
    //CoreImage Filter to store filters selected by the user
    var currentImageFilters: CIFilter!
    
    let filterList = FilterListTypes()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disabling filter slider if user hasn't added any image
        filterIntensity.isEnabled = false
        
        //disabling filter slider if user hasn't added any image
        changeFilterButton.isEnabled = false
        
        //disabling filter slider if user hasn't added any image
        saveFilteredImageButton.isEnabled = false
        
        //modifying shape of  buttons
        changeFilterButton.layer.cornerRadius = 9.0
        
        saveFilteredImageButton.layer.cornerRadius = 9.0
        
        //objects of coreContext and coreFilterd
//        imageContext = CIContext()
//        let iniFilterValue = filterList.filtersDictionaryAll["CIUnsharpMask"].key
        currentImageFilters = CIFilter(name: "CIUnsharpMask")
        
        //title to appear on nav
        title = "Ebony Filter"
        
        //adding a add button on nav to allow users to add picture from album
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPictureFromAlbum))
        
        //bar button item which allows users to share picture after editing
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFilteredImage))
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //actions to change filter on the image calling the changeFilter()
    @IBAction func changeFilter(_ sender: UIButton) {
        let alertControllerAction = UIAlertController(title: "Choose a Filter", message: nil, preferredStyle: .actionSheet)
        
        for filterNames in filterList.filtersDictionaryAll.values {
            alertControllerAction.addAction(UIAlertAction(title: filterNames, style: .default, handler: selectFilter))
        }
//        alertControllerAction.addAction(UIAlertAction(title: "CIColorControls", style: .default, handler: selectFilter))
//        alertControllerAction.addAction(UIAlertAction(title: "CILinearToSRGBToneCurve", style: .default, handler: selectFilter))
        alertControllerAction.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertControllerAction, animated: true)
    }
    
    //action to save image to photo album after editing of the image is finished and user presses the save button
    @IBAction func saveFilteredImage(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageToFilter.image!, self, #selector(savingPictureWithSaveButton(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //action to update UI when user increases or decreases intensity
    @IBAction func intensityValueChanged(_ sender: UISlider) {
        processImageWithFilter()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo  info: [String : Any]) {
        guard let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        dismiss(animated: true)
        
        currentImage = imageSelected
        
        //setting imported image as value to Filter object then manipulating
        let initialImageForFilters = CIImage(image: currentImage)
        currentImageFilters.setValue(initialImageForFilters, forKey: kCIInputImageKey)
        
        
        //enabling save button, change filter button and filter intensity slider
        filterIntensity.isEnabled = true
        changeFilterButton.isEnabled = true
        saveFilteredImageButton.isEnabled = true
        
        //calling on method to process the image
        processImageWithFilter()
    }
    
    //this method handles the uialerts so user can select a filter of his/her choice
    func selectFilter(action: UIAlertAction) {
        //checks if there is a valid image first
        guard currentImage != nil else {return}
        
        for (filterKey, filterName) in filterList.filtersDictionaryAll {
            if filterName.elementsEqual(action.title!){
                currentImageFilters = CIFilter(name: filterKey)
                break
            }
        }
        
        
        let initialImage = CIImage(image: currentImage)
        currentImageFilters!.setValue(initialImage, forKey: kCIInputImageKey)
        
        processImageWithFilter()
    }
    
    func processImageWithFilter(){
//        currentImageFilters.setValue(filterIntensity.value, forKey: kCIInputIntensityKey)
        
        //image filters with different variables other than KCIInputIntensityKey
        let inputKeys = currentImageFilters.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey){
            currentImageFilters.setValue(filterIntensity.value, forKey: kCIInputIntensityKey)
        }
        
        
        if inputKeys.contains(kCIInputRadiusKey){
            currentImageFilters.setValue(filterIntensity.value*200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey){
            currentImageFilters.setValue(filterIntensity.value*10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey){
            currentImageFilters.setValue(CIVector(x: currentImage.size.width, y: currentImage.size.height), forKey: kCIInputCenterKey)
        }
        
        if inputKeys.contains(kCIInputEVKey){
            currentImageFilters.setValue(filterIntensity.value, forKey: kCIInputEVKey)
        }
        
//        if inputKeys.contains(kCIInputImageKey){
//            currentImageFilters?.setValue(CIImage(image: imageToFilter.image!), forKey: kCIInputImageKey)
//        }
        
        if let computerGeneratedImage = imageContext.createCGImage(currentImageFilters.outputImage!, from: currentImageFilters.outputImage!.extent){
            let processedImage = UIImage(cgImage: computerGeneratedImage)
            self.imageToFilter.image = processedImage
        }
    }
    
    //this method will act as selector  handle sharing of filtered image when share button is clicked
    @objc func shareFilteredImage() {
        let viewControlForActivity = UIActivityViewController(activityItems: [imageToFilter.image!], applicationActivities: [])
        viewControlForActivity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(viewControlForActivity, animated: true)
    }
    
    
    //this method will be used as selector method for saving images to user photo album with
    @objc func savingPictureWithSaveButton(_ image : UIImage, didFinishSavingWithError error:Error?, contextInfo:UnsafeRawPointer) {
        
        //managing error messages in case user rejects write permission to photo album
        if let error =  error {
            let errorAlert = UIAlertController (title: "Error Saving Picture", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }else {
            let saveWithoutError = UIAlertController(title: "Saved!", message: "Ebony filtered Image Saved Successfully", preferredStyle: .alert)
            saveWithoutError.addAction(UIAlertAction(title: "Ok", style: .default))
            present(saveWithoutError, animated: true)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    //objective c method to control method for selector how to import picture from album
    @objc func importPictureFromAlbum(){
        //creating an object of UIImagePickerController class (will allow editing of images too by modifying Info.plist
        let imagePicker = UIImagePickerController()
        
        //allow editing of the image
        imagePicker.allowsEditing = true
        
        //assigning delegate
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
}

