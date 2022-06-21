//
//  ResultView.swift
//  🍣Poses
//
//  Created by Sima Nerush on 6/21/22.
//

import SwiftUI
import Vision
import CoreGraphics

struct ResultView: View {
    @Binding var image: UIImage
    
    var body: some View {
        VStack {
            Text("Pose detected:")
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500, alignment: .center)
                .foregroundColor(.white)
                .background(.gray)
                .onAppear {
                    processImage(image: image)
                }
        }
        
    }
    
    func processImage(image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
        
        // Process each observation to find the recognized body pose points.
        observations.forEach { processObservation($0) }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(.torso) else { return }
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
            .neck,
            .rightShoulder,
            .rightHip,
            .root,
            .leftHip,
            .leftShoulder
        ]
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let imagePoints: [CGPoint] = torsoJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
            return VNImagePointForNormalizedPoint(point.location,
                                                  500,
                                                  500)
        }
        
        draw(points: imagePoints, on: &image)
    }
    
    func draw(points: [CGPoint], on image: inout UIImage) {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        for point in points {
            image.draw(at: point)
        }
        
        context!.drawPath(using: .fill)
        
        let imageOutput = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        image = imageOutput!
    }
}
