import UIKit

class HomeView: UIView, UIScrollViewDelegate {
    private var homeViewModel: HomeViewModel
    private var homeModel: HomeModel
    
    init(homeViewModel: HomeViewModel, homeModel: HomeModel) {
        self.homeModel = homeModel
        self.homeViewModel = homeViewModel
        super.init(frame: .zero)
        
        setupView()
        
        // Notifica a view quando as notícias forem atualizadas / [weak self] evita ciclo de retenção. só tenta chamar updateUI() se self  (a HomeView ) ainda estiver na memória.
        homeViewModel.didUpdateNews = { [weak self] in
            self?.updateUI()
        }
        
        homeViewModel.didFailToLoadNews = { [weak self] errorMessage in
            self?.showErrorBanner(message: errorMessage)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let title: UILabel = {
        let label = UILabel()
        label.text = "News App"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        
        return scrollView
        
    }()
    
    private let newStackView: UIStackView = {
      let  newStackView = UIStackView()
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        newStackView.axis = .vertical
        newStackView.spacing = 10
        
        return newStackView
        
    }()
    
    
    private func setupView() {
        homeViewModel.loadNews()
        
        addSubview(title)
        addSubview(scrollView)
        scrollView.delegate = self

        scrollView.addSubview(newStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            scrollView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            newStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 5),
            newStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -5),
            newStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            newStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            newStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -10),
            
        ])
    }
    
    // Atualiza a UI com as novas notícias
    private func updateUI() {
        
        for new in homeModel.news {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .lightGray
            container.layer.cornerRadius = 7
            
            let titleLabel = UILabel()
            titleLabel.text = new.title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = .black
            
            container.addSubview(titleLabel)
            newStackView.addArrangedSubview(container)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
                
                container.leadingAnchor.constraint(equalTo: newStackView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: newStackView.trailingAnchor)
            ])
        }
    }
    
    private func showErrorBanner(message: String) {
        // Cria a view do banner
        let banner = UIView()
        banner.backgroundColor = .red
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        banner.addSubview(messageLabel)
        
        // Adiciona o banner à view principal
        if let topController = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = topController.windows.first(where: { $0.isKeyWindow }) {
            
            window.addSubview(banner)
            
            // Constraints do banner
            NSLayoutConstraint.activate([
                banner.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor),
                banner.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                banner.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                banner.heightAnchor.constraint(equalToConstant: 50),
                
                messageLabel.topAnchor.constraint(equalTo: banner.topAnchor),
                messageLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -10)
            ])
            
            // Animação para mostrar o banner vindo de baixo
            banner.transform = CGAffineTransform(translationX: 0, y: -50)  // Começa abaixo da tela
            UIView.animate(withDuration: 0.5) {
                banner.transform = .identity  // Desliza para cima até sua posição original
            }
            
            // Remove o banner após 3 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    banner.transform = CGAffineTransform(translationX: 0, y: 50)  // Desliza para baixo
                }) { _ in
                    banner.removeFromSuperview()  // Remove o banner da hierarquia da view
                }
            }
        }
    }




    // Detecta quando o usuário atinge o final da lista
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height * 2 {
            let currentIndex = homeModel.news.count - 1
            homeViewModel.loadMoreNewsIfNeeded(at: currentIndex)
        }
    }
}
