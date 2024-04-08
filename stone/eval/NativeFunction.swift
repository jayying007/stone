//
//  NativeFunction.swift
//  stone
//
//  Created by janezhuang on 2024/4/8.
//

import Foundation

class NativeFunction: NSObject {
    var selector: Selector

    init(selector: Selector) {
        self.selector = selector
    }

    func invoke(args: [Any]) -> AnyObject {
        return self.perform(selector, with: args[0]).takeRetainedValue()
    }

    @objc func c_print(obj: Any) {
        print(obj)
    }
}
