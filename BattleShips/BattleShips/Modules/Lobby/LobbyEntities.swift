import Foundation
import RealmSwift


class LobbyWorker {
    
    private(set) var players: Observable<[Player]> = Observable<[Player]>(value: [])
    private var notificationToken: NotificationToken?
    
    @MainActor
    func instantiatePlayers(_ login: String, _ password: String) async throws {
        let user = try await RealmDB.shared.getUser(login, password)
        let realm = try await RealmDB.shared.getRealm(login, password)
        self.notificationToken = realm.objects(Player.self).observe(keyPaths: []) { [weak self] _ in
            let players = realm.objects(Player.self).filter({ $0.online == true && $0.ownerId != user.id })
            self?.players.value = players.map({ $0 })
        }
    }
    
}

class ChallengeWorker {
    
    private(set) var challenge: Observable<Challenge?> = Observable<Challenge?>(value: nil)
    private var notificationToken: NotificationToken?
    private var player: Player?
    
    init(_ player: Player?) {
        self.player = player
    }
    
    @MainActor
    func instantiateChallenge(_ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        self.notificationToken = realm.objects(Challenge.self).observe(keyPaths: [], { [weak self] _ in
            self?.challenge.value = realm.objects(Challenge.self).first(where: { $0.reciever?._id == self?.player?._id })
        })
    }
    
    @MainActor
    func sendChallenge(_ id: String, _ login: String, _ password: String) async throws {
        let user = try await RealmDB.shared.getUser(login, password)
        let realm = try await RealmDB.shared.getRealm(login, password)
        try realm.write({
            guard let sender = realm.objects(Player.self).first(where: { $0.ownerId == user.id }) else { return }
            guard let reciever = realm.objects(Player.self).first(where: { $0._id.stringValue == id }) else { return }
            let challenge = Challenge(sender, reciever)
            realm.add(challenge)
        })
    }
    
    @MainActor
    func acceptChallenge(_ id: String, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        try realm.write({
            guard let challenge = realm.objects(Challenge.self).first(where: { $0._id.stringValue == id }) else { return }
            let game = Game(challenge.sender, challenge.reciever, challenge.bet)
            realm.delete(challenge)
            realm.add(game)
        })
    }
    
    @MainActor
    func denyChallenge(_ id: String, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        try realm.write({
            guard let challenge = realm.objects(Challenge.self).first(where: { $0._id.stringValue == id }) else { return }
            realm.delete(challenge)
        })
    }
    
}

