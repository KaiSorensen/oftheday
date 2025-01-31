//
//  Images.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/30/25.
//


import SwiftUI
import UIKit
import CryptoKit
import Photos

extension UIImage {
    /// Computes the SHA256 hash of the UIImage's JPEG data to be used as an identification number for image
    /// - Returns: A hexadecimal string representation of the hash, or nil if conversion fails.
    func sha256Hash() -> String? {
        guard let data = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

struct Images {
    
    static func requestImagesAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    static func checkImageSettings(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        completion(status == .authorized || status == .limited)
    }
}

/*
 for handling the image data
 maintains a cache, with functions to retrieve the actual image data
 */
class ImageTable {
    
    static let imageTable = ImageTable()
    
    /// Directory where images are stored
    private let imagesDirectory: URL
    /// Reference counts stored as [imageID: count]
    private var referenceCounts: [String: Int] = [:]
    /// File name for reference counts
    private let referenceCountsFileName = "referenceCounts.json"
    
    private init() {
        // Initialize the images directory
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            imagesDirectory = documentsDirectory.appendingPathComponent("ImageTable", isDirectory: true)
            
            // Create the directory if it doesn't exist
            if !fileManager.fileExists(atPath: imagesDirectory.path) {
                do {
                    try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
                    print("Created ImageTable directory at \(imagesDirectory.path)")
                } catch {
                    fatalError("Failed to create ImageTable directory: \(error.localizedDescription)")
                }
            }
            
            // Load existing reference counts
            loadReferenceCounts()
        } else {
            fatalError("Unable to access documents directory.")
        }
    }
    
    // MARK: - Reference Counts Persistence
    
    /// Path to the reference counts file
    private var referenceCountsURL: URL {
        return imagesDirectory.appendingPathComponent(referenceCountsFileName)
    }
    
    /// Loads reference counts from disk
    private func loadReferenceCounts() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: referenceCountsURL.path) {
            do {
                let data = try Data(contentsOf: referenceCountsURL)
                let decoded = try JSONDecoder().decode([String: Int].self, from: data)
                referenceCounts = decoded
                print("Loaded reference counts.")
            } catch {
                print("Failed to load reference counts: \(error.localizedDescription)")
            }
        } else {
            referenceCounts = [:]
            print("No existing reference counts found. Starting fresh.")
        }
    }
    
    /// Saves reference counts to disk
    private func saveReferenceCounts() {
        do {
            let data = try JSONEncoder().encode(referenceCounts)
            try data.write(to: referenceCountsURL)
            print("Saved reference counts.")
        } catch {
            print("Failed to save reference counts: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Management
    
    /// Adds an image to the table. If it already exists, increments its reference count.
    /// - Parameter image: The UIImage to add.
    /// - Returns: The unique identifier (SHA256 hash string) of the image.
    func addImage(_ image: UIImage) -> String? {
        // Resize image to square
        guard let squareImage = resizeToSquare(image: image, size: CGSize(width: 500, height: 500)),
              let imageID = squareImage.sha256Hash() else {
            print("Failed to resize image or compute hash.")
            return nil
        }
        
        // Check if image already exists
        if referenceCounts[imageID] != nil {
            // Image already exists, increment reference count
            referenceCounts[imageID]! += 1
            print("Image already exists. Incremented reference count to \(referenceCounts[imageID]!).")
            saveReferenceCounts()
            return imageID
        }
        
        // Convert image to JPEG data
        guard let imageData = squareImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG.")
            return nil
        }
        
        // Save image to disk
        let imageURL = imagesDirectory.appendingPathComponent("\(imageID).jpg")
        do {
            try imageData.write(to: imageURL)
            print("Saved image to \(imageURL.path)")
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return nil
        }
        
        // Update reference counts
        referenceCounts[imageID] = 1
        saveReferenceCounts()
        
        return imageID
    }
    
    /// Increments the reference count for a given image.
    /// - Parameter imageID: The unique identifier of the image.
    func incrementReference(for imageID: String) {
        if let count = referenceCounts[imageID] {
            referenceCounts[imageID] = count + 1
            print("Incremented reference for \(imageID). New count: \(referenceCounts[imageID]!)")
        } else {
            // If the image doesn't exist, you might choose to handle it differently.
            print("Image ID \(imageID) not found. Adding it with a reference count of 1.")
            referenceCounts[imageID] = 1
        }
        saveReferenceCounts()
    }
    
    /// Decrements the reference count for a given image, and removes it if it has no more references.
    /// - Parameter imageID: The unique identifier of the image.
    func decrementReference(for imageID: String) {
        guard let count = referenceCounts[imageID] else {
            print("Image ID not found.")
            return
        }
        
        if count > 1 {
            referenceCounts[imageID] = count - 1
            print("Decremented reference for \(imageID). New count: \(referenceCounts[imageID]!)")
        } else {
            // Remove image from disk
            let imageURL = imagesDirectory.appendingPathComponent("\(imageID).jpg")
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("Deleted image at \(imageURL.path)")
            } catch {
                print("Failed to delete image: \(error.localizedDescription)")
            }
            // Remove reference count entry
            referenceCounts.removeValue(forKey: imageID)
            print("Removed reference count for \(imageID).")
        }
        
        // Save updated reference counts
        saveReferenceCounts()
    }
    
    /// Retrieves a UIImage by its unique identifier.
    /// - Parameter imageID: The unique identifier of the image.
    /// - Returns: The UIImage if found, else nil.
    func getImage(byID imageID: String) -> UIImage? {
        let imageURL = imagesDirectory.appendingPathComponent("\(imageID).jpg")
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            print("Image file does not exist at path: \(imageURL.path)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            print("Failed to load image data.")
            return nil
        }
        
        return image
    }
    
    /// Checks if an image already exists in the table by computing its hash.
    /// - Parameter image: The UIImage to check.
    /// - Returns: The imageID if it exists, else nil.
    func imageExists(_ image: UIImage) -> String? {
        guard let hash = image.sha256Hash() else { return nil }
        return referenceCounts[hash] != nil ? hash : nil
    }
    
    // MARK: - Helper Methods
    
    /// Resizes an image to a square of the given size.
    /// - Parameters:
    ///   - image: The original UIImage.
    ///   - size: The target size.
    /// - Returns: The resized square UIImage.
    private func resizeToSquare(image: UIImage, size: CGSize) -> UIImage? {
        let originalSize = image.size
        let length = min(originalSize.width, originalSize.height)
        let squareCropRect = CGRect(
            x: (originalSize.width - length) / 2,
            y: (originalSize.height - length) / 2,
            width: length,
            height: length
        )
        
        guard let cgImage = image.cgImage?.cropping(to: squareCropRect) else { return nil }
        let croppedImage = UIImage(cgImage: cgImage)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        croppedImage.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
