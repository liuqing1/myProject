//
//  APIManager.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/15/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import AFNetworking
import SwiftyJSON
import Locksmith
import RealmSwift
import MapKit
import Toucan
class APIManager {
    
    
    
    let SCHEMA_VERSION:UInt64 = 16
    
    static let shared = APIManager()
    private var af : AFHTTPSessionManager!
    
    var meTrainer:Trainer?;
    private var token:String? {
        didSet {
            af.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
        }
    };
    
    var meTrainee:Trainee?;
    
    private var averageClockDrift:NSTimeInterval = 0;
    private var recentDrifts:[NSTimeInterval] = [];
    var serverTime:NSDate {
        get {
            return NSDate().dateByAddingTimeInterval(averageClockDrift)
        }
    }
    
    init() {
        
        
        let migrationBlock:MigrationBlock = { migration, oldSchemaVersion in
//            if oldSchemaVersion < 3 {
//                // Nothing to do!
//                // Realm will automatically detect new properties and removed properties
//                // And will update the schema on disk automatically
//            }
        }
        
        // Apply the migration block above to the default Realm
        Realm.Configuration.defaultConfiguration.schemaVersion = SCHEMA_VERSION
        Realm.Configuration.defaultConfiguration.migrationBlock = migrationBlock
        
        let url = NSURL(string: Config.shared.getStr("ApiBase"))
        print("Initializing APIEngine with base url: \(url!)")
        af = AFHTTPSessionManager(baseURL: url)
        af.requestSerializer = AFJSONRequestSerializer()
        af.responseSerializer = CustomResponseSerializer()
        
        
    }
    
