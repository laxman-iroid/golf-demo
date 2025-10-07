import Foundation
import ObjectMapper

// MARK: - Login Response -
class LogInResponse: Mappable {
    var id: Int?
    var name: String?
    var email: String?
    var token: Token?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
        email           <- map["email"]
        token           <- map["auth"]
    }
}

class Token: Mappable {
    var token: String?
    var refreshToken: String?
    var expiresIn: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        token        <- map["token"]
        refreshToken <- map["refreshToken"]
        expiresIn    <- map["expires_in"]
    }
}
