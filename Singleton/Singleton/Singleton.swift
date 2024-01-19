//
//  Singleton.swift
//  Singleton
//
//  Created by Vinod Supnekar on 18/01/24.
//

import Foundation
import UIKit

/* By Book Defination of Singleton(// Upper case Singleton(By book):- ):-
class ApiClient {
    
    private static let instance = ApiClient()
    
    static func getInstance() -> ApiClient {
        return instance
    }
    
    private init() {}
    
}
*/

// Swift versipn Defination:-
final class ApiClient {
    
    static let instance = ApiClient() // In swift "static let" is a constant and lazy loaded
    
    private init() {}
    
    func login(completion: (LoggedInUser) -> Void) {}
    
}

/* final:- not allowed for singleton, i.e. Singleton class may be extended, adding more methods to a singlton class is allowed.
class MyApiClient: ApiClient {
    
    override func  getXYZ() {
        
    }
    
    func add() {
     
    }
}
 
 But in swift we can achieve this by using Extention's.

// Hence:-

extension ApiClient { // Remeber ApiClient Class is final.
    
}
 */

/* Lower case singleton(Apple use's for convenience):-
URLSession.shared
URLSession()
*/


// Testing the App :- Now we can inject a property in tests to Test this function, using Property injetion and MockApiClient(see MyApiClient above).

// And using proerty  var api = ApiClient2.instance, we can test it.
// Or We can make Global Mutable test(not recommended ) like below:-
/*
 final class ApiClient {
     
     static var instance = ApiClient()
     
     private init() {}
     
     func login(completion: (LoggedInUser) -> Void) {}
     
 }
 
 class LoginViewController: UIViewController {
          
     func didTapLogin() {
         
        ApiClient2.instance.login() { user in
                 // show next screen
         }
     }
 }
 
 
 // for testing we can use mock like below:-
 ApiClient2.instance = MyApiClient()

// This appoacha has very much limitations, as its rick prone , as global state
 can be modified at any time , and may create App state to state from anywhere.
 */
let client = ApiClient2.instance


class LoginViewController: UIViewController {
    
    var api = ApiClient2.instance // Property injetion.
    
    func didTapLogin() {
        
        api.login() { user in
                // show next screen
        }
    }
}


/* Now to test didTapLogin(), we need to use Mock of ApiClient, so need to make it non-final class for swift
 ApiClient2 is non final.
 */

class ApiClient2 {
    
    static let instance = ApiClient2()
    
    private init() {}
    
    func login(completion: (LoggedInUser) -> Void) {}
    
}

class MockApiClient: ApiClient2 {
    
}


// Now the wrong practices , is to make instance as var, to tets ApiClient
class ApiClient3 {
    
    static var instance = ApiClient3() // var instance to test it.
    
    init() {}
    
    func login(completion: (LoggedInUser) -> Void) {}
    
}

class MockApiClient3: ApiClient3 {
    
    override init() {
        
    }
}

// now test is llike
// ApiClient3.instance = MockApiClient3()


//*************

// Extending ApiClient with more feature.

class FeedViewController: UIViewController {
    
    var api = ApiClient4.instance
    
    override func viewDidLoad() {
         
        super.viewDidLoad()
        
        api.loadFeed { loadedFeeds in
            
        }
    }
}



class ApiClient4 {
    
    static let instance = ApiClient4() // In swift "static let" is a constant and lazy loaded
    
    private init() {}
    
    func login(completion: (LoggedInUser) -> Void) {}
    func loadFeed(completion: ([FeedItem]) -> Void) {}
}

// Problems Now, as we see above, adding more featues in ApiClient4 is easy,but we are breaking others moduels here.

// Solution :- Step 1. Use extentions.

// Api Module
class ApiClient5 {
    
    static let shared = ApiClient5() // In swift "static let" is a constant and lazy loaded
    
    func execute(_ request: URLRequest , completion:(Data) -> Void) {}
    }


// Login Module
struct LoggedInUser {}

extension ApiClient5 {
    func login(completion: (LoggedInUser) -> Void) {}
}

class LoginViewController2: UIViewController {
    
    var api = ApiClient5.shared // So now we can inject a property in tests to Test this function, using MockApiClient.
    
    func didTapLogin() {
        
        api.login() { user in
                // show next screen
        }
    }
}

// Feed Module
struct FeedItem {}

extension ApiClient5 {
    
    func loadFeed(completion: ([FeedItem]) -> Void) {}
}

class FeedViewController2: UIViewController {
    
    var api = ApiClient5.shared
    
    override func viewDidLoad() {
         
        super.viewDidLoad()
        
        api.loadFeed { loadedFeeds in
            
        }
    }
}


/* As we are now separete modules by using extentions, we are safe now as we can add more api calls in extentions without breaking other modules.
 But, still ApiClient is shared among Modules, which might break in cases such as :- Adding -upload(request, data) method in  ApiCliet class, whic break all other.
 
 
 Solution:-  Step 2  Invert Dependecy:-
 
 */

// Main Module


class ApiClient6 {
    
    static let instance = ApiClient6()
}


extension ApiClient6 {
    func login(completion: (LoggedInUser) -> Void) {}
}


extension ApiClient6 {
    
    func loadFeed(completion: ([FeedItem]) -> Void) {}
}
// Login Module


class LoginViewController3: UIViewController {
    
    var login: (((LoggedInUser) -> Void) -> Void)?
    
    func didTapLogin() {
        
        login?() { user in
                // show next screen
        }
    }
}


// Main Module

class FeedViewController3: UIViewController {
    
    var loadFeed: (((FeedItem) -> Void) -> Void)?

    override func viewDidLoad() {
         
        super.viewDidLoad()
        
        loadFeed? { loadedFeeds in
            
        }
    }
}