    func applyRealmTransaction(block:(Void->Void))->Bool {
        let realm = try! Realm()
        realm.beginWrite()
        block();
        if let _ = try? realm.commitWrite() {
            return true
        }
        return false
    }
    func logout() {
        self.token = nil
        self.meTrainer = nil
        self.meTrainee = nil
        do {
            try Locksmith.deleteDataForUserAccount("fiti")
        } catch {
            print("nothing to clear")
        }
    }
    func cachedLogin()->Bool {
        guard let dictionary = Locksmith.loadDataForUserAccount("fiti"), aid = dictionary["id"] as? String, atoken = dictionary["token"] as? String, atype=dictionary["type"] as? String else {
            return false
        }
        self.token = atoken
        let realm = try! Realm()
        if (atype=="trainer") {
            self.meTrainer = realm.objectForPrimaryKey(Trainer.self, key: aid)
            self.token = atoken
            return true
        } else {
            self.meTrainee = realm.objectForPrimaryKey(Trainee.self, key: aid)
            self.token = atoken
            return true
        }
    }
    func refreshMe(success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = token else {
            error("No token");
            return
        }
        af.GET("me", parameters: nil, progress: nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    let resource = response.json["resource"].string
                    if resource == "trainer" {
                        let trainer = Trainer.fromJSON(response.json)
                        self.meTrainer = trainer
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(trainer, update:true)
                        }
                        success();
                    } else if resource == "trainee" {
                        let trainee = Trainee.fromJSON(response.json)
                        self.meTrainee = trainee
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(trainee, update:true)
                        }
                        success();
                    } else {
                        error("Unknown resource type");
                    }
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func login(country:String, phone:String, password:String, success:((Trainer?, Trainee?) -> Void), error:((String) -> Void)) {
        af.POST("login", parameters: ["phone":phone, "password":password, "country":country], progress: nil, success: { (task, response) -> Void in
                if let response = response as? FitiResponse {
                    if let errorMessage = response.errorMessage {
                       error(errorMessage);
                    } else {
                        let resource = response.json["resource"].string
                        if resource == "trainer" {
                            let trainer = Trainer.fromJSON(response.json)
                            self.token = response.json["token"].string
                            self.meTrainer = trainer
                            let realm = try! Realm()
                            try! realm.write {
                                realm.add(trainer, update:true)
                            }
                            try! Locksmith.updateData(["id":trainer.id,"type":"trainer","token":response.json["token"].string!], forUserAccount: "fiti")
                            success(trainer,nil);
                        } else if resource == "trainee" {
                            let trainee = Trainee.fromJSON(response.json)
                            self.token = response.json["token"].string
                            self.meTrainee = trainee
                            let realm = try! Realm()
                            try! realm.write {
                                realm.add(trainee, update:true)
                            }
                            try! Locksmith.updateData(["id":trainee.id,"type":"trainee","token":response.json["token"].string!], forUserAccount: "fiti")
                            success(nil, trainee);
                        }
                    }
                } else {
                    error("Error parsing response");
                }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
        
    }
    func forgotPassword(country:String, phone:String, success:((String) -> Void), error:((String) -> Void)) {
        af.POST("forgotpassword", parameters: ["phone":phone, "country":country], progress: nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else if let message = response.json["message"].string {
                        success(message)
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
        
    }
    func signupTrainee(country:String, phone:String, success:(Void -> Void), error:((String) -> Void)) {
        af.POST("trainees", parameters: ["phone":phone, "country":country], progress: nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success();
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func confirmTrainee(country:String, phone:String, code:String, success:((Trainee) -> Void), error:((String) -> Void)) {
         af.POST("trainees/confirm", parameters: ["phone":phone, "country":country, "code":code], progress: nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else if let tok = response.json["_id"].string, trainee_id = response.json["resource_id"].string {
                    self.token = tok
                    let trainee = Trainee()
                    trainee.id = trainee_id ?? ""
                    self.meTrainee = trainee
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(trainee, update:true)
                    }
                    try! Locksmith.updateData(["id":trainee.id,"type":"trainee","token":tok], forUserAccount: "fiti")
                    success(trainee);
                }
            } else {
                 error("Error parsing response");
            }
            }) {task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func rate(booking:Booking, stars:Int, comment:String, privateFeedback:String, success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = token else {
            error("No token");
            return
        }
        let fields = ["stars":stars, "comment":comment, "private_feedback":privateFeedback]
        af.PATCH("bookings/"+booking.id!+"/rate", parameters: fields, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success()
                    APIManager.shared.applyRealmTransaction({
                        booking.rated = true
                    })
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
        
    }
    func updateTrainer(fields:[String:AnyObject], success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = token else {
            error("No token");
            return
        }
        let id = meTrainer!.id
        af.PATCH("trainers/"+id, parameters: fields, success: { (task, response) -> Void in
                if let response = response as? FitiResponse {
                    if let errorMessage = response.errorMessage {
                        error(errorMessage);
                    } else {
                        success()
                    }
                } else {
                    error("Error parsing response");
                }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func updateTrainee(fields:[String:AnyObject], success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = token else {
            error("No token");
            return
        }
        let id = meTrainee!.id
        af.PATCH("trainees/"+id, parameters: fields, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success()
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func updateBooking(booking:Booking, fields:[String:AnyObject], success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = token, booking_id=booking.id else {
            error("No token or booking id");
            return
        }
        af.PATCH("bookings/"+booking_id, parameters: fields, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success()
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func getTrainers(near:CLLocationCoordinate2D, success:([Trainer] -> Void), error:((String) -> Void)) {
        
        let params = ["latitude":near.latitude, "longitude":near.longitude, "radius":10000]
        
        af.GET("trainers", parameters: params, progress:nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    let jsonarr = response.json
                    let trainers = jsonarr.map({ (key, tjson) -> Trainer in
                        let t = Trainer.fromJSON(tjson)
                        return t
                    })
                    
                    // trainers who are within 10km of me, and have at least one skill
                    let maxDistance = Constants.Values.DemoMode ? Double(100000000) : Double(10000)
                    let relevantTrainers = trainers.filter({ trainer in
                        return !trainer.skills.isEmpty && CLLocation.distance(from: near, to: trainer.coordinate())<maxDistance;
                    })
                    success(relevantTrainers)
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func makeBooking(trainer:Trainer, skill:Skill, duration:Int, startTime:NSDate, people:Int, latitude:Double, longitude:Double, location:String, success:(Void -> Void), error:((String) -> Void)) {
        guard let _ = APIManager.shared.meTrainee else {
            error("You are not logged in as a trainee!");
            return
        }
        guard let _ = token, skillid = skill.id else {
            error("Invalid parameters");
            return
        }
        let params:[String:AnyObject] = ["trainer":trainer.id, "skill":skillid, "duration":duration, "startTime":startTime.toISODate(), "people":people, "latitude":latitude, "longitude":longitude, "location":location]
        
        
        af.POST("bookings", parameters: params, progress:nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success()
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func getBooking(booking_id:String, success:(Booking -> Void), error:((String) -> Void)) {
        guard let _ = token else {
            error("Invalid parameters");
            return
        }
        
        af.GET("bookings/\(booking_id)", parameters: nil, progress:nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    success(Booking.fromJSON(response.json))
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func getMyBookingsAsTrainer(success:([Booking] -> Void), error:((String) -> Void)) {
        guard let _ = APIManager.shared.meTrainer else {
            error("You are not logged in as a trainer!");
            return
        }
        guard let _ = token else {
            error("No token");
            return
        }
        af.GET("trainers/bookings", parameters: nil, progress:nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    let jsonarr = response.json
                    let bookingsArr = jsonarr.map({ (key, tjson) -> Booking in
                        let b = Booking.fromJSON(tjson)
                        return b
                    })
                    success(bookingsArr)
                    
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }
    }
    func getMyBookingsAsTrainee(success:([Booking] -> Void), error:((String) -> Void)) {
        guard let _ = APIManager.shared.meTrainee else {
            error("You are not logged in as a trainee!");
            return
        }
        guard let _ = token else {
            error("No token");
            return
        }
        af.GET("trainees/bookings", parameters: nil, progress:nil, success: { (task, response) -> Void in
            if let response = response as? FitiResponse {
                if let errorMessage = response.errorMessage {
                    error(errorMessage);
                } else {
                    let jsonarr = response.json
                    let bookings = jsonarr.map({ (key, tjson) -> Booking in
                        let b = Booking.fromJSON(tjson)
                        return b
                    })
                    success(bookings)
                }
            } else {
                error("Error parsing response");
            }
            }) { task, err in
                error("Unknown error, please check your internet connection");
        }

    }
    private func addDrift(drift:NSTimeInterval) {
        recentDrifts.append(drift)
        if (recentDrifts.count>10) {
            recentDrifts.removeFirst(recentDrifts.count-10)
        }
        averageClockDrift = Double(recentDrifts.reduce(0,combine:+))/Double(recentDrifts.count)
        print("average clock drift is", averageClockDrift)
    }
    func uploadImage(image : UIImage, success:(String -> Void), error:((String) -> Void) ) {
        
        if APIManager.shared.meTrainer==nil && APIManager.shared.meTrainee==nil {
            error("Not logged in");
            return
        }
        
        print("uploading image")
        
        if let imageData = UIImageJPEGRepresentation(image, 0.9) {
            af.POST("upload/profile", parameters: nil, constructingBodyWithBlock: { (formData : AFMultipartFormData) -> Void in
                formData.appendPartWithFileData(imageData, name: "profile", fileName: "\(NSUUID().UUIDString).jpg", mimeType: "image/jpeg")
                }, progress: { (progress: NSProgress) -> Void in
                    print("upload progress: \(progress)")
                }, success: { (task : NSURLSessionDataTask, response : AnyObject?) -> Void in
                    if let response = response as? FitiResponse {
                        if let errorMessage = response.errorMessage {
                            error(errorMessage);
                        } else {
                            if let profile = response.json["profile"].string {
                                success(profile)
                            } else {
                                error("wrong response")
                            }
                        }
                        
                    }
                }) { (task : NSURLSessionDataTask?, e : NSError) -> Void in
                    error(e.description)
            }
        } else {
            error("Cant create JPG from image")
        }
        
   
        
        
    }
    func uploadCertificate(title:NSString, skill:Skill, image : UIImage, success:(Void -> Void), error:((String) -> Void) ) {
        
        if APIManager.shared.meTrainer==nil {
            error("Not logged in");
            return
        }
        
        print("uploading certificate")
        
        if let imageData = UIImageJPEGRepresentation(image, 0.9) {
            af.POST("upload/skillcert", parameters: ["title":title, "skill":skill.id!], constructingBodyWithBlock: { (formData : AFMultipartFormData) -> Void in
                formData.appendPartWithFileData(imageData, name: "skillcert", fileName: "\(NSUUID().UUIDString).jpg", mimeType: "image/jpeg")
                }, progress: { (progress: NSProgress) -> Void in
                    print("upload progress: \(progress)")
                }, success: { (task : NSURLSessionDataTask, response : AnyObject?) -> Void in
                    if let response = response as? FitiResponse {
                        if let errorMessage = response.errorMessage {
                            error(errorMessage);
                        } else {
                            if let ok = response.json["success"].bool where ok {
                                success()
                            } else {
                                error("wrong response")
                            }
                        }
                        
                    }
                }) { (task : NSURLSessionDataTask?, e : NSError) -> Void in
                    error(e.description)
            }
        } else {
            error("Cant create JPG from image")
        }
        
        
        
        
    }
    
    func uploadVideo(videoPath : String, success:(String -> Void), error:((String) -> Void) ) {
        
        guard let _ = APIManager.shared.meTrainer else {
            error("You are not logged in as a trainee!");
            return
        }
        
        print("uploading video: \(videoPath)")
        if let url = NSURL(string: videoPath) {
            if let videoData = NSData(contentsOfURL: url) {
                af.POST("trainers/video", parameters: nil, constructingBodyWithBlock: { (formData : AFMultipartFormData) -> Void in
                    formData.appendPartWithFileData(videoData, name: "video", fileName: "\(NSUUID().UUIDString).mov", mimeType: "video/quicktime")
                    }, progress: { (progress: NSProgress) -> Void in
                        print("upload progress: \(progress)")
                    }, success: { (task : NSURLSessionDataTask, response : AnyObject?) -> Void in
                        if let response = response as? FitiResponse {
                            if let errorMessage = response.errorMessage {
                                error(errorMessage);
                            } else {
                                if let video = response.json["video"].string {
                                    success(video)
                                } else {
                                    error("wrong response")
                                }
                            }
                            
                        }
                    }) { (task : NSURLSessionDataTask?, e : NSError) -> Void in
                        error(e.description)
                }
            } else {
                error("Wrong URL for video file")
            }

        } else {
            error("Wrong URL for video file")
        }
        
        
        
    }
    func sendImageContentToWeixin(image:UIImage, success:(String -> Void), error:((String) -> Void)) {
        //if the Weixin app is not installed, show an error
        if !WXApi.isWXAppInstalled() {
            error("The Weixin app is not installed")
        }
        
        //create a message object
        let message = WXMediaMessage()
        
        //set the thumbnail image. This MUST be less than 32kb, or sendReq may return NO.
        //we'll just use the full image resized to 100x100 pixels for now
        message.setThumbImage(Toucan.Resize.resizeImage(image, size: CGSize(width: 100, height: 100)))
        
        //create an image object and set the image data as a JPG representation of our UIImage
        let ext = WXImageObject()
        ext.imageData = UIImageJPEGRepresentation(image, 0.8)
        message.mediaObject = ext
        
        //create a request
        let req = SendMessageToWXReq()
        
        //this is a multimedia message, not a text message
        req.bText = false
        
        //set the message
        req.message = message
        
        //set the "scene", WXSceneTimeline is for "moments". WXSceneSession allows the user to send a message to friends
        req.scene = Int32(WXSceneTimeline.rawValue)
        
        //try to send the request
        if !WXApi.sendReq(req) {
            error("Error")
        } else {
            success("Success")
        }
    }


}
class FitiResponse {
    var json:JSON;
    var serverTime:NSDate?;
    var errorMessage:String?;
    init(json:JSON) {
        self.json = json
    }
}
class CustomResponseSerializer : AFHTTPResponseSerializer {
    private static var headerFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return formatter
    }()
   
    
    override func responseObjectForResponse(response: NSURLResponse?, data: NSData?, error: NSErrorPointer) -> AnyObject? {
        guard let data = data, response = response as? NSHTTPURLResponse else {
            return nil;
        }
        let json = JSON(data:data)
        let res = FitiResponse(json:json)
        
        //if there's an error, try to extract the "message" property from the response and add to userInfo.message
        if (response.statusCode != 200) {
            if let message = json["message"].string {
                res.errorMessage = message;
            } else {
                res.errorMessage = "Unknown error \(response.statusCode)"
            }
        }
        if let date = response.allHeaderFields["Date"] as? String, serverTime = CustomResponseSerializer.headerFormatter.dateFromString(date) {
            res.serverTime = serverTime
            let drift = serverTime.timeIntervalSinceNow
            APIManager.shared.addDrift(drift)
        }
        
        return res
    }
    
}
