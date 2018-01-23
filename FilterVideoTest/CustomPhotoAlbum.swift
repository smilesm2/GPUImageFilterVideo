import Foundation
import Photos
import ImageIO
import MobileCoreServices
import UIKit
class CustomPhotoAlbum {
    
    static let albumName = "GPUImageTest"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject! as PHAssetCollection
            }
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    enum MyError: Error {
        case FoundNil(String)
    }
    enum saveActions: String {
        case save
        case share
    }
    func saveVideo(_ url:URL , handler: ((Bool) -> Swift.Void)? = nil) {
        do {
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                assetChangeRequest?.creationDate = Date()
                
                albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)
            }, completionHandler: { (bol, error) in
            })
        }
        handler?(true)        
    }
}

