import Foundation


class Observable<T> {
    
    typealias Listener = (_ value: T) -> Void
    
    var value: T{
        didSet {
            for listener in self.listeners {
                listener(value)
            }
        }
    }
    
    init(value: T) {
        self.value = value
    }
    
    private var listeners: [Listener] = []
    
    func bind(_ listener: @escaping Listener) {
        self.listeners.append(listener)
        listener(self.value)
    }
    
}
