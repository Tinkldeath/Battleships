import Foundation


final class LobbyPresenter {
    
    private var view: LobbyViewController?
    private(set) var interactor: LobbyInteractor?
    
    init(_ view: LobbyViewController?, _ interactor: LobbyInteractor?) {
        self.view = view
        self.interactor = interactor
    }
    
    func presentOnlinePlayers(_ players: [Player]) {
        let list = players.map { value in
            return LobbyPlayer(id: value._id.stringValue, nickname: value.nickname, rating: value.rating)
        }
        self.view?.displayPlayers(list)
    }
    
    func presentChallenge(_ challenge: Challenge?) {
        if let challenge = challenge {
            self.view?.displayChallenge(LobbyChallenge(id: challenge._id.stringValue, sender: challenge.sender?.nickname ?? "Unknown", bet: challenge.bet))
        }
    }
    
    func presentGame() {
        self.view?.displayGame()
    }
    
}
