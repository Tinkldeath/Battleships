import Foundation
import RealmSwift


class Game: Object {
    
    enum GameState: String, PersistableEnum {
        case prepare = "Prepare"
        case play = "Play"
        case end = "End"
    }
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var state: GameState
    @Persisted var player1: Player?
    @Persisted var player2: Player?
    @Persisted var current: Player?
    
    @Persisted var player1Board: Board?
    @Persisted var player2Board: Board?
    
    @Persisted var player1Ready: Bool
    @Persisted var player2Ready: Bool
    
    @Persisted var winner: Player?
    @Persisted var loser: Player?
    @Persisted var bet: Int
    
    
    convenience init(_ player1: Player?, _ player2: Player?, _ bet: Int) {
        self.init()
        self.state = .prepare
        self.player1 = player1
        self.player2 = player2
        self.player1Board = Board(player1)
        self.player2Board = Board(player2)
        self.player1Ready = false
        self.player2Ready = false
        self.winner = nil
        self.loser = nil
        self.current = player1
        self.bet = bet
    }
    
}
