import Foundation


final class LoginPresenter {
    
    private(set) var interactor: LoginInteractor?
    private weak var view: LoginViewController?
    
    init(_ interactor: LoginInteractor?, _ view: LoginViewController?) {
        self.interactor = interactor
        self.view = view
    }
    
    func presentLogin(_ loginEntity: LoginEntity) {
        if loginEntity.success {
            self.view?.displaySuccess()
        }
        if let error = loginEntity.error {
            self.view?.displayError(error)
        }
    }
    
    func presentSignUp(_ loginEntity: LoginEntity) {
        if loginEntity.success {
            self.view?.displaySuccess()
        }
        if let error = loginEntity.error {
            self.view?.displayError(error)
        }
    }
    
}
