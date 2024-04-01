//
//  main.swift
//  stone
//
//  Created by janezhuang on 2024/3/25.
//

import Foundation

let filePath = CommandLine.arguments[1]

let lexer = Lexer(filePath: filePath)

let parser = Parser(lexer: lexer)

do {
    let ast = try parser.ast()
    print(ast)
} catch {
    print(error)
}
