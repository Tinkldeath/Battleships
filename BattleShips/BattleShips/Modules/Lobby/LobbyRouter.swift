import Foundation


final class LobbyRouter {
    
    func configure(_ view: LobbyViewController?) {
        let interactor = LobbyInteractor()
        let presenter = LobbyPresenter(view, interactor)
        interactor.presenter = presenter
        view?.presenter = presenter
    }
    
    func routeToLogin(_ view: LobbyViewController?) {
        view?.navigationController?.popViewController(animated: true)
    }
    
    func routeToGame(_ view: LobbyViewController?) {
        if let vc = view?.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
            view?.presenter?.interactor?.sleep()
            view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func routeToProfile(_ view: LobbyViewController?) {
        if let vc = view?.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
