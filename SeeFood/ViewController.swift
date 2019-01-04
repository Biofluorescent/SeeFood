//
//  ViewController.swift
//  SeeFood
//
//  Created by Tanner Quesenberry on 1/3/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //.photoLibrary to allow user to select from their photos
        imagePicker.allowsEditing = false
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Downcast to UIImage, optional bind
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // Convert to all vision and CoreML Usages
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage.")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    func detect(image: CIImage){
        
        //Load up imported model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        //Create request for model to classify data we pass in. Results callback after handler performed.
        let request = VNCoreMLRequest(model: model)
        { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                }else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
            
        }
        
        //Pass data via handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
       
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

