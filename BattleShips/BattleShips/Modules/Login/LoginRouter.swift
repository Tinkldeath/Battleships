import Foundation


final class LoginRouter {
    
    func routeToLobby(_ view: LoginViewController?) {
        if let vc = view?.storyboard?.instantiateViewController(withIdentifier: "LobbyViewController") as? LobbyViewController {
            view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func configure(_ view: LoginViewController?) {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter(interactor, view)
        interactor.presenter = presenter
        view?.presenter = presenter
    }
    
}
