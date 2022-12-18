import Foundation


final class GameInteractor {
        
    private let loginManager = LoginManager.shared
    private let playerWorker = PlayerWorker()
    private var gameWorker = GameWorker(nil)
    
    var presenter: GamePresenter?
    private var shipsToPlace: [Ship: Int] = [
        .fourdeck: 1,
        .threedeck: 2,
        .twodeck: 3,
        .onedeck: 4
    ]
    
    func initialize() async {
        do {
            let player = try await playerWorker.instantiatePlayer(self.loginManager.login, self.loginManager.password)
            self.gameWorker = GameWorker(player)
            try await self.gameWorker.instantiateGame(self.loginManager.login, self.loginManager.password)
            self.setBindings()
        } catch {
            print(String(describing: error))
        }
    }
    
    func setShipAction(_ coordinates: [(x: Int, y: Int)]) {
        Task { [weak self] in
            do {
                try await self?.gameWorker.trySetShip(coordinates, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
                guard let ptr = self else { return }
                if let ship = Ship(rawValue: coordinates.count) {
                    ptr.shipsToPlace.updateValue(ptr.shipsToPlace[ship]!-1, forKey: ship)
                }
            } catch {
                print(String(describing: error))
                return
            }
        }
    }
    
    private func setBindings() {
        self.gameWorker.game.bind { [weak self] game in
            if let game = game {
                if game.current?._id == self?.gameWorker.player?._id {
                    self?.presenter?.presentPlayerMove(game.state)
                } else {
                    self?.presenter?.presentEnemyMove(game.state)
                }
                if game.player1?._id == self?.gameWorker.player?._id {
                    self?.presenter?.presentPlayerBoard(game.player1Board)
                    self?.presenter?.presentEnemyBoard(game.player2Board)
                    self?.presenter?.presentEnemyReady(game.player2Ready)
                } else {
                    self?.presenter?.presentPlayerBoard(game.player2Board)
                    self?.presenter?.presentEnemyBoard(game.player1Board)
                    self?.presenter?.presentEnemyReady(game.player1Ready)
                }
                if game.state == .end {
                    guard let player = self?.gameWorker.player else { return }
                    guard let winner = game.winner else { return }
                    if player._id == winner._id {
                        self?.presenter?.presentWin(game.bet)
                    } else {
                        self?.presenter?.presentLose(game.bet)
                    }
                    self?.endGame(game)
                }
            }
        }
    }
    
    private func endGame(_ game: Game) {
        Task { [weak self] in
            do {
                try await self?.gameWorker.dropGame(game, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func availableShips() -> [Ship: Int] {
        return self.shipsToPlace
    }
    
    func resignAction() {
        guard let game = self.gameWorker.game.value else { return }
        Task { [weak self] in
            do {
                try await self?.gameWorker.resign(game, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func readyAction() {
        var ready: Bool = true
        for key in self.shipsToPlace.keys {
            if self.shipsToPlace[key]! != 0 {
                ready = false
                break
            }
        }
        if ready {
            self.presenter?.presentReady()
            Task { [weak self] in
                do {
                    try await self?.gameWorker.setReady(self?.loginManager.login ?? "", self?.loginManager.password ?? "")
                } catch {
                    print(String(describing: error))
                }
            }
        } else {
            self.presenter?.presentNotReady()
        }
    }
    
    func attackAction(_ point: (x: Int, y: Int)) {
        Task { [weak self] in
            do {
                try await self?.gameWorker.attack(point, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
}
