//
//  DataSource.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

protocol DataSource {
    func readData(ofLength length: Int) -> Data
    func container() -> DataContainer?
}
