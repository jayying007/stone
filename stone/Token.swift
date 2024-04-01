//
//  Token.swift
//  stone
//
//  Created by janezhuang on 2024/3/25.
//

import Foundation

enum TokenType {
    case EOF
    // 字面量（如函数名、变量名、if/else）
    case Identifier
    // 数值
    case Number
    // 字符串
    case String
    // 标点符号
    case Symbol
}

class Token {

    static var EOL = "\n"

    var type: TokenType
    var value: String
    // debug info
    var lineNum: Int

    init(type: TokenType, value: String, lineNum: Int) {
        self.type = type
        self.value = value
        self.lineNum = lineNum
    }
}
