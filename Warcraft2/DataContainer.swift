//
//  DataContainer.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class DataContainerIterator {
    func name() -> String {
        fatalError("You need to override this method.")
    }

    func isContainer() -> Bool {
        fatalError("You need to override this method.")
    }

    func isValid() -> Bool {
        fatalError("You need to override this method.")
    }

    func next() {
        fatalError("You need to override this method.")
    }
}

class DataContainer {
    func first() -> DataContainerIterator {
        fatalError("You need to override this method.")
    }

    func dataSource(name: String) -> DataSource {
        fatalError("You need to override this method.")
    }

    func dataSink(name: String) -> DataSink {
        fatalError("You need to override this method.")
    }

    func dataContainer(name: String) -> DataContainer {
        fatalError("You need to override this method.")
    }
}
