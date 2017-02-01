//
//  GraphicRecolorMap.swift
//  Warcraft2
//
//  Created by Anthony on 1/31/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class GraphicRecolorMap{
    
    private var DState: Int
    private var DMapping: Dictionary<String, Int>
    private var DColorNames: Array<String>
    private var DColors: Array<Array<UInt32>>
    private var DOriginalColors: Array<Array<UInt32>>
    
    init() {
        DState = -1
        DMapping = [:]
        DColorNames = []
        DColors = []
        DOriginalColors = []
    }
    
    func groupCount() -> Int {
        return DColors.count
    }
    
    func colorCount() -> Int {
        if DColors.count > 0 {
            return DColors[0].count
        }
        return 0
    }
    
    func findColor(colorname: String) -> Int {
        fatalError("This method is not yet implemented.")
    }
    
    func colorValue(gindex: Int, cindex: Int) -> UInt32 {
        fatalError("This method is not yet implemented.")
    }
    
    func load(source: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }
    
    func observePixels() -> UInt32 {
        fatalError("This method is not yet implemented.")
    }
    
    func recolorPixels() -> UInt32 {
        fatalError("This method is not yet implemented")
    }
    
    func recolorSurface(index: Int, srcsurface: GraphicSurface) -> GraphicSurface {
        fatalError("This method is not yet implemented")
    }
    
}


