import Foundation
import RealmSwift


class Point: EmbeddedObject {
    
    enum PointState: String, PersistableEnum {
        case empty = "Empty"
        case ship = "Ship"
        case destroyed = "Destroyed"
        case missed = "Missed"
    }
    
    @Persisted var x: Int
    @Persisted var y: Int
    @Persisted var state: PointState
    
    convenience init(_ x: Int, _ y: Int, _ state: PointState) {
        self.init()
        self.x = x
        self.y = y
        self.state = state
    }
}
