import Foundation


final class ProfileInteractor {
    
    private let loginManager = LoginManager.shared
    private let playerWorker = PlayerWorker()
    var presenter: ProfilePresenter?
    
    func initialize() {
        Task { [weak self] in
            do {
                let _ = try await self?.playerWorker.instantiatePlayer(self?.loginManager.login ?? "", self?.loginManager.password ?? "")
                self?.setBindings()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func changeNicknameAction(_ nickname: String) {
        if nickname.isEmpty { return }
        Task { [weak self] in
            do {
                try await self?.playerWorker.updateNickname(nickname, self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func deletePlayerAction() {
        Task { [weak self] in
            do {
                try await self?.playerWorker.deleteProfile(self?.loginManager.login ?? "", self?.loginManager.password ?? "")
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    private func setBindings() {
        self.playerWorker.player.bind({ [weak self] value in
            self?.presenter?.presentPlayer(value)
        })
    }
    
}
