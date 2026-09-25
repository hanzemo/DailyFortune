import Foundation
import SwiftKeychainWrapper

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let accessTokenKey = "dailyfortune.accessToken"
    private let refreshTokenKey = "dailyfortune.refreshToken"

    @discardableResult
    func saveAccessToken(token: String) -> Bool {
        return KeychainWrapper.standard.set(token, forKey: accessTokenKey)
    }

    func getAccessToken() -> String? {
        return KeychainWrapper.standard.string(forKey: accessTokenKey)
    }

    @discardableResult
    func removeAccessToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: accessTokenKey)
    }

    @discardableResult
    func saveRefreshToken(token: String) -> Bool {
        return KeychainWrapper.standard.set(token, forKey: refreshTokenKey)
    }

    func getRefreshToken() -> String? {
        return KeychainWrapper.standard.string(forKey: refreshTokenKey)
    }

    @discardableResult
    func removeRefreshToken() -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: refreshTokenKey)
    }

    func clearAll() {
        removeAccessToken()
        removeRefreshToken()
    }
}
