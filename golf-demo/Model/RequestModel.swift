import Foundation
import ObjectMapper


// MARK: - Login -
class LoginRequest: Mappable {

    var email: String?
    var password: String?

    init(email: String? = nil, password: String? = nil) {
        self.email = email
        self.password = password
    }
    required init?(map: Map){
    }

    func mapping(map: Map) {
        email <- map["email"]
        password <- map["password"]
    }
}

// MARK: - SIGNUP -
class SignUpRequest: Mappable {

    var name: String?
    var email: String?
    var password: String?

    init(name: String?,email: String? = nil, password: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
    }
    required init?(map: Map){
    }

    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        password <- map["password"]
    }
}

