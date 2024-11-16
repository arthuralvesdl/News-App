import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeModel = HomeModel()
        let homeViewModel = HomeViewModel(homeModel:homeModel)
        
        
        let contentView = HomeView(homeViewModel: homeViewModel, homeModel: homeModel)
        let homeViewController = HomeViewController(contentView: contentView, viewModel: homeViewModel)
        
        self.navigationController.viewControllers = [homeViewController]
    }
    
    
    
}
