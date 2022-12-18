import Foundation
import RealmSwift


enum Ship: Int {
    case fourdeck = 4
    case threedeck = 3
    case twodeck = 2
    case onedeck = 1
}

struct InvalidException: Error {
    var description: String
}

class Board: EmbeddedObject {
    
    @Persisted var owner: Player?
    @Persisted var points: List<Point>
    
    var pointsStack: [(x: Int, y: Int)] = []
    var shipsStack: [Int] = []
    
    var availableShips: [Ship: Int] = [
        .onedeck: 4,
        .twodeck: 3,
        .threedeck: 2,
        .fourdeck: 1
    ]
    
    convenience init(_ owner: Player?) {
        self.init()
        self.owner = owner
        self.points = List<Point>()
        for i in 0..<10 {
            for j in 0..<10 {
                self.points.append(Point(i, j, .empty))
            }
        }
    }
    
    func recieveAttack(_ x: Int, _ y: Int) -> Point.PointState {
        if let index = self.points.firstIndex(where: { $0.x == x && $0.y == y }) {
            if self.points[index].state == .ship {
                self.points[index].state = .destroyed
                return .destroyed
            } else {
                self.points[index].state = .missed
            }
        }
        return .missed
    }
    
    func setShip(_ points: [(x: Int, y: Int)]) throws {
        for i in 0..<points.count-1 {
            if abs(points[i].x - points[i+1].x) > 1 || abs(points[i].y - points[i+1].y) > 1 {
                throw InvalidException(description: "Invalid coordinates")
            }
        }
        if !self.checkAvailableShip(points.count) {
            throw InvalidException(description: "Too much ships")
        }
        for point in points {
            if !self.validPoint((point.x, point.y)) {
                throw InvalidException(description: "Invalid point")
            }
        }
        for point in points {
            if let index = self.points.firstIndex(where: { $0.x == point.x && $0.y == point.y }) {
                self.points[index].state = .ship
                self.pointsStack.append(point)
            }
        }
        self.shipsStack.append(points.count)
        self.updateSetShip(points.count)
    }
    
    func undo() {
        guard let ship = self.shipsStack.first else { return }
        for _ in 0..<ship {
            guard let point = self.pointsStack.last else { return }
            if let index = self.points.firstIndex(where: { $0.x == point.x && $0.y == point.y }) {
                self.points[index].state = .empty
                self.pointsStack = self.pointsStack.dropLast()
            }
        }
        self.updateUndoShip(ship)
    }
    
    func isSet() -> Bool {
        guard self.availableShips[.onedeck] == 0 else { return false }
        guard self.availableShips[.twodeck] == 0 else { return false }
        guard self.availableShips[.threedeck] == 0 else { return false }
        guard self.availableShips[.fourdeck] == 0 else { return false }
        return true
    }
    
    func isLost() -> Bool {
        for point in self.points {
            if point.state == .ship {
                return false
            }
        }
        return true
    }
    
    private func validPoint(_ point: (x: Int, y: Int)) -> Bool {
        let left = point.x - 1
        let right = point.x + 1
        let top = point.y - 1
        let bot = point.y + 1
        if left >= 0 && left <= 9 {
            if self.points.first(where: { $0.x == left && $0.y == point.y })?.state != .empty {
                return false
            }
            if top >= 0 && top <= 9 {
                if self.points.first(where: { $0.x == point.x && $0.y == top })?.state != .empty {
                    return false
                }
                if self.points.first(where: { $0.x == left && $0.y == top })?.state != .empty {
                    return false
                }
            }
            if bot >= 0 && bot <= 9 {
                if self.points.first(where: { $0.x == point.x && $0.y == bot })?.state != .empty {
                    return false
                }
                if self.points.first(where: { $0.x == left && $0.y == bot })?.state != .empty {
                    return false
                }
            }
        }
        if right >= 0 && right <= 9 {
            if self.points.first(where: { $0.x == right && $0.y == point.y })?.state != .empty {
                return false
            }
            if top >= 0 && top <= 9 {
                if self.points.first(where: { $0.x == point.x && $0.y == top })?.state != .empty {
                    return false
                }
                if self.points.first(where: { $0.x == right && $0.y == top })?.state != .empty {
                    return false
                }
            }
            if bot >= 0 && bot <= 9 {
                if self.points.first(where: { $0.x == point.x && $0.y == bot })?.state != .empty {
                    return false
                }
                if self.points.first(where: { $0.x == right && $0.y == bot })?.state != .empty {
                    return false
                }
            }
        }
        return true
    }
    
    private func checkAvailableShip(_ count: Int) -> Bool {
        switch count {
            case 1:
                let available = self.availableShips[.onedeck]! > 0 ? true : false
                return available
            case 2:
                let available = self.availableShips[.twodeck]! > 0 ? true : false
                return available
            case 3:
                let available = self.availableShips[.threedeck]! > 0 ? true : false
                return available
            case 4:
                let available = self.availableShips[.fourdeck]! > 0 ? true : false
                return available
            default:
                return false
        }
    }
    
    private func updateSetShip(_ count: Int) {
        switch count {
            case 1:
                self.availableShips.updateValue(self.availableShips[.onedeck]! - 1, forKey: .onedeck)
            case 2:
                self.availableShips.updateValue(self.availableShips[.twodeck]! - 1, forKey: .twodeck)
            case 3:
                self.availableShips.updateValue(self.availableShips[.threedeck]! - 1, forKey: .threedeck)
            case 4:
                self.availableShips.updateValue(self.availableShips[.fourdeck]! - 1, forKey: .fourdeck)
            default:
                return
        }
    }
    
    private func updateUndoShip(_ count: Int) {
        switch count {
            case 1:
                self.availableShips.updateValue(self.availableShips[.onedeck]! + 1, forKey: .onedeck)
            case 2:
                self.availableShips.updateValue(self.availableShips[.twodeck]! + 1, forKey: .twodeck)
            case 3:
                self.availableShips.updateValue(self.availableShips[.threedeck]! + 1, forKey: .threedeck)
            case 4:
                self.availableShips.updateValue(self.availableShips[.fourdeck]! + 1, forKey: .fourdeck)
            default:
                return
        }
    }
    
}
