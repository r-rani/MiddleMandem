//  BoardsManager.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import Foundation
import Observation

@Observable
class BoardsManager {
    var boards: [Board] = []
    
    func addBoard(_ board: Board) {
        boards.append(board)
    }
    
    func updateBoard(_ board: Board) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            boards[index] = board
        }
    }
    
    func deleteBoard(_ board: Board) {
        boards.removeAll { $0.id == board.id }
    }
    
    // Get all locations from all boards
    func getAllLocations() -> [(location: Location, board: Board)] {
        var allLocations: [(Location, Board)] = []
        for board in boards {
            for location in board.locations {
                allLocations.append((location, board))
            }
        }
        return allLocations
    }
}
