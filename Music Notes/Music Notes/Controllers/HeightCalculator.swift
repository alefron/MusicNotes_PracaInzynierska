//
//  HeightCalculator.swift
//  Music Notes
//
//  Created by Aleksandra Front on 06/01/2022.
//

import Foundation
import UIKit

class HeightCalculator {
    var staffModel: StaffModel
    var prediction: String
    var minFilledSecondFound: CGFloat
    var minFilledFirstFound: CGFloat
    
    init(staffModel: StaffModel, prediction: String) {
        self.staffModel = staffModel
        self.prediction = prediction
        
        switch prediction {
        case "whole":
            minFilledSecondFound = 37
            minFilledFirstFound = 20
        case "half":
            minFilledSecondFound = 37
            minFilledFirstFound = 20
        case "quarter":
            minFilledSecondFound = 47
            minFilledFirstFound = 18
        case "eight":
            minFilledSecondFound = 20
            minFilledFirstFound = 16
        case "sixteenth":
            minFilledSecondFound = 20
            minFilledFirstFound = 16
        default:
            minFilledSecondFound = 10
            minFilledFirstFound = 7
        }
    }
    
    func calculateHeight_TheMostFilledField(imageOneNote: UIImage) -> Int {
        //for each of staff fields
        var currentMaxFilledFieldValue = 0
        var currentMaxFilledFieldIndex = 5
        for i in (0...staffModel.fields.count - 1).reversed() {
            let croppedImage = self.cutImageOneField(
                image: imageOneNote,
                field: staffModel.fields[i],
                step: staffModel.step
            )
            //get pixels array of an image
            let pixels = croppedImage.pixelData()
            
            //counting percent of color filled
            var ind = 0
            var transparentPixelsCount = 0
            var colorPixelsCount = 0
            while (ind < pixels!.count) {
                if (pixels![ind] == 0) {
                    transparentPixelsCount += 1
                } else {
                    colorPixelsCount += 1
                }
                ind += 4
            }
            
            //if new max is found, replace previous
            let percentOfColor = colorPixelsCount*100/(colorPixelsCount + transparentPixelsCount)
            if (percentOfColor >= currentMaxFilledFieldValue) {
                currentMaxFilledFieldValue = percentOfColor
                currentMaxFilledFieldIndex = staffModel.fields[i].index
            }
        }
        return currentMaxFilledFieldIndex
    }
    
    func calculateHeight_SecondOneFromBottom(imageOneNote: UIImage) -> Int {
        var firstFromBottomFound = false
        var maxFilledFieldIndex = 5
        var currentMaxFilled: Float = 0
        for i in (0...staffModel.fields.count - 1).reversed() {
            let croppedImage = self.cutImageOneField(
                image: imageOneNote,
                field: staffModel.fields[i],
                step: staffModel.step
            )
            //get pixels array of an image
            let pixels = croppedImage.pixelData()
            
            //counting percent of color filled
            var ind = 0
            var transparentPixelsCount = 0
            var colorPixelsCount = 0
            while (ind < pixels!.count) {
                if (pixels![ind] == 0) {
                    transparentPixelsCount += 1
                } else {
                    colorPixelsCount += 1
                }
                ind += 4
            }
            
            let percentOfColor = Float(colorPixelsCount)*100/Float(colorPixelsCount + transparentPixelsCount)
            
            if (!firstFromBottomFound && staffModel.fields[i].index == 2) {
                maxFilledFieldIndex = 2
                break
            }
            if (firstFromBottomFound && staffModel.fields[i].index == 2 * staffModel.linesCount && Float(percentOfColor) < Float(minFilledSecondFound)) {
                maxFilledFieldIndex = staffModel.fields[i].index
                break
            }
            
            if (Float(percentOfColor) > Float(currentMaxFilled) && firstFromBottomFound) {
                maxFilledFieldIndex = staffModel.fields[i].index
                currentMaxFilled = percentOfColor
                if (Float(percentOfColor) > Float(minFilledSecondFound)) {
                    break
                }
            }
            
            if (percentOfColor != 0 && !firstFromBottomFound) {
                firstFromBottomFound = true
            }
        }
        return maxFilledFieldIndex
    }
    
