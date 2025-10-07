import Foundation
import ObjectMapper

class Response: Mappable {
    var success: String?
    var error: String?
    var message: String?
    var status: Bool?
    var logInResponse: LogInResponse?
    
    required init?(map: ObjectMapper.Map) { }
    
    func mapping(map: ObjectMapper.Map) {
        success <- map["success"]
        error <- map["error"]
        message <- map["message"]
        status  <- map["status"]
        logInResponse <- map["data"]
    }
}
