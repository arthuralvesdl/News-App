import Foundation

// Modelo para as notícias
struct New: Decodable {
    let id: String
    let title: String
}

// Modelos auxiliares para decodificação da resposta da API
struct NewsAPIResponse: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let source: Source
    let title: String
}

struct Source: Decodable {
    let id: String?
}

// ViewModel para gerenciar as notícias
class HomeViewModel {
    
    private let apiKey = "36ed76aa755b404abe5b5b7cb6192820"
    private let baseUrl = "https://newsapi.org/v2/top-headlines"
    
    private var currentPage: Int
    public var isLoading: Bool
    private var homeModel: HomeModel
    
    init(currentPage: Int = 1, isLoading: Bool = false, homeModel: HomeModel, didUpdateNews: ( () -> Void)? = nil) {
        self.currentPage = currentPage
        self.isLoading = isLoading
        self.homeModel = homeModel
        self.didUpdateNews = didUpdateNews
    }
    
    // Closure para notificar a View sobre as atualizações
    public var didUpdateNews: (() -> Void)?
    
    public var didFailToLoadNews: ((_: String)-> Void)?
    
    func loadNews() {
        guard !isLoading else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard let url = URL(string: "\(baseUrl)?apiKey=\(apiKey)&country=us&page=\(currentPage)") else { return }
        
        // delay antes de fazer a requisição
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //evita ciclo de retenção
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self, let data = data, error == nil else {
                    self?.isLoading = false
                    DispatchQueue.main.async {
                        self?.didFailToLoadNews?(error?.localizedDescription ?? "Unknown error")
                    }
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                    let newNews = response.articles.map { New(id: $0.source.id ?? UUID().uuidString, title: $0.title) }
                    
                    // Atualiza as notícias e incrementa a página
                    homeModel.news.append(contentsOf: newNews)
                    self.currentPage += 1
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.didUpdateNews?()  // Notifica a View que os dados foram atualizados
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.didFailToLoadNews?(error.localizedDescription)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    // Função para carregar mais notícias quando o usuário atingir o final da lista
    public func loadMoreNewsIfNeeded(at index: Int) {
        if index == homeModel.news.count - 1 {  // Se o item atual for o último
            loadNews()
        }
    }

}
