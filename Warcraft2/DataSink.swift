//
//  DataSink.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

protocol DataSink {
    func write(data: Data)
    func container() -> DataContainer?
}
