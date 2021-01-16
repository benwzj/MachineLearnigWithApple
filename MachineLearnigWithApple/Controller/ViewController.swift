
import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            guard let ciimage = CIImage(image: imagePicked) else{
                fatalError("can't cover image which picked to CIImage")
            }
            predict (image: ciimage)
            
            imageView.image = imagePicked
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func predict(image: CIImage){
        guard let model = try? VNCoreMLModel(for: DogCatRabbitImageClassifierV1(configuration: MLModelConfiguration.init()).model) else {
            fatalError("can't load model for CoreML")
        }
        let request = VNCoreMLRequest (model: model) { (req, error) in
            guard let results = req.results as? [VNClassificationObservation] else{
                fatalError ("model fail to go ahead")
            }
            print ("predict result: ")
            print (results)
            if let firstResult = results.first{
                self.navigationItem.title = firstResult.identifier
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
}

