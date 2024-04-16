//
//  NativeFunction.swift
//  stone
//
//  Created by janezhuang on 2024/4/8.
//

import Foundation

class NativeFunction {
    static var nativeMaps: [String: NativeFunction] = [ "print": NativeFunction_print(),
                                                        "array": NativeFunction_array(),
                                                        "arrayGet": NativeFunction_arrayGet(),
                                                        "arraySet": NativeFunction_arraySet() ]

    static func find(_ name: String) -> NativeFunction {
        return nativeMaps[name] ?? NativeFunction()
    }

    func invoke(args: [Any]) -> Any? {
        return nil
    }
}

class NativeFunction_print: NativeFunction {
    override func invoke(args: [Any]) -> Any? {
        print(args[0])
    }
}

class NativeFunction_array: NativeFunction {
    override func invoke(args: [Any]) -> Any? {
        let arr = NSMutableArray()
        for _ in 1...(args[0] as! Int) {
            arr.add("")
        }
        return arr
    }
}

class NativeFunction_arrayGet: NativeFunction {
    override func invoke(args: [Any]) -> Any? {
        let array = args[0] as! NSMutableArray
        return array[args[1] as! Int]
    }
}

class NativeFunction_arraySet: NativeFunction {
    override func invoke(args: [Any]) -> Any? {
        let array = args[0] as! NSMutableArray
        array[args[1] as! Int] = args[2]
        return nil
    }
}
