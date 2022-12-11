//
//  ViewController.swift
//  WristcamPartnerSampleCode
//
//  Created by Doron Adler on 05/12/2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var registerPartnerButton : UIButton!
    
    @IBOutlet var tokenTextField : UITextField!
    @IBOutlet var invokeWristcamButton : UIButton!
    @IBOutlet var resultTextLabel : UILabel!
    
    let thePartnerId = "8c878360-e040-4def-99cc-f9eef9e0a4e8"
    let theSecretKey = "71bf2cd8-e826-45d1-9f6b-5c3701645410"
    let thePartnerName = "Test Partner"
    var thePartnerKey : String?
    var theProviderUserToken : String?
    var theConsumerUserToken : String?
    
    let serviceProviderUserID = "11111111-1111-1111-1111-111111111001"
    let serviceProviderUserName = "ServiceProvider001"
    let serviceProviderUserAvatarUrl = "https://pbs.twimg.com/profile_images/1453758246515265536/0bXKe8pY_400x400.jpg"
    
    let serviceConsumerUserID = "11111111-1111-1111-1111-111111111002"
    let serviceConsumerUserName = "ServiceConsumer002"
    let serviceConsumerUserAvatarUrl = "https://pbs.twimg.com/profile_images/1594037780656492544/kxkIwj9e_400x400.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tokenTextField.text = "ABCD_TheToken_1234"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openWristcam(_ sender: AnyObject!) {
        guard  let theToken = self.tokenTextField.text else {
            self.resultTextLabel.text = "Please enter a token value"
            return
        }
        let wristcam = WristcamClient()
        do {
            try wristcam.open(token: theToken,onSuccess: { parameters in
                if let parameters = parameters {
                    for parameter in parameters {
                        print("parameter = \(parameter)")
                        if let glideID = parameters["glideID"] {
                            self.resultTextLabel.text = "glideID = \"\(glideID)\""
                        }
                    }
                } else {
                    print("Weird, onSuccess but no parameters")
                    self.resultTextLabel.text = "ERROR: no parameters were returned"
                }
                
            }, onFailure: { failure in
                print("failure = \(failure)")
                self.resultTextLabel.text = "ERROR: code = \(failure.code) \"\(failure.message)\""
            })
        } catch CallbackURLKitError.appWithSchemeNotInstalled(let scheme) {
            print("The App for (\(scheme)) not installed or not implement x-callback-url in current os")
            self.resultTextLabel.text = "ERROR: No App responds to scheme: \"\(scheme)\""
        } catch CallbackURLKitError.callbackURLSchemeNotDefined {
            print("You specify a callback but no manager.callbackURLScheme defined")
            self.resultTextLabel.text = "ERROR: The scheme for this sample is not configured well"
        } catch let e {
            print("exception \(e)")
        }
    }
    
    fileprivate func sendRequest(_ url: URL, _ parametersDict: [String : Any], _ completion: @escaping ([String : Any]?, Error?) -> Void) {
        //create the session object
        let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parametersDict, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil, error)
        }
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
    func postPartnerRegistrationRequest(partnerId: String,
                                        secretKey: String,
                                        profileName: String,
                                        profileEmail: String,
                                        profilePhone: String,
                                        completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        //Prepare the post body
        let profileDict : [String : Any] = ["name" : profileName, "email" : profileEmail, "phone" : profilePhone]
        let parametersDict : [String : Any] = ["partnerId": partnerId, "secretKey": secretKey, "profile" : profileDict]
        
        //create the url with NSURL
        //
        //https://wcqa-env.gldapis.com/partner/userRegistration
        let url = URL(string: "https://wcqa-env.gldapis.com/partner/registration")!
        
        sendRequest(url, parametersDict, completion)
    }
    
    @IBAction func submitPartnerRegistration(_ sender: AnyObject!) {
        //call postRequest with username and password parameters
        postPartnerRegistrationRequest(partnerId: thePartnerId,
                                       secretKey: theSecretKey,
                                       profileName: thePartnerName,
                                       profileEmail: "contact@partner.com",
                                       profilePhone: "+972527777777") { (result, error) in
            if let result = result {
                if let success = result["success"] as? [String: Any] {
                    if let thePartnerKey = success["partnerKey"] as? String {
                        self.thePartnerKey = thePartnerKey
                        DispatchQueue.main.async {
                            self.resultTextLabel.text = "partnerKey = \"\(thePartnerKey)\""
                            self.sumbitUserProviderRegistration()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.resultTextLabel.text = "ERROR: No \"partnerKey\" in response"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.resultTextLabel.text = "ERROR: No \"success\" in response"
                    }
                }
            } else if let error = error {
                let errorString = "ERROR: \(error.localizedDescription)"
                print(errorString)
                DispatchQueue.main.async {
                    self.resultTextLabel.text = errorString
                }
            }
        }
    }
    
    func postPartnerServiceProviderUserRegistrationRequest(partnerId: String,
                                                           partnerKey: String,
                                                           partnerUserId: String,
                                                           partnerUserName: String,
                                                           partnerUserAvatarUrl: String,
                                                           completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        //Prepare the post body
        let userDetailsDict : [String : Any] = ["partnerUserId" : partnerUserId,
                                                "partnerUserName" : partnerUserName,
                                                "partnerUserAvatarUrl" : partnerUserAvatarUrl]
        let parametersDict : [String : Any] = ["partnerId": partnerId, "partnerKey": partnerKey, "userDetails" : userDetailsDict]
        
        //create the url with NSURL
        //
        //
        let url = URL(string: "https://wcqa-env.gldapis.com/partner/userRegistration")!
        
        sendRequest(url, parametersDict, completion)
    }
    
    func sumbitUserProviderRegistration() {
        if let thePartnerKey = self.thePartnerKey {
            postPartnerServiceProviderUserRegistrationRequest(partnerId: thePartnerId,
                                                              partnerKey: thePartnerKey,
                                                              partnerUserId: serviceProviderUserID,
                                                              partnerUserName: serviceProviderUserName,
                                                              partnerUserAvatarUrl: serviceProviderUserAvatarUrl) { (result, error) in
                if let result = result {
                    if let success = result["success"] as? [String: Any] {
                        if let theProviderUserToken = success["token"] as? String {
                            self.theProviderUserToken = theProviderUserToken
                            DispatchQueue.main.async {
                                self.resultTextLabel.text = "Provider token = \"\(theProviderUserToken)\""
                                self.sumbitConsumerUserRegistration()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.resultTextLabel.text = "ERROR: No \"token\" in response"
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.resultTextLabel.text = "ERROR: No \"success\" in response"
                        }
                    }
                } else if let error = error {
                    let errorString = "ERROR: \(error.localizedDescription)"
                    print(errorString)
                    DispatchQueue.main.async {
                        self.resultTextLabel.text = errorString
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.resultTextLabel.text = "ERROR: We do not have a \"partnerKey\""
            }
        }
    }
    
    func postPartnerServiceConsumerUserRegistrationRequest(partnerId: String,
                                                           partnerKey: String,
                                                           partnerUserId: String,
                                                           partnerUserName: String,
                                                           partnerUserAvatarUrl: String,
                                                           complicationCallPartnerContactId: String?,
                                                           complicationMessagePartnerContactId: String?,
                                                           completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        if (complicationCallPartnerContactId == nil && complicationMessagePartnerContactId == nil) {
            print("ERROR: At least one of \"complicationCallPartnerContactId\" or \"complicationMessagePartnerContactId\" should have a contact ID value")
            completion(nil, NSError(domain: "invalidParameters", code: -100019, userInfo: nil))
            return
        }
        
        //Prepare the post body
        let userDetailsDict : [String : Any] = ["partnerUserId" : partnerUserId,
                                                "partnerUserName" : partnerUserName,
                                                "partnerUserAvatarUrl" : partnerUserAvatarUrl]
        var parametersDict : [String : Any] = ["partnerId": partnerId, "partnerKey": partnerKey, "userDetails" : userDetailsDict]
        
        if let callPartnerContactId = complicationCallPartnerContactId {
            let complicationCallDict : [String : Any] = ["partnerContactId" : callPartnerContactId]
            parametersDict["complicationCall"] = complicationCallDict
        }
        
        if let messagePartnerContactId = complicationMessagePartnerContactId {
            let complicationMessageDict : [String : Any] = ["partnerContactId" : messagePartnerContactId]
            parametersDict["complicationMessage"] = complicationMessageDict
        }
        
        //create the url with NSURL
        //
        //
        let url = URL(string: "https://wcqa-env.gldapis.com/partner/userRegistration")!
        
        sendRequest(url, parametersDict, completion)
    }
    
    func sumbitConsumerUserRegistration() {
        if let thePartnerKey = self.thePartnerKey {
            postPartnerServiceConsumerUserRegistrationRequest(partnerId: thePartnerId,
                                                              partnerKey: thePartnerKey,
                                                              partnerUserId: serviceConsumerUserID,
                                                              partnerUserName: serviceConsumerUserName,
                                                              partnerUserAvatarUrl: serviceConsumerUserAvatarUrl,
                                                              complicationCallPartnerContactId: serviceProviderUserID,
                                                              complicationMessagePartnerContactId: serviceProviderUserID) { (result, error) in
                if let result = result {
                    if let success = result["success"] as? [String: Any] {
                        if let theConsumerUserToken = success["token"] as? String {
                            self.theConsumerUserToken = theConsumerUserToken
                            DispatchQueue.main.async {
                                self.resultTextLabel.text = "Consumer token = \"\(theConsumerUserToken)\""
                                self.tokenTextField.text = theConsumerUserToken
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.resultTextLabel.text = "ERROR: No \"token\" in response"
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.resultTextLabel.text = "ERROR: No \"success\" in response"
                        }
                    }
                } else if let error = error {
                    let errorString = "ERROR: \(error.localizedDescription)"
                    print(errorString)
                    DispatchQueue.main.async {
                        self.resultTextLabel.text = errorString
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.resultTextLabel.text = "ERROR: We do not have a \"partnerKey\""
            }
        }
    }
    
}
