import UIKit


class GameViewController: UIViewController {
    
    @IBOutlet weak var opponentView: BoardView?
    @IBOutlet weak var playerView: BoardView?
    @IBOutlet weak var moveLabel: UILabel?
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var enemyReadyLabel: UILabel?
    @IBOutlet weak var readyButton: UIButton?
    
    private var router = GameRouter()
    var coordinates = [(x: Int, y: Int)]()
    var presenter: GamePresenter?
    var state: Game.GameState = .prepare
    var selectedShip: Ship?
    var count = 0
    var waitAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatior?.startAnimating()
        self.timeLabel?.isHidden = true
        self.playerView?.setMode(.displayPlayer)
        self.opponentView?.setMode(.displayEnemy)
        self.playerView?.delegate = self
        self.opponentView?.delegate = self
        self.router.configure(self)
    }
    
    @IBAction func resignClicked(_ sender: Any) {
        let ac = UIAlertController(title: "Are you shure want to resign?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.presenter?.interactor?.resignAction()
        }))
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(ac, animated: true)
    }
    
    
    @IBAction func readyClicked(_ sender: UIButton) {
        self.presenter?.interactor?.readyAction()
    }
    
    @IBAction func shipClicked(_ sender: Any) {
        guard let ships = self.presenter?.interactor?.availableShips() else { return }
        let ac = UIAlertController(title: "Select ship", message: nil, preferredStyle: .alert)
        for key in ships.keys {
            if ships[key]! <= 0 {
                continue
            }
            switch key {
            case .fourdeck:
                ac.addAction(UIAlertAction(title: "Fourdeck (\(ships[key]!))", style: .default, handler: { [weak self] _ in
                    self?.count = 0
                    self?.selectedShip = .fourdeck
                }))
            case .threedeck:
                ac.addAction(UIAlertAction(title: "Threedeck (\(ships[key]!))", style: .default, handler: { [weak self] _ in
                    self?.count = 0
                    self?.selectedShip = .threedeck
                }))
            case .twodeck:
                ac.addAction(UIAlertAction(title: "Twodeck (\(ships[key]!))", style: .default, handler: { [weak self] _ in
                    self?.count = 0
                    self?.selectedShip = .twodeck
                }))
            case .onedeck:
                ac.addAction(UIAlertAction(title: "Onedeck (\(ships[key]!))", style: .default, handler: { [weak self] _ in
                    self?.count = 0
                    self?.selectedShip = .onedeck
                }))
            }
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.selectedShip = nil
            self?.count = 0
        }))
        self.present(ac, animated: true)
    }
    
}

extension GameViewController {
    
    func displayEnemyMove(_ state: Game.GameState) {
        switch state {
        case .prepare:
            self.title = state.rawValue
            self.moveLabel?.text = "Set up your ships"
            self.activityIndicatior?.isHidden = true
            self.timeLabel?.isHidden = false
        case .play:
            self.waitAlert?.dismiss(animated: true)
            self.title = state.rawValue
            self.moveLabel?.isHidden = true
            self.activityIndicatior?.isHidden = true
            self.timeLabel?.isHidden = true
            let ac = UIAlertController(title: "Waiting for opponent...", message: nil, preferredStyle: .alert)
            self.waitAlert = ac
            self.present(ac, animated: true)
        case .end:
            self.waitAlert?.dismiss(animated: true)
            self.title = state.rawValue
            self.moveLabel?.text = "Game is over"
            self.activityIndicatior?.isHidden = true
            self.timeLabel?.isHidden = true
        }
        self.state = state
    }
    
    func displayPlayerMove(_ state: Game.GameState) {
        switch state {
        case .prepare:
            self.title = state.rawValue
            self.moveLabel?.text = "Set up your ships"
            self.activityIndicatior?.isHidden = true
            self.timeLabel?.isHidden = false
        case .play:
            self.title = state.rawValue
            self.waitAlert?.dismiss(animated: true)
            self.moveLabel?.isHidden = false
            self.moveLabel?.text = "Select cell to attack"
            self.timeLabel?.isHidden = false
        case .end:
            self.waitAlert?.dismiss(animated: true)
            self.title = state.rawValue
            self.moveLabel?.text = "Game is over"
            self.activityIndicatior?.isHidden = true
            self.timeLabel?.isHidden = true
        }
        self.state = state
    }
    
    func displayPlayerBoard(_ points: [Point]) {
        self.playerView?.displayPoints(points)
    }
    
    func displayEnemyBoard(_ points: [Point]) {
        self.opponentView?.displayPoints(points)
    }
    
    func displayEnemyReady(_ ready: Bool) {
        let text = ready == true ? "ready" : "not ready"
        self.enemyReadyLabel?.text = "Opponent: \(text)"
    }
    
    func displayReady() {
        self.readyButton?.isEnabled = false
    }
    
    func displayNotReady() {
        let ac = UIAlertController(title: "Set all ships!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    func displayWin(_ bet: Int) {
        let ac = UIAlertController(title: "You won!", message: "Your rating is up to +\(bet)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.router.routeToLobby(self)
        }))
        self.present(ac, animated: true)
    }
    
    func displayLose(_ bet: Int) {
        let ac = UIAlertController(title: "You lose!", message: "Your rating is down to -\(bet)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.router.routeToLobby(self)
        }))
        self.present(ac, animated: true)
    }
    
}


extension GameViewController: BoardViewDelegate {
    
    func didSelectPoint(_ view: BoardView, _ point: (x: Int, y: Int)) {
        if view.mode == .displayEnemy && self.state == .play {
            self.presenter?.interactor?.attackAction(point)
        }
        if view.mode == .displayPlayer && self.selectedShip != nil {
            if count + 1 == self.selectedShip?.rawValue {
                self.coordinates.append(point)
                self.presenter?.interactor?.setShipAction(self.coordinates)
                self.count = 0
                self.selectedShip = nil
                self.coordinates.removeAll()
            } else {
                self.coordinates.append(point)
                self.count += 1
            }
        }
    }
    
}
