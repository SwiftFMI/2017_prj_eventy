//
//  User.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import Foundation

class User: Codable {
    let name: String
    let id: Int
    let eventsIds: [Int]
    let profilePicPath: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id = "id"
        case eventsIds = "events"
        case profilePicPath = "profile-pic"
    }
    
    init(name: String, id: Int, events: [Int], profilePic: String) {
        self.name = name
        self.id = id
        self.eventsIds = events
        self.profilePicPath = profilePic
    }
}

// MARK: Convenience initializers

extension User {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(User.self, from: data)
        self.init(name: me.name, id: me.id, events: me.eventsIds, profilePic: me.profilePicPath)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

