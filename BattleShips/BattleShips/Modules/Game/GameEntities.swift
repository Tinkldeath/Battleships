import Foundation
import RealmSwift


class GameWorker {
    
    private(set) var game: Observable<Game?> = Observable<Game?>(value: nil)
    private var notificationToken: NotificationToken?
    private(set) var player: Player?
    
    init(_ player: Player?) {
        self.player = player
    }
    
    @MainActor
    func instantiateGame(_ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        self.notificationToken = realm.objects(Game.self).observe(keyPaths: [], { [weak self] _ in
            self?.game.value = realm.objects(Game.self).first(where: { $0.player1?._id == self?.player?._id || $0.player2?._id == self?.player?._id })
        })
    }
    
    @MainActor
    func trySetShip(_ coordinates: [(x: Int, y: Int)], _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = self.player else { return }
        guard let game = self.game.value else { return }
        try realm.write({
            if game.player1?._id == player._id {
                try game.player1Board?.setShip(coordinates)
            } else {
                try game.player2Board?.setShip(coordinates)
            }
        })
    }
    
    @MainActor
    func setReady(_ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = self.player else { return }
        guard let game = self.game.value else { return }
        try realm.write({
            if game.player1?._id == player._id {
                game.player1Ready = true
                if game.player2Ready {
                    game.state = .play
                }
            } else {
                game.player2Ready = true
                if game.player1Ready {
                    game.state = .play
                }
            }
        })
    }
    
    
    @MainActor
    func attack(_ point: (x: Int, y: Int), _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = self.player else { return }
        guard let game = self.game.value else { return }
        try realm.write({
            if game.player1?._id == player._id {
                let result = game.player2Board?.recieveAttack(point.x, point.y)
                if result == .destroyed {
                    game.current = game.player1
                } else {
                    game.current = game.player2
                }
                guard let lost = game.player2Board?.isLost() else { return }
                if lost {
                    game.winner = game.player1
                    game.loser = game.player2
                    game.state = .end
                    game.winner?.rating += game.bet
                    game.loser?.rating -= game.bet
                }
            } else {
                let result = game.player1Board?.recieveAttack(point.x, point.y)
                if result == .destroyed {
                    game.current = game.player2
                } else {
                    game.current = game.player1
                }
                guard let lost = game.player1Board?.isLost() else { return }
                if lost {
                    game.winner = game.player2
                    game.loser = game.player1
                    game.state = .end
                    game.winner?.rating += game.bet
                    game.loser?.rating -= game.bet
                }
            }
        })
    }
    
    @MainActor
    func dropGame(_ game: Game, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        try realm.write({
            realm.delete(game)
        })
    }
    
    @MainActor
    func resign(_ game: Game, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = self.player else { return }
        try realm.write({
            if game.player1?._id == player._id {
                game.winner = game.player2
                game.loser = game.player1
                game.state = .end
                game.winner?.rating += game.bet
                game.loser?.rating -= game.bet
            } else {
                game.winner = game.player1
                game.loser = game.player2
                game.state = .end
                game.winner?.rating += game.bet
                game.loser?.rating -= game.bet
            }
        })
    }
    
    
}
