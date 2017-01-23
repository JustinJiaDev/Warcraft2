//
//  MapTiles.swift
//  Warcraft2
//
//  Created by Andrew van Tonningen on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import SpriteKit

class TerrainManager {

    // MARK: Member Variables

    var terrainTiles = [SKTexture]() // Array of terrain textures, can be identified using terrainTypes
    var terrainTypes: [TerrainMap.TileType] = [] // Array of terrain types, used to identify terrainTextures

    private var terrainDataFileName = "./data/img/Terrain.dat"

    // MARK: Public Functions

    // This function loads the possible terrain types and the location of the terrain.png file from terrain.dat, and then loads the textures from terrain.png.  It stores the textures and types in member variables terrainTiles and terrainTypes
    func loadTerrainTextures() {

        var numSprites: Int = 0
        var pngFileName: String = ""

        self.terrainTypes = loadTerrainDataFile(datFileName: terrainDataFileName, numSprites: &numSprites, fileName: &pngFileName)
        let terrainSpriteSheet = UIImage(named: pngFileName)
        self.terrainTiles = splitVerticalSpriteSheet(image: terrainSpriteSheet!, numSprites: numSprites)
    }

    // MARK: Private Functions

    // For splitting a sprite sheet (input as UIImage) into numSprites different textures, returned as [SKTexture]
    private func splitVerticalSpriteSheet(image: UIImage, numSprites: Int) -> [SKTexture] {

        let segmentHeight: CGFloat = image.size.height / CGFloat(numSprites)
        var cropRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: segmentHeight)
        var imageSegments: [SKTexture] = []

        for i in 0 ..< numSprites {

            cropRect.origin.y = CGFloat(i) * segmentHeight

            let currentSegmentCGImage = image.cgImage!.cropping(to: cropRect)
            let currentSegmentUIImage = UIImage(cgImage: currentSegmentCGImage!)
            let currentSegmentSKTexture = SKTexture(image: currentSegmentUIImage)

            imageSegments.append(currentSegmentSKTexture)
        }

        return imageSegments
    }

    // Reads .dat file to match textures in the png file to their correct TileTypes
    func loadTerrainDataFile(datFileName: String, numSprites: inout Int, fileName: inout String) -> [TerrainMap.TileType] {

        var fullFileText: String = ""
        var terrainTypesTemp: [TerrainMap.TileType] = []

        if let filePath = Bundle.main.path(forResource: "Terrain", ofType: "dat") {

            let fileUrl = URL(fileURLWithPath: filePath)
            do {
                fullFileText = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            } catch {
                print("Error loading terrain .dat file")
            }

            let fileLines: [String] = fullFileText.components(separatedBy: "\n")

            // Read line 0 and make it the filename of the associated png, removing the "./" in the file path
            fileName = fileLines[0]
            fileName.remove(at: fileName.startIndex)
            fileName.remove(at: fileName.startIndex)

            // Read line 1 and make it the size of the return array
            if let integerCastTemp = Int(fileLines[1]) {
                numSprites = integerCastTemp
            } else {
                fatalError("Error in \(fileName). Expecting integer.")
            }

            // Read remaining lines, interpreting each as an TileType
            let numLines = numSprites + 2
            for index in 2 ..< numLines {
                let tileType = TerrainMap.TileType.getType(fromString: fileLines[index])
                terrainTypesTemp.append(tileType)
            }

        } else {
            fatalError("Could not get file path for Terrain")
        }

        return terrainTypesTemp
    }
}
