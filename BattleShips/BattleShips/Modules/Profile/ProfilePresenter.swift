import Foundation


final class ProfilePresenter {
    
    private(set) var interactor: ProfileInteractor?
    private var view: ProfileViewController?
    
    init(_ interactor: ProfileInteractor? = nil, _ view: ProfileViewController? = nil) {
        self.interactor = interactor
        self.view = view
    }
    
    func presentPlayer(_ player: Player?) {
        guard let player = player else { return }
        self.view?.displayProfile(player.nickname, player.rating)
    }
    
}
