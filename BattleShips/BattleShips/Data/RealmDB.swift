import Foundation
import RealmSwift


final class RealmDB {
    
    private static var _instance = RealmDB()
    public static var shared = {
       return _instance
    }()
    private init() {
        self.app = App(id: self.appId)
    }
    private let appId = "ships-wealn"
    private(set) var app: App
    
    @MainActor
    func getRealm(_ login: String, _ password: String) async throws -> Realm {
        let user = try await getUser(login, password)
        let configuration = user.flexibleSyncConfiguration (initialSubscriptions: { subs in
            if subs.first(named: "Players") == nil {
                subs.append(QuerySubscription<Player>(name: "Players"))
            }
            if subs.first(named: "Games") == nil {
                subs.append(QuerySubscription<Game>(name: "Games"))
            }
            if subs.first(named: "Challenges") == nil {
                subs.append(QuerySubscription<Challenge>(name: "Challenges"))
            }
        }, rerunOnOpen: true)
        let realm = try await Realm(configuration: configuration, downloadBeforeOpen: .always)
        return realm
    }
    
    @MainActor
    func getUser(_ login: String, _ password: String) async throws -> User {
        let app = App(id: self.appId)
        let loggedInUser = try await app.login(credentials: Credentials.emailPassword(email: login, password: password))
        return loggedInUser
    }
    
    @MainActor
    func registerUser(_ login: String, _ password: String) async throws {
        let app = App(id: self.appId)
        let auth = app.emailPasswordAuth
        try await auth.registerUser(email: login, password: password)
    }
    
}
