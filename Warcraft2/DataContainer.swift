//
//  DataContainer.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

protocol DataContainerIterator {
    func name() -> String
    func isContainer() -> Bool
    func isValid() -> Bool
    func next()
}

protocol DataContainer {
    func first() -> DataContainerIterator
    func dataSource(name: String) -> DataSource
    func dataSink(name: String) -> DataSink
    func dataContainer(name: String) -> DataContainer
}
