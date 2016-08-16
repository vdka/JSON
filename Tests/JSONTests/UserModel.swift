
import Foundation
import JSON

// The model that the JSON in large.json in Fixtures models.

public struct User {
  public let id: String
  public let index: Int
  public let guid: String
  public let isActive: Bool
  public let balance: String
  public let picture: String
  public let age: Int
  public let eyeColor: Color
  public let name: String
  public let gender: Gender
  public let company: String
  public let email: String
  public let phone: String
  public let address: String
  public let about: String
  public let registered: String
  public let latitude: Double
  public let longitude: Double
  public let tags: [String]
  public let friends: [Friend]
  public let greeting: String
  public let favoriteFruit: String

  public enum Color: String {
    case red
    case green
    case blue
    case brown
  }

  public enum Gender: String {
    case male
    case female
  }

  public struct Friend {
    public let id: Int
    public let name: String
  }
}

// MARK: - vdka/json

extension User.Friend: JSONInitializable {

  public init(json: JSON) throws {
    self.id   = try json.get("id")
    self.name = try json.get("name")
  }
}

extension User: JSONInitializable {

  public init(json: JSON) throws {
    self.id             = try json.get("_id")
    self.index          = try json.get("index")
    self.guid           = try json.get("guid")
    self.isActive       = try json.get("isActive")
    self.balance        = try json.get("balance")
    self.picture        = try json.get("picture")
    self.age            = try json.get("age")
    self.eyeColor       = try json.get("eyeColor")
    self.name           = try json.get("name")
    self.gender         = try json.get("gender")
    self.company        = try json.get("company")
    self.email          = try json.get("email")
    self.phone          = try json.get("phone")
    self.address        = try json.get("address")
    self.about          = try json.get("about")
    self.registered     = try json.get("registered")
    self.latitude       = try json.get("latitude")
    self.longitude      = try json.get("longitude")
    self.tags           = try json.get("tags")
    self.friends        = try json.get("friends")
    self.greeting       = try json.get("greeting")
    self.favoriteFruit  = try json.get("favoriteFruit")
  }
}


// MARK: - Foundation

enum FoundationJSONError: Error {
  case typeMismatch
}

extension User.Friend {

  public init(foundationJSON json: Any) throws {
    guard
      let json  = json as? [String: Any],
      let id    = json["id"] as? Int,
      let name  = json["name"] as? String
      else { throw FoundationJSONError.typeMismatch }
    self.id   = id
    self.name = name
  }
}

extension User {

  public init(foundationJSON json: Any) throws {
    guard
      let json              = json as? [String: Any],
      let id                = json["_id"] as? String,
      let index             = json["index"] as? Int,
      let guid              = json["guid"] as? String,
      let isActive          = json["isActive"] as? Bool,
      let balance           = json["balance"] as? String,
      let picture           = json["picture"] as? String,
      let age               = json["age"] as? Int,
      let eyeColorRawValue  = json["eyeColor"] as? String,
      let eyeColor          = Color(rawValue: eyeColorRawValue),
      let name              = json["name"] as? String,
      let genderRawValue    = json["gender"] as? String,
      let gender            = Gender(rawValue: genderRawValue),
      let company           = json["company"] as? String,
      let email             = json["email"] as? String,
      let phone             = json["phone"] as? String,
      let address           = json["address"] as? String,
      let about             = json["about"] as? String,
      let registered        = json["registered"] as? String,
      let latitude          = json["latitude"] as? Double,
      let longitude         = json["longitude"] as? Double,
      let tags              = json["tags"] as? [String],
      let friendsObjects    = json["friends"] as? [Any],
      let greeting          = json["greeting"] as? String,
      let favoriteFruit     = json["favoriteFruit"] as? String
      else { throw FoundationJSONError.typeMismatch }

    self.id             = id
    self.index          = index
    self.guid           = guid
    self.isActive       = isActive
    self.balance        = balance
    self.picture        = picture
    self.age            = age
    self.eyeColor       = eyeColor
    self.name           = name
    self.gender         = gender
    self.company        = company
    self.email          = email
    self.phone          = phone
    self.address        = address
    self.about          = about
    self.registered     = registered
    self.latitude       = latitude
    self.longitude      = longitude
    self.tags           = tags
    self.friends        = try friendsObjects.map(Friend.init)
    self.greeting       = greeting
    self.favoriteFruit  = favoriteFruit
  }
}


