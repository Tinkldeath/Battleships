import Foundation
import RealmSwift


class Player: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var ownerId: String
    @Persisted var nickname: String
    @Persisted var rating: Int
    @Persisted var online: Bool
    
    convenience init(_ ownerId: String, _ nickname: String) {
        self.init()
        self.ownerId = ownerId
        self.nickname = nickname
        self.rating = 5000
        self.online = true
    }
    
}
