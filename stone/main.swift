//
//  main.swift
//  stone
//
//  Created by janezhuang on 2024/3/25.
//

import Foundation

let filePath = CommandLine.arguments[1]

let lexer = Lexer(filePath: filePath)
while lexer.peek(i: 0).type != .EOF {
    print(lexer.read().value)
}
