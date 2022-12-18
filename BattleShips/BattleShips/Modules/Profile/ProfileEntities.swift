import Foundation
import RealmSwift


class PlayerWorker {
    
    private(set) var player: Observable<Player?> = Observable<Player?>(value: nil)
    private var notificationToken: NotificationToken?
    
    @MainActor
    func instantiatePlayer(_ login: String, _ password: String) async throws -> Player {
        let user = try await RealmDB.shared.getUser(login, password)
        let realm = try await RealmDB.shared.getRealm(login, password)
        if let player = realm.objects(Player.self).first(where: { $0.ownerId == user.id }) {
            try realm.write({
                player.online = true
            })
            self.notificationToken = player.observe({ [weak self] _ in
                self?.player.value = player
            })
            return player
        } else {
            let player = Player(user.id, login)
            try realm.write({
                player.online = true
                realm.add(player)
            })
            self.notificationToken = player.observe({ [weak self] _ in
                self?.player.value = player
            })
            return player
        }
    }
    
    @MainActor
    func logout(_ player: Player, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        try realm.write({
            player.online = false
        })
    }
    
    @MainActor
    func deleteProfile( _ login: String, _ password: String) async throws {
        let user = try await RealmDB.shared.getUser(login, password)
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = realm.objects(Player.self).first(where: { $0.ownerId == user.id } ) else {
            try await user.delete()
            return
        }
        try realm.write({
            realm.delete(player)
        })
        try await user.delete()
    }
    
    @MainActor
    func updateNickname(_ nickname: String, _ login: String, _ password: String) async throws {
        let realm = try await RealmDB.shared.getRealm(login, password)
        guard let player = self.player.value else { return }
        try realm.write({
            player.nickname = nickname
        })
    }
    
}
