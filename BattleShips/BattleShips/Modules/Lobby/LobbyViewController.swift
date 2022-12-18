import UIKit


struct LobbyPlayer {
    var id: String
    var nickname: String
    var rating: Int
}

struct LobbyChallenge {
    var id: String
    var sender: String
    var bet: Int
}

class PlayerCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var playerLabel: UILabel?
    @IBOutlet weak var challengeButton: UIButton?
    private var player: LobbyPlayer?
    private var view: LobbyViewController?
    
    func setup(_ player: LobbyPlayer?, _ view: LobbyViewController?) {
        guard let player = player else { return }
        self.player = player
        self.view = view
        self.playerLabel?.text = "\(player.nickname) (\(player.rating))"
        self.challengeButton?.isEnabled = true
    }
    
    @IBAction func challengeClicked(_ sender: Any) {
        self.view?.challengeClicked(self.player)
        self.challengeButton?.isEnabled = false
    }
    
}

class LobbyViewController: UIViewController {
    
    @IBOutlet weak var playersTable: UITableView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var players = [LobbyPlayer]()
    private var router = LobbyRouter()
    
    var presenter: LobbyPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.playersTable?.dataSource = self
        self.playersTable?.rowHeight = 62;
        let activity = UIActivityIndicatorView(style: .medium)
        self.view.addSubview(activity)
        self.activityIndicator = activity
        self.activityIndicator?.center = self.view.center
        self.activityIndicator?.startAnimating()
        self.router.configure(self)
        Task { [weak self] in
            await self?.presenter?.interactor?.initialize()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.router.configure(self)
        Task { [weak self] in
            await self?.presenter?.interactor?.initialize()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter?.interactor?.sleep()
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.presenter?.interactor?.logout()
        self.router.routeToLogin(self)
    }
    
    @IBAction func profileClicked(_ sender: Any) {
        self.router.routeToProfile(self)
    }
    
    
}

extension LobbyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerCell
        cell.setup(self.players[indexPath.row], self)
        return cell
    }
    
}

extension LobbyViewController {
    
    func displayPlayers(_ players: [LobbyPlayer]) {
        Task { [weak self] in
            self?.activityIndicator?.removeFromSuperview()
            self?.players = players
            self?.playersTable?.reloadData()
        }
    }
    
    func displayChallenge(_ challenge: LobbyChallenge) {
        let ac = UIAlertController(title: "New challenge", message: "From \(challenge.sender) (+\(challenge.bet))", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            self?.presenter?.interactor?.acceptChallengeAction(challenge.id)
        }))
        ac.addAction(UIAlertAction(title: "Deny", style: .cancel, handler: { [weak self] _ in
            self?.presenter?.interactor?.denyChallengeAction(challenge.id)
        }))
        self.present(ac, animated: true)
    }
    
    func challengeClicked(_ player: LobbyPlayer?) {
        guard let player = player else { return }
        self.presenter?.interactor?.challengePlayerAction(player.id)
    }
    
    func displayGame() {
        self.presenter?.interactor?.sleep()
        self.router.routeToGame(self)
    }
    
}
