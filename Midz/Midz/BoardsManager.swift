//
//  BoardsManager.swift
//  Midz
//
//  Manages board data and related operations.
//

import Foundation
import Observation

/// Manages a collection of boards and provides
/// methods for creating, updating, and deleting boards.
@Observable
class BoardsManager {

    /// All boards owned or accessible by the user
    var boards: [Board] = []

    /// Adds a new board to the collection
    /// - Parameter board: The board to add
    func addBoard(_ board: Board) {
        boards.append(board)
    }

    /// Updates an existing board if it exists
    /// - Parameter board: The board containing updated data
    func updateBoard(_ board: Board) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            boards[index] = board
        }
    }

    /// Deletes a board from the collection
    /// - Parameter board: The board to remove
    func deleteBoard(_ board: Board) {
        boards.removeAll { $0.id == board.id }
    }

    /// Retrieves all locations across all boards
    /// - Returns: An array of tuples pairing each location
    ///   with the board it belongs to
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
