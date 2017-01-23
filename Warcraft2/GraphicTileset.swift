//
//  GraphicTileset.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/22/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class GraphicTileset {

    private var surfaceTileset: GraphicSurface?
    private var clippingMasks: [Int: GraphicSurface] = [:]
    private var mapping: [String: Int] = [:]
    private var tileNames: [String] = []
    private var groupNames: [String] = []
    private var groupSteps: [String: Int] = [:]
    private(set) var tileCount: Int = 0
    private(set) var tileWidth: Int = 0
    private(set) var tileHeight: Int = 0
    private(set) var tileHalfWidth: Int = 0
    private(set) var tileHalfHeight: Int = 0

    var groupCount: Int {
        fatalError("This method is not yet implemented.")
    }

    private static func parseGroupName(_ tileName: String) -> (String, Int)? {
        var name = tileName
        var numberString = ""
        while name.unicodeScalars.count > 0 {
            guard let last = name.unicodeScalars.last, !CharacterSet.decimalDigits.contains(last) else {
                numberString.unicodeScalars.insert(name.unicodeScalars.removeLast(), at: numberString.unicodeScalars.startIndex)
                continue
            }
            guard !numberString.isEmpty, let number = Int(numberString) else {
                return nil
            }
            return (name, number)
        }
        return nil
    }

    private func updateGroupNames() {
        groupSteps.removeAll()
        groupNames.removeAll()
        for tileName in tileNames {
            guard let (groupName, groupStep) = GraphicTileset.parseGroupName(tileName) else {
                continue
            }
            if let oldGroupStep = groupSteps[groupName] {
                groupSteps[groupName] = max(oldGroupStep, groupStep + 1)
            } else {
                groupSteps[groupName] = groupStep + 1
                groupNames.append(groupName)
            }
        }
    }

    func setTileCount(_ count: Int) -> Int {
        guard count > 0, tileWidth > 0, tileHeight > 0, let surfaceTileset = surfaceTileset else {
            return tileCount
        }
        guard count >= tileCount else {
            tileCount = count
            mapping.keys.filter { key in
                return self.mapping[key]! >= self.tileCount
            }.forEach { key in
                self.mapping.removeValue(forKey: key)
            }
            updateGroupNames()
            return tileCount
        }

        guard let tempSurface = GraphicFactory.createSurface(width: tileWidth, height: count * tileHeight, format: surfaceTileset.format()) else {
            return tileCount
        }
        tempSurface.copy(surface: surfaceTileset, dxPosition: 0, dyPosition: 0, width: -1, height: -1, sxPosition: 0, syPosition: 0)
        self.surfaceTileset = tempSurface
        tileCount = count
        return tileCount
    }

    func findTile(with name: String) -> Int {
        return mapping.first { key, _ in
            return key == name
        }?.value ?? -1
    }

    func groupName(at index: Int) -> String {
        guard index >= 0 || index < groupNames.count else {
            return ""
        }
        return groupNames[index]
    }

    func groupSteps(at index: Int) -> Int {
        return groupSteps(of: groupName(at: index))
    }

    func groupSteps(of groupName: String) -> Int {
        return groupSteps[groupName] ?? 0
    }

    func clearTile(at index: Int) -> Bool {
        guard index >= 0 || index < tileCount, let surfaceTileset = surfaceTileset else {
            return false
        }
        surfaceTileset.clear(xPosition: 0, yPosition: index * tileHeight, width: tileWidth, height: tileHeight)
        return true
    }

    func duplicateTile(destinationIndex: Int, tileName: String, sourceIndex: Int) -> Bool {
        guard sourceIndex > 0, destinationIndex > 0, sourceIndex < tileCount, destinationIndex < tileCount, !tileName.isEmpty else {
            return false
        }
        guard let surfaceTileset = surfaceTileset, clearTile(at: destinationIndex) else {
            return false
        }
        surfaceTileset.copy(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: destinationIndex * tileHeight,
            width: tileWidth,
            height: tileHeight,
            sxPosition: 0,
            syPosition: sourceIndex * tileHeight
        )
        mapping[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        mapping[tileName] = destinationIndex
        return true
    }

    func duplicateClippedTile(destinationIndex: Int, tileName: String, sourceIndex: Int, clipIndex: Int) -> Bool {
        guard sourceIndex > 0, destinationIndex > 0, clipIndex > 0, sourceIndex < tileCount, destinationIndex < tileCount, clipIndex < clippingMasks.count, !tileName.isEmpty else {
            return false
        }
        guard let surfaceTileset = surfaceTileset, let maskSurface = clippingMasks[clipIndex], clearTile(at: destinationIndex) else {
            return false
        }
        surfaceTileset.copyMaskSurface(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: destinationIndex * tileHeight,
            maskSurface: maskSurface,
            sxPosition: 0,
            syPosition: sourceIndex * tileHeight
        )
        mapping[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        mapping[tileName] = destinationIndex
        clippingMasks[destinationIndex] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
        clippingMasks[destinationIndex]?.copy(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: 0,
            width: tileWidth,
            height: tileHeight,
            sxPosition: 0,
            syPosition: destinationIndex * tileHeight
        )
        return true
    }

    func createClippingMasks() {
        fatalError("This method is not yet implemented.")
    }

    func loadTileset(dataSource: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    func drawTile(surface _: GraphicSurface, x _: Int, y _: Int, tileIndex _: Int) {
        fatalError("This method is not yet implemented.")
    }

    func drawClipped(surface _: GraphicSurface, x _: Int, y _: Int, tileIndex _: Int, rgb _: UInt32) {
        fatalError("This method is not yet implemented.")
    }
}
