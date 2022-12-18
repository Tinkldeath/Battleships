import Foundation


final class GamePresenter {
    
    private(set) var interactor: GameInteractor?
    private var view: GameViewController?
    
    init(_ interactor: GameInteractor?, _ view: GameViewController?) {
        self.interactor = interactor
        self.view = view
    }
    
    func presentPlayerMove(_ state: Game.GameState) {
        self.view?.displayPlayerMove(state)
    }
    
    func presentEnemyMove(_ state: Game.GameState) {
        self.view?.displayEnemyMove(state)
    }
    
    func presentPlayerBoard(_ board: Board?) {
        if let board = board {
            var points = [Point]()
            for point in board.points {
                points.append(point)
            }
            self.view?.displayPlayerBoard(points)
        }
    }
    
    func presentEnemyBoard(_ board: Board?) {
        if let board = board {
            var points = [Point]()
            for point in board.points {
                points.append(point)
            }
            self.view?.displayEnemyBoard(points)
        }
    }
    
    func presentEnemyReady(_ ready: Bool) {
        self.view?.displayEnemyReady(ready)
    }
    
    func presentReady() {
        self.view?.displayReady()
    }
    
    func presentNotReady() {
        self.view?.displayNotReady()
    }
    
    func presentWin(_ bet: Int) {
        self.view?.displayWin(bet)
    }
    
    func presentLose(_ bet: Int) {
        self.view?.displayLose(bet)
    }
    
}
