//
//  main.swift
//  stone
//
//  Created by janezhuang on 2024/3/25.
//

import Foundation

do {
    let filePath = CommandLine.arguments[1]

    let lexer = Lexer(filePath: filePath)

    let parser = Parser(lexer: lexer)

    let ast = try parser.ast()

    let evalVisitor = EvalVisitor()
    try ast.accept(evalVisitor)
} catch {
    print(error)
}
