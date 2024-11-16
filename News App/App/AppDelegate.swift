import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Criar uma janela principal
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Inicializar o UINavigationController
        let navigationController = UINavigationController()
        
        // Inicializar o AppCoordinator com o UINavigationController
        appCoordinator = AppCoordinator(navigationController: navigationController)
        
        // Iniciar o fluxo do AppCoordinator
        appCoordinator?.start()
        
        // Definir o rootViewController da janela principal
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

