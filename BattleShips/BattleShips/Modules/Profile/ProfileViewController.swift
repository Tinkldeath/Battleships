import UIKit


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nicknameLabel: UILabel?
    @IBOutlet weak var ratingLabel: UILabel?
    @IBOutlet weak var tierButton: UIButton?
    @IBOutlet weak var onlineButton: UIButton?
    @IBOutlet weak var deleteProfileButton: UIButton?
    
    
    private var router = ProfileRouter()
    var activityIndicator: UIActivityIndicatorView?
    var presenter: ProfilePresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nicknameLabel?.isHidden = true
        self.ratingLabel?.isHidden = true
        self.tierButton?.isHidden = true
        self.onlineButton?.isHidden = true
        self.deleteProfileButton?.isHidden = true
        let activity = UIActivityIndicatorView(style: .medium)
        self.view.addSubview(activity)
        activity.center = self.view.center
        activity.startAnimating()
        self.activityIndicator = activity
        self.router.configure(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.router.configure(self)
    }
    
    @IBAction func editClicked(_ sender: Any) {
        let ac = UIAlertController(title: "Enter new nickname:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
            let text = ac.textFields!.first!.text ?? ""
            self?.presenter?.interactor?.changeNicknameAction(text)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac, animated: true)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let ac = UIAlertController(title: "Are you shure?", message: "It will delete your account and player's profile", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.presenter?.interactor?.deletePlayerAction()
            self?.router.routeToLogin(self)
        }))
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(ac, animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.router.routeToLobby(self)
    }
    

}

extension ProfileViewController {
    
    func displayProfile(_ nickname: String, _ rating: Int) {
        self.nicknameLabel?.text = nickname
        self.ratingLabel?.text = "Rating: \(rating)"
        if rating < 2000 {
            self.tierButton?.configuration?.baseBackgroundColor = UIColor.brown
            let customButtonTitle = NSMutableAttributedString(string: "Bronze", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            ])
            self.tierButton?.setAttributedTitle(customButtonTitle, for: .normal)
        } else if rating < 3500 {
            self.tierButton?.configuration?.baseBackgroundColor = UIColor.lightGray
            let customButtonTitle = NSMutableAttributedString(string: "Silver", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            ])
            self.tierButton?.setAttributedTitle(customButtonTitle, for: .normal)
        } else if rating < 5500 {
            self.tierButton?.configuration?.baseBackgroundColor = UIColor.yellow
            let customButtonTitle = NSMutableAttributedString(string: "Gold", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            ])
            self.tierButton?.setAttributedTitle(customButtonTitle, for: .normal)
        } else {
            self.tierButton?.configuration?.baseBackgroundColor = UIColor.cyan
            self.tierButton?.setTitle("Daimond", for: .normal)
            let customButtonTitle = NSMutableAttributedString(string: "Daimond", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            ])
            self.tierButton?.setAttributedTitle(customButtonTitle, for: .normal)
        }
        self.nicknameLabel?.isHidden = false
        self.ratingLabel?.isHidden = false
        self.tierButton?.isHidden = false
        self.onlineButton?.isHidden = false
        self.deleteProfileButton?.isHidden = false
        self.activityIndicator?.removeFromSuperview()
    }
    
}
