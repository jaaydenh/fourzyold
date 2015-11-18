

struct Move: CustomStringConvertible {
    let column: Int
    let row: Int
    let direction: Direction
    let player: PieceType
    
    init(column: Int, row: Int, direction: Direction, player: PieceType) {
        self.column = column
        self.row = row
        self.direction = direction
        self.player = player
    }
    
    var description: String {
        return "column: \(column), row: \(row), direction: \(direction), player: \(player)"
    }
}

