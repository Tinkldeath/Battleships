import Foundation
import RealmSwift


class Challenge: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var sender: Player?
    @Persisted var reciever: Player?
    @Persisted var bet: Int
    
    convenience init(_ sender: Player?, _ reciever: Player?) {
        self.init()
        self.sender = sender
        self.reciever = reciever
        self.bet = Int.random(in: 25...50)
    }
    
}
