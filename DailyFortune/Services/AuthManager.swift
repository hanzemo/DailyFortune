import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthManager: ObservableObject {

    @Published private(set) var isLoading = true
    @Published private(set) var token: String?
    @Published private(set) var currentUser: UserMeProfile?

    var isAuthenticated: Bool {
        return token != nil && currentUser != nil
    }

    init() {
        Task(priority: .userInitiated) {
            let storedToken = KeychainService.shared.getAccessToken()
            if let token = storedToken, !token.isEmpty {
                self.token = token
                await self.fetchCurrentUser()
            }
            self.isLoading = false
        }
    }

    func login(accessToken: String, refreshToken: String, user: UserMeProfile) {
        KeychainService.shared.saveAccessToken(token: accessToken)
        KeychainService.shared.saveRefreshToken(token: refreshToken)
        self.token = accessToken
        self.currentUser = user
    }

    func logout() {
        KeychainService.shared.clearAll()
        self.token = nil
        self.currentUser = nil
    }

    func fetchCurrentUser() async {
        guard token != nil else {
            logout()
            return
        }
        do {
            let response = try await APIService.shared.getMyProfile()
            self.currentUser = response.user
        } catch {
            if await tryRefreshToken() {
                if let response = try? await APIService.shared.getMyProfile() {
                    self.currentUser = response.user
                    return
                }
            }
            print("持久化登录失败: \(error.localizedDescription)")
            logout()
        }
    }

    private func tryRefreshToken() async -> Bool {
        guard let refreshToken = KeychainService.shared.getRefreshToken() else {
            return false
        }
        do {
            let response = try await APIService.shared.refreshToken(refreshToken)
            KeychainService.shared.saveAccessToken(token: response.accessToken)
            KeychainService.shared.saveRefreshToken(token: response.refreshToken)
            self.token = response.accessToken
            return true
        } catch {
            return false
        }
    }

    func updateUser(_ newUser: UserMeProfile) {
        self.currentUser = newUser
    }
}
