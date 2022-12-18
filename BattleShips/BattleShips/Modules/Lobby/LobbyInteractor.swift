import Foundation


final class LobbyInteractor {
    
    private let loginManager = LoginManager.shared
    private let playerWorker = PlayerWorker()
    private let lobbyWorker = LobbyWorker()
    private var challengeWorker: ChallengeWorker?
    private var gameWorker: GameWorker?
    
    var presenter: LobbyPresenter?
    
    @MainActor
    func initialize() async {
        do {
            let player = try await playerWorker.instantiatePlayer(self.loginManager.login, self.loginManager.password)
            self.challengeWorker = ChallengeWorker(player)
            self.gameWorker = GameWorker(player)
            try await self.fetch()
        } catch {
            print(String(describing: error))
        }
    }
    
    func logout() {
        Task { [weak self] in
            do {
                let player = try await playerWorker.instantiatePlayer(self?.loginManager.login ?? "", self?.loginManager.password ?? "")
                try await self?.playerWorker.logout(player, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func sleep() {
        self.gameWorker = nil
        self.challengeWorker = nil
    }
    
    func challengePlayerAction(_ id: String) {
        Task { [weak self] in
            do {
                try await self?.challengeWorker?.sendChallenge(id, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func acceptChallengeAction(_ id: String) {
        Task { [weak self] in
            do {
                try await self?.challengeWorker?.acceptChallenge(id, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func denyChallengeAction(_ id: String) {
        Task { [weak self] in
            do {
                try await self?.challengeWorker?.denyChallenge(id, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    private func setBindings() {
        self.lobbyWorker.players.bind { [weak self] players in
            self?.presenter?.presentOnlinePlayers(players)
        }
        self.challengeWorker?.challenge.bind({ [weak self] challenge in
            self?.presenter?.presentChallenge(challenge)
        })
        self.gameWorker?.game.bind({ [weak self] game in
            if let _ = game {
                self?.presenter?.presentGame()
                self?.presenter = nil
            }
        })
    }
    
    @MainActor
    private func fetch() async throws {
        try await self.gameWorker?.instantiateGame(self.loginManager.login, self.loginManager.password)
        try await self.challengeWorker?.instantiateChallenge(self.loginManager.login, self.loginManager.password)
        try await self.lobbyWorker.instantiatePlayers(self.loginManager.login, self.loginManager.password)
        self.setBindings()
    }
    
}
