//
//  Path.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import Foundation

class LiarPath: ObservableObject {
    @Published var paths: [PathDestination]
    
    init(paths: [PathDestination] = []) {
        self.paths = paths
    }
}

enum PathDestination {
    case createRoom
    case connectRoom
}
