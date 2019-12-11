//
//  ParamTestProvider.swift
//  DynamicXCTests-ExampleTests
//
//  Created by Ostrowski, Nick on 12/9/19.
//  Copyright © 2019 BDK. All rights reserved.
//

import Foundation

@objc public protocol ParamTestProvider {
   func getParamTests() -> [String: ParamTest]
}
