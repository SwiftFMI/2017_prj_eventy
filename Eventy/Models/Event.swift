//
//  Event.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import Foundation

class Event: Codable {
    let name: String
    let id: Int
    let location: String
    let createdById: Int
    let participantIds: [Int]
    let imagePaths: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id = "id"
        case location = "location"
        case createdById = "created-by"
        case participantIds = "participants"
        case imagePaths = "images"
    }
    
    init(name: String, id: Int, location: String, createdBy: Int, participants: [Int], images: [String]) {
        self.name = name
        self.id = id
        self.location = location
        self.createdById = createdBy
        self.participantIds = participants
        self.imagePaths = images
    }
}

// MARK: Convenience initializers

extension Event {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Event.self, from: data)
        self.init(name: me.name, id: me.id, location: me.location, createdBy: me.createdById, participants: me.participantIds, images: me.imagePaths)
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
