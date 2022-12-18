import Foundation


final class LoginInteractor {
    
    private var realmDb: RealmDB = RealmDB.shared
    private var loginManager: LoginManager = LoginManager.shared
    
    weak var presenter: LoginPresenter?
    
    func loginAction(_ login: String, _ password: String) {
        Task { [weak self] in
            do {
                let _ = try await self?.realmDb.getUser(login, password)
                self?.presenter?.presentLogin(LoginEntity(login: login, password: password, success: true, error: nil))
                self?.loginManager.setValues(login, password)
            } catch {
                self?.presenter?.presentLogin(LoginEntity(login: login, password: password, success: false, error: error))
            }
        }
    }
    
    func signUpAction(_ login: String, _ password: String) {
        Task { [weak self] in
            do {
                try await self?.realmDb.registerUser(login, password)
                self?.presenter?.presentSignUp(LoginEntity(login: login, password: password, success: true, error: nil))
                self?.loginManager.setValues(login, password)
            } catch {
                self?.presenter?.presentSignUp(LoginEntity(login: login, password: password, success: false, error: error))
            }
        }
    }
    
}
