//
//  RuntimeTests.swift
//  DynamicXCTests-ExampleTests
//
//  Created by Denis Bogomolov on 20/03/2019.
//  Copyright © 2019 BDK. All rights reserved.
//

import Foundation
import XCTest

//todo: provider initializer init(provider: Method)
//todo: test initializer init(test: Method)
@objc public class RuntimeTests: ParametrizedTestCase,ParamTestProvider {

    
    //let argForMyTest:[String] = ["Super", "Confusing"] //no diff between functions and members
    
    func p(_ s: String) {
        print("Magic: \(s)")
    }

    dynamic public func getParamTests() -> [String: ParamTest] {
        
        let providerPrefix:String = "argFor"
        let paramPrefix:String = "param"
        let providerPrefixLen = String.Index(encodedOffset: 6)
        let paramPrefixLen = String.Index(encodedOffset: 5)
        var methodCount: UInt32 = 0
        var paramTests: [String: ParamTest] = [:]
        
        let methodList = class_copyMethodList(object_getClass(self), &methodCount)
        
        for index in 0..<numericCast(methodCount) {
            if let method : Method = methodList?[index] {

                let methodName:String = (method_getDescription(method).pointee as objc_method_description).name!.description
                print ("methodname: " + methodName)
                //verify # of args for provider (0 args)
                if (methodName.hasPrefix(providerPrefix)) {
                    var buf = [ Int8 ](repeating: 0, count: 46)
                    method_getReturnType(method, &buf, buf.count)
                    if String(cString: &buf) != "@" {
                        print("argFor func must have an object return type")
                    } else {
                        let testName = String(methodName[providerPrefixLen...])
                        addProvider(testName: String(testName), method: method, paramTests: &paramTests)
                    }
                } else if (methodName.hasPrefix(paramPrefix) && numericCast(method_getNumberOfArguments(method)) == 3) {
                    //regex fail for more than one "With"
                    let groups = methodName.groups(for: "param([A-Za-z0-9]+?)(With[A-Z].*:)")
                    let testName = groups[0][1]
                    addTest(testName: String(testName) as String, method: method, paramTests: &paramTests)
                }
            }
        }
        dump(paramTests)
        return paramTests
        //todo: verify all tests are matched with providers
    }
    
    func addTest(testName: String, method: Method, paramTests: inout [String:ParamTest]) {
        print("addtest" + testName)
        if let paramTest = paramTests[testName] {
            paramTest.test = method
        } else {
            //todo: use initializer with param arg
            let paramTest = ParamTest()
            paramTest.test = method
            paramTests.updateValue(paramTest, forKey: testName)
        }
    }
    
    //todo: check that arg matches return value
    func addProvider(testName: String, method: Method, paramTests: inout [String:ParamTest]) {
        print("addProvider" + testName)
        if let paramTest = paramTests[testName] {
            paramTest.dataProvider = method
        } else {
            //todo: use initializer with test arg
            let paramTest = ParamTest()
            paramTest.dataProvider = method
            paramTests.updateValue(paramTest, forKey: testName)
        }
    }
    
    //paramWith(WithAccount -> paramWithWithAccount
    //paramWith(Account -> paramWithAccount
    //param(Account -> paramWithAccount
    func paramMyTest(account:Account) {
        print(account.login);
        //print("Running with " + account.login)
    }
    
    func argForMyTest() -> [String:Account] {
        let anAccount = Account(login: "login",
                                password: "pass",
                                locale: "locale",
                                host: "host",
                                merchantName: "name"
        )
        let anotherAccount = Account(login: "login2",
                                     password: "password2",
                                     locale: "locale2",
                                     host: "host2",
                                     merchantName: "name2"
        )
        return ["first": anAccount, "second": anotherAccount]
    }
        
    func testBasic() {
        
    }
        
}

extension String {
    func groups(for regexPattern: String) -> [[String]] {
    do {
        let text = self
        let regex = try NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return matches.map { match in
            return (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
}
