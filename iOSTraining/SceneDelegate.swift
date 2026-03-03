//
//  SceneDelegate.swift
//  iOSTraining
//
//  Created by FDC.Eyan-NC-SA-IOS on 2/24/26.
//

import UIKit
import SwiftUI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var cartCancellable: AnyCancellable?
    private var ordersCancellable: AnyCancellable?
    private var tabBarController: UITabBarController?

    func showLoginScreen(animated: Bool = false) {
        let loginViewController = SigninViewController(
            nibName: String(describing: SigninViewController.self),
            bundle: nil
        )

        setRootViewController(loginViewController, animated: animated)
    }

    func showMainApp(animated: Bool = true) {
        let tabBarController = UITabBarController()
        self.tabBarController = tabBarController

        // Home Tab - Empty placeholder
        let homeVC = UIHostingController(rootView: HomeTabView())
        homeVC.view.backgroundColor = .systemBackground
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)


        // Shop Tab - Your ProductListViewController
        let shopVC = ProductListViewController()
        let shopNav = UINavigationController(rootViewController: shopVC)
        shopNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        // Cart Tab
        let cartVC = UIHostingController(rootView: Cart())
        cartVC.view.backgroundColor = .systemBackground
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 2)

        // orders Tab
        let ordersVC = UIHostingController(rootView: OrdersView())
        ordersVC.view.backgroundColor = .systemBackground
        ordersVC.tabBarItem = UITabBarItem(title: "My Orders", image: UIImage(systemName: "bag"), tag: 3)

        //Settings
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)

        tabBarController.viewControllers = [homeVC, shopNav, cartVC, ordersVC, settingsVC]
        
        setupBadgeObservers()
        
        setRootViewController(tabBarController, animated: animated, useNavigation: false)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                   
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Configure global appearance
        configureAppearance()
                   
        if isLoggedIn {
            showMainApp(animated: false)
        } else {
            showLoginScreen(animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

private extension SceneDelegate {
    func setupBadgeObservers() {
        // Cart badge observer
        cartCancellable = CartManager.shared.$items
            .map { $0.reduce(0) { $0 + $1.quantity } }
            .sink { [weak self] totalCount in
                DispatchQueue.main.async {
                    guard let tabBar = self?.tabBarController else { return }
                    // Cart is at index 2
                    if totalCount > 0 {
                        tabBar.viewControllers?[2].tabBarItem.badgeValue = "\(totalCount)"
                    } else {
                        tabBar.viewControllers?[2].tabBarItem.badgeValue = nil
                    }
                }
            }
        
        // Orders badge observer
        ordersCancellable = OrderManager.shared.$orders
            .map { $0.filter { $0.status == .pending || $0.status == .processing }.count }
            .sink { [weak self] unreadCount in
                DispatchQueue.main.async {
                    guard let tabBar = self?.tabBarController else { return }
                    // Orders is at index 3
                    if unreadCount > 0 {
                        tabBar.viewControllers?[3].tabBarItem.badgeValue = "\(unreadCount)"
                    } else {
                        tabBar.viewControllers?[3].tabBarItem.badgeValue = nil
                    }
                }
            }
    }
    
    func configureAppearance() {
        // Brand green color
        let brandGreen = UIColor(red: 87/255.0, green: 175/255.0, blue: 135/255.0, alpha: 1.0)
        
        // Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = brandGreen
        
        // Tab Bar Appearance
        UITabBar.appearance().tintColor = brandGreen
        
        // Global tint color
        window?.tintColor = brandGreen
    }
    
    func setRootViewController(_ viewController: UIViewController, animated: Bool, useNavigation: Bool = true) {
        guard let window else { return }

        let applyRoot = {
            let wereAnimationsEnabled = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)

            if useNavigation {
                window.rootViewController = UINavigationController(rootViewController: viewController)
            } else {
                window.rootViewController = viewController
            }

            window.makeKeyAndVisible()
            UIView.setAnimationsEnabled(wereAnimationsEnabled)
        }

        guard animated else {
            applyRoot()
            return
        }

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: applyRoot
        )
    }
}
