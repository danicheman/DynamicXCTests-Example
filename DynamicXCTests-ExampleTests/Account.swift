//
//  Account.swift
//  DynamicXCTests-ExampleTests
//
//  Created by Ostrowski, Nick on 12/2/19.
//  Copyright © 2019 BDK. All rights reserved.
//

import Foundation

//must be a class extending NSObject
@objcMembers public class Account:NSObject {
    var something:String
    let login: String
    let password: String
    let locale: String
    let host: String
    let merchantName: String
    
    init(login:String, password:String, locale:String, host:String, merchantName:String) {
        self.something = "something"
        self.login = login
        self.password = password
        self.locale = locale
        self.host = host
        self.merchantName = merchantName
    }
    
    //name for arg
    override public var description: String {
        return locale
    }
}
