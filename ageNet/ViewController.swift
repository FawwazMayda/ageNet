//
//  ViewController.swift
//  ageNet
//
//  Created by Muhammad Fawwaz Mayda on 21/07/20.
//  Copyright © 2020 Muhammad Fawwaz Mayda. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var acneLabel: UILabel!
    
    @IBOutlet weak var wrinkleLabel: UILabel!
    
    
    let netreq = NetReq()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        netreq.acneLabel = self.acneLabel
        netreq.wrinkleLabel = self.wrinkleLabel
    }

    @IBAction func photoTapped(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func detectAge(image: CIImage) {
        print("Try Detecting")
        guard let model = try? VNCoreMLModel(for: AgeNet().model) else {
            fatalError("Cant load model")
        }
        
        let res = VNCoreMLRequest(model: model) { [weak self] res, error in
            guard let resc = res.results as? [VNClassificationObservation],let conf = res.results as? [VNObservation],let topRes = resc.first else {
                fatalError("No Results")
            }
            for i in 0..<resc.count {
                let className = resc[i].identifier
                let confScore = conf[i].confidence
                print("\(className) with confidence: \(confScore)")
            }
            print(topRes.identifier)
            DispatchQueue.main.async {
                self?.ageLabel.text = "Your age: \(topRes.identifier)"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([res])
            } catch {
                print("Error")
            }
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        imageView.image = image
        
        guard let cgImage = CIImage(image: image) else {
            fatalError("Cant convert to CGIMage")
        }
        dismiss(animated: true)
        detectAge(image: cgImage)
        //netreq.doRequests(withImage: image)
        netreq.doRequestsAlamo(withImage: image)
    }
    
}
