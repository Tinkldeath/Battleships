import Foundation


final class ProfileRouter {
    
    func configure(_ view: ProfileViewController?) {
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter(interactor, view)
        interactor.presenter = presenter
        view?.presenter = presenter
        interactor.initialize()
    }
    
    func routeToLobby(_ view: ProfileViewController?) {
        view?.navigationController?.popViewController(animated: true)
    }
    
    func routeToLogin(_ view: ProfileViewController?) {
        view?.navigationController?.popToRootViewController(animated: true)
    }
    
}
