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

    func invoke(args: [Any]) -> Any? {
        if selector == #selector(c_print) {
            print(args[0])
        }
        if selector == #selector(c_array) {
            let arr = NSMutableArray()
            for _ in 1...(args[0] as! Int) {
                arr.add("")
            }
            return arr
        }
        if selector == #selector(c_get) {
            let array = args[0] as! NSMutableArray
            return array[args[1] as! Int]
        }
        if selector == #selector(c_set) {
            let array = args[0] as! NSMutableArray
            array[args[1] as! Int] = args[2]
        }
        return nil
    }

    @objc func c_print(obj: Any) {
    }

    @objc func c_array(n: Int) {
    }

    @objc func c_get(array: [Any], index: Int) {
    }

    @objc func c_set(array: [Any], index: Int, value: Any) {
    }
}
