# DynamicXCTests-Example
Example project for https://stackoverflow.com/questions/55142213/how-to-dynamically-add-xctestcase/55204082

An extension of ManWithBear's repository enabling dynamic testing

Create a swift object which is accessible to Objective C
```swift
//Account.swift
import Foundation

@objcMembers public class Account:NSObject {
    public var locale:String
    init(l:String) {
        locale = l
    }
    
    public override var description: String {
        return "account_\(locale)"
    }
}
```

Extend ParamTestsBase and write your own dynamic tests and argument providers

```swift
//make sure to use the objc annotation
@objc public class DynamicTests:ParamTestBase {

     //this is a parameterized test, it follows the convention
     //func param<testName>(_ a: arg)
     func paramTestAccount(_ a: Account) {
        //we can successfully access member of Account
        print("Magic: Account \(a.locale)")
        if (a.locale == "l1") {
            XCTFail("unexpected locale")
        }
    }
    
    //this is the argument provider for paramTestAccount
    //it follows the convention
    //class func argFor<testName>() -> [<argtype>]
    // it returns an array of arguments to be tested
    class func argForTestAccount() -> [Account] {
        let a1 = Account.init(l: "l1");
        let a2 = Account.init(l: "l2");
        return [a1,a2]
    }
    
    //one class can have multiple argFor/param test func pairs
    func paramTestAnotherAccount(_ a: Account) {
        //we can successfully access member of Account
        print("Magic: Account \(a.locale)")
        if (a.locale == "l1") {
            XCTFail("unexpected locale")
        }
    }
    
    class func argForTestAnotherAccount() -> [Account] {
        let a1 = Account.init(l: "l3");
        let a2 = Account.init(l: "l4");
        return [a1,a2]
    }
    
    //regular tests are also okay
    func testBadNews() {
        print("my regular test")
        XCTFail("test fail");
    }
    
    func testGoodNews() {
        print("Good news!")
    }
}
```
