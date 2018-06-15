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
    
    //property to store UIImage containing the image selected by user from photo album
    var currentImage: UIImage!
    
    //context from CoreImage Framework to handle rendering of the image for Wakanda Filter
    var imageContext: CIContext!
    
    //CoreImage Filter to store filters selected by the user
    var currentImageFilters: CIFilter!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //objects of coreContext and coreFilterd
        imageContext = CIContext()
        currentImageFilters = CIFilter(name: "CIUnsharpMask")
        
        //title to appear on nav
        title = "Wakanda Filter"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPictureFromAlbum))
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //actions to change filter on the image calling the changeFilter()
    @IBAction func changeFilter(_ sender: UIButton) {
    }
    
    
    //action to save image to photo album after editing of the image is finished
    @IBAction func saveFilteredImage(_ sender: UIButton) {
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
        
        //calling on method to process the image
        processImageWithFilter()
    }
    
    
    
    func processImageWithFilter(){
        currentImageFilters.setValue(filterIntensity.value, forKey: kCIInputIntensityKey)
        if let computerGeneratedImage = imageContext.createCGImage(currentImageFilters.outputImage!, from: currentImageFilters.outputImage!.extent){
            let processedImage = UIImage(cgImage: computerGeneratedImage)
            self.imageToFilter.image = processedImage
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

