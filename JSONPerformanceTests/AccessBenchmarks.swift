
import XCTest
//import SwiftyJSON
import JSON

class AccessBenchmarks: XCTestCase {
  
  struct User: JSONDecodable {
    let id: Int
    let name: String
    let screenName: String
    let createdAt: String
    let location: String
    let protected: Bool
    let verified: Bool
    let url: String?
//
//    let following: Bool?
//    
//    let geoEnabled: Bool
//    let friendsCount: Int
//    let statusesCount: Int
//    let followersCount: Int
//    let favouritesCount: Int
//    let description: String?
//    let profileImageURL: String
//    let profileBackgroundImageURL: String
    
    enum Error: ErrorProtocol {
      case unknown
    }
    
    init(json: VDKAJSON) throws {
      guard
        let id = json["id"].int,
        let name = json["name"].string,
        let screenName = json["screen_name"].string,
        let createdAt = json["created_at"].string,
        let location = json["location"].string,
        let protected = json["protected"].bool,
        let verified = json["verified"].bool
      else { throw Error.unknown }
      
      self.id = id
      self.name = name
      self.screenName = screenName
      self.createdAt  = createdAt
      self.location = location
      self.protected = protected
      self.verified = verified
      self.url = json["url"].string
    }
    
    init?(nsJson: [String: AnyObject]) {
      guard
        let id = nsJson["id"] as? Int,
        let name = nsJson["name"] as? String,
        let screenName = nsJson["screen_name"] as? String,
        let createdAt = nsJson["created_at"] as? String,
        let location = nsJson["location"] as? String,
        let protected = nsJson["protected"] as? Bool,
        let verified = nsJson["verified"] as? Bool
      else { return nil }
      
      self.id = id
      self.name = name
      self.screenName = screenName
      self.createdAt  = createdAt
      self.location = location
      self.protected = protected
      self.verified = verified
      self.url = nsJson["url"] as? String
    }
    
//    init?(swiftyJson: SwiftyJSON.JSON) {
//      guard
//        let id = swiftyJson["id"].int,
//        let name = swiftyJson["name"].string,
//        let screenName = swiftyJson["screen_name"].string,
//        let createdAt = swiftyJson["created_at"].string,
//        let location = swiftyJson["location"].string,
//        let protected = swiftyJson["protected"].bool,
//        let verified = swiftyJson["verified"].bool
//      else { return nil }
//      
//      self.id = id
//      self.name = name
//      self.screenName = screenName
//      self.createdAt  = createdAt
//      self.location = location
//      self.protected = protected
//      self.verified = verified
//      self.url = swiftyJson["url"].string
//    }
  }

  func testTwitterTweetMappingJSON() {
    guard let userJson = twitterJson[0]["user"] else { fatalError() }
    measure {
      for _ in 0...1000 {
        _ = try! User(json: userJson)
      }
    }
  }
  
  func testTwitterTweetMappingNSJSON() {
    guard let json = try! JSONSerialization.jsonObject(with: twitterJsonData, options: []) as? [[String: AnyObject]] else { fatalError() }
    guard let userJson = json[0]["user"] as? [String: AnyObject] else { fatalError() }
    measure {
      for _ in 0...1000 {
        _ = User(nsJson: userJson)!
      }
    }
    
  }

//  func testTwitterTweetMappingSwiftyJSON() {
//    let json = SwiftyJSON.JSON.init(twitterJsonData)
//    let userJson = json[0]["user"]
//    measureBlock {
//      for _ in 0...1000 {
//        User(swiftyJson: userJson)!
//      }
//    }
//  }
  
  
  
  
}
/*
{
  "geo": null,
  "in_reply_to_user_id": null,
  "in_reply_to_status_id": null,
  "truncated": false,
  "source": "web",
  "favorited": false,
  "created_at": "Wed Nov 04 07:20:37 +0000 2009",
  "in_reply_to_screen_name": null,
  "user": {
    "notifications": null,
    "favourites_count": 0,
    "description": "AdMan \/ Music Collector",
    "following": null,
    "statuses_count": 617,
    "profile_text_color": "8c8c8c",
    "geo_enabled": false,
    "profile_background_image_url": "http:\/\/s.twimg.com\/a\/1257288876\/images\/themes\/theme9\/bg.gif",
    "profile_image_url": "http:\/\/a3.twimg.com\/profile_images\/503330459\/madmen_icon_normal.jpg",
    "profile_link_color": "2FC2EF",
    "verified": false,
    "profile_background_tile": false,
    "url": null,
    "screen_name": "khaled_itani",
    "created_at": "Thu Jul 23 20:39:21 +0000 2009",
    "profile_background_color": "1A1B1F",
    "profile_sidebar_fill_color": "252429",
    "followers_count": 156,
    "protected": false,
    "location": "Tempe, Arizona",
    "name": "Khaled Itani",
    "time_zone": "Pacific Time (US & Canada)",
    "friends_count": 151,
    "profile_sidebar_border_color": "050505",
    "id": 59581900,
    "utc_offset": -28800
  },
  "id": 5414922107,
  "text": "RT @cakeforthought 24. If you wish hard enough, you will hear your current favourite song on the radio minutes after you get into your car."

 */
