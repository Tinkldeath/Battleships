import Foundation


final class LoginManager {
    
    private static var _instance = LoginManager()
    public static var shared = {
       return _instance
    }()
    private init() {}
    
    private(set) var login: String = ""
    private(set) var password: String = ""
    
    func setValues(_ login: String, _ password: String) {
        self.login = login
        self.password = password
    }
    
}