    func calculateHeight_TheBigestOfThreeFromBottom(imageOneNote: UIImage) -> Int {
        var firstFromBottomFound = false
        var secondFromBottomFound = false
        var thirdFromBottomFound = false
        
        var firstFromBottomValue: Float = 0
        var secondFromBottomValue: Float = 0
        var thirdFromBottomValue: Float = 0
        
        var firstFoundFieldIndex = 0
        
        var maxFilledFieldIndex = 5
        var currentMaxFilled: Float = 0
        
        for i in (0...staffModel.fields.count - 1).reversed() {
            let croppedImage = self.cutImageOneField(
                image: imageOneNote,
                field: staffModel.fields[i],
                step: staffModel.step
            )
            //get pixels array of an image
            let pixels = croppedImage.pixelData()
            
            //counting percent of color filled
            var ind = 0
            var transparentPixelsCount = 0
            var colorPixelsCount = 0
            while (ind < pixels!.count) {
                if (pixels![ind] == 255) {
                    transparentPixelsCount += 1
                } else {
                    colorPixelsCount += 1
                }
                ind += 4
            }
            
            let percentOfColor = Float(colorPixelsCount)*100/Float(colorPixelsCount + transparentPixelsCount)
            
            if (!firstFromBottomFound && staffModel.fields[i].index == 2) {
                maxFilledFieldIndex = 2
                break
            }
            if (staffModel.fields[i].index == 2 * staffModel.linesCount + 1 && Float(percentOfColor) > Float(3)) {
                maxFilledFieldIndex = staffModel.fields[i].index - 1
                break
            }
            
            if (percentOfColor != 0 && !firstFromBottomFound) {
                firstFromBottomFound = true
                firstFromBottomValue = percentOfColor
                firstFoundFieldIndex = staffModel.fields[i].index
                maxFilledFieldIndex = staffModel.fields[i].index
                currentMaxFilled = percentOfColor
                continue
            }
            if (firstFromBottomFound && !secondFromBottomFound) {
                secondFromBottomFound = true
                secondFromBottomValue = percentOfColor
                if (percentOfColor > currentMaxFilled) {
                    maxFilledFieldIndex = staffModel.fields[i].index
                    currentMaxFilled = percentOfColor
                }
                continue
            }
            if (secondFromBottomFound && !thirdFromBottomFound) {
                thirdFromBottomFound = true
                thirdFromBottomValue = percentOfColor
                if (percentOfColor > currentMaxFilled && Float(secondFromBottomValue/firstFromBottomValue) > 3) {
                    maxFilledFieldIndex = staffModel.fields[i].index
                    currentMaxFilled = percentOfColor
                }
                break
            }
        }
        return maxFilledFieldIndex
    }
            
    func cutImageOneField(image: UIImage, field: StaffField, step: CGFloat) -> UIImage {
        let sourceCGImage = image.cgImage!
        
        //crop image - get only one field part
        let croppedCGImage = sourceCGImage.cropping(
            to: CGRect(origin: CGPoint(x: 0, y: field.upperBound),
                       size: CGSize(width: sourceCGImage.width, height: Int(field.lowerBound)))
        )
        //convert back to UIImage
        return UIImage(
            cgImage: croppedCGImage!,
            scale: image.imageRendererFormat.scale,
            orientation: image.imageOrientation
        )
    }
        
}


extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context!.setFillColor(UIColor.white.cgColor);
        context!.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return pixelData
    }
    
    func pixel2DData() -> [[PixelRGBA]]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context!.setFillColor(UIColor.white.cgColor);
        context!.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var i = 0
        var j = 0
        var outArray = Array(repeating: Array(repeating: PixelRGBA(), count: Int(size.width)), count: Int(size.height))
        while (i < Int(size.height)) {
            while (j < Int(size.width)) {
                outArray[i][j] = PixelRGBA(alpha: 255,
                                           red: pixelData[i*Int(size.width)*4 + j*4],
                                           green: pixelData[i*Int(size.width)*4 + 4*j + 1],
                                           blue: pixelData[i*Int(size.width)*4 + 4*j + 2])
                
                j += 1
            }
            i += 1
            j = 0
        }
        
        return outArray
    }
    
    convenience init?(pixels: [PixelRGBA], width: Int, height: Int) {
            guard width > 0 && height > 0, pixels.count == width * height else { return nil }
            var data = pixels
            guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<PixelRGBA>.size) as CFData)
                else { return nil }
            guard let cgim = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * MemoryLayout<PixelRGBA>.size,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
                provider: providerRef,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
            else { return nil }
            self.init(cgImage: cgim)
        }
 }
