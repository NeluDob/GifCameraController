//
//  GifCameraPreviewView.swift
//  Pods
//
//  Created by Lawrence Tran on 4/7/16.
//
//

import Foundation
import Darwin
import UIKit
import GLKit
import AVFoundation

protocol PreviewTarget {
    func setImage(image: CIImage)
}

public class GifCameraPreviewView: GLKView, PreviewTarget {
    
    var coreImageContext: CIContext!
    var drawableBounds: CGRect!
    static public var currentFilter: CIFilter!
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame, context: GifContextManager.sharedInstance.eaglContext)
        self.enableSetNeedsDisplay = false
        self.isOpaque = true
        self.frame = frame
        self.backgroundColor = UIColor.cyan
        
        self.bindDrawable()
        self.drawableBounds = self.bounds
        self.drawableBounds.size.width = CGFloat(self.drawableWidth)
        self.drawableBounds.size.height = CGFloat(self.drawableHeight)
        self.coreImageContext = GifContextManager.sharedInstance.ciContext
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImage(image: CIImage) {
        self.bindDrawable()
        
        if let filter = GifCameraPreviewView.currentFilter {

            if GifCameraController.currentDevicePosition == .front {
                self.coreImageContext.draw(image, in: self.drawableBounds, from: image.extent)
                
                self.display()
            } else {
            
            filter.setValue(image, forKey: kCIInputImageKey)
            
            if let output = filter.outputImage {
                if let cgimg = self.coreImageContext.createCGImage(output, from: output.extent) {
                    self.coreImageContext.draw(CIImage(cgImage: cgimg), in: self.drawableBounds, from: image.extent)
                    
                    self.display()
                }
            }
            
            }
        } else {
            self.coreImageContext.draw(image, in: self.drawableBounds, from: image.extent)

            self.display()
        }
        
    }
}

class GifContextManager: NSObject {
    static let sharedInstance = GifContextManager()
    var eaglContext: EAGLContext!
    var ciContext: CIContext!
    override init() {
        super.init()
        self.eaglContext = EAGLContext(api: .openGLES2)
        let options: [String : AnyObject] = [kCIContextWorkingColorSpace: NSNull()]
        self.ciContext = CIContext(eaglContext: self.eaglContext, options: options)
    }
}
