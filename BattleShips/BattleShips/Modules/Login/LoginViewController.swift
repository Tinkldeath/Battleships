import UIKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    
    private var router: LoginRouter = LoginRouter()
    var presenter: LoginPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.router.configure(self)
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        self.presenter?.interactor?.loginAction(self.loginTextField?.text ?? "", self.passwordTextField?.text ?? "")
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.presenter?.interactor?.signUpAction(self.loginTextField?.text ?? "", self.passwordTextField?.text ?? "")
    }
    
    func displayError(_ error: Error) {
        Task { [weak self] in
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    func displaySuccess() {
        Task { [weak self] in
            let ac = UIAlertController(title: "Successfully logged in", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self?.router.routeToLobby(self)
            }))
            self?.present(ac, animated: true)
        }
    }
    
}
