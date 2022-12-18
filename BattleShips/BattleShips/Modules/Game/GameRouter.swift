import Foundation


final class GameRouter {
    
    func configure(_ view: GameViewController?) {
        let interactor = GameInteractor()
        let presenter = GamePresenter(interactor, view)
        interactor.presenter = presenter
        view?.presenter = presenter
        Task {
            await interactor.initialize()
        }
    }
    
    func routeToLobby(_ view: GameViewController?) {
        view?.navigationController?.popViewController(animated: true)
    }
    
}
