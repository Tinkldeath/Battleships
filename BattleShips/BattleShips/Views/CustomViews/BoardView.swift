import UIKit


class BoardView: UIView {
    
    enum BoardViewMode {
        case displayPlayer, displayEnemy
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var pointsStack: UIStackView?
    @IBOutlet var pointButtons: [UIButton]!
    
    private var hideShips: Bool = false
    private var hideControlButtons: Bool = false
    private(set) var mode: BoardViewMode = .displayPlayer
    var delegate: BoardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("BoardView", owner: self)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        for button in self.pointButtons {
            button.addAction(UIAction(handler: { [weak self] _ in
                if let index = self?.pointButtons.firstIndex(where: { $0 === button }) {
                    if button.configuration?.baseBackgroundColor != UIColor.red {
                        self?.selectPointAction(index % 10, index / 10)
                    }
                }
            }), for: .touchDown)
        }
    }

    func selectPointAction(_ x: Int, _ y: Int) {
        self.delegate?.didSelectPoint(self, (x, y))
    }
    
    func setMode(_ mode: BoardViewMode) {
        self.mode = mode
        switch mode {
        case .displayPlayer:
            self.hideShips = false
        case .displayEnemy:
            self.hideShips = true
        }
    }
    
    func displayPoints(_ points: [Point]) {
        for point in points {
            let pointer = (point.y*10) + point.x
            self.pointButtons[pointer].isEnabled = true
            switch point.state {
                case .empty:
                    self.pointButtons[pointer].configuration?.baseBackgroundColor = UIColor.blue
                case .ship:
                    let color = self.hideShips == true ? UIColor.blue : UIColor.darkGray
                    self.pointButtons[pointer].configuration?.baseBackgroundColor = color
                case .destroyed:
                    self.pointButtons[pointer].configuration?.baseBackgroundColor = UIColor.red
                case .missed:
                    self.pointButtons[pointer].isEnabled = false
            }
        }
    }

}


protocol BoardViewDelegate {
    func didSelectPoint(_ view: BoardView, _ point: (x: Int, y: Int))
}
