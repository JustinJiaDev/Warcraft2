//
//  DataSink.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class DataSink {

    func write(data _: UnsafeMutablePointer<UInt8>, length _: Int) -> Int {
        fatalError("You need to override this method.")
    }

    func container() -> DataContainer? {
        return nil
    }
}
