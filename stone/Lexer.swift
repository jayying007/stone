//
//  Lexer.swift
//  stone
//
//  Created by janezhuang on 2024/3/25.
//

import Foundation

enum LexerError: Error {
    case UnknownCharacter(String)
    case InvalidEscape(String)
}

class Lexer {
    var queue = [Token]()

    init(filePath: String) throws {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        for (i, line) in lines.enumerated() {
            try readTokens(from: line, lineNum: i + 1)
        }
    }

    func read() -> Token {
        if queue.count == 0 {
            return Token(type: .EOF, value: "", lineNum: -1)
        }
        return queue.removeFirst()
    }

    func peek(i: Int) -> Token {
        if queue.count < i + 1 {
            return Token(type: .EOF, value: "", lineNum: -1)
        }
        return queue[i]
    }
}

extension Lexer {
    func readTokens(from line: String, lineNum: Int) throws {
        // 有限状态机
        var pos = 0
        while pos < line.count {
            var char = line.charAt(pos)
            // 跳过空格
            if char == " " {
                pos += 1
                continue
            }
            // 单行注释
            if char == "/" {
                let nextChar = line.charAt(pos + 1)
                if nextChar == "/" {
                    break
                }
            }

            if char.isSymbol() {
                if pos < line.count - 1 {
                    let twoCharOp = [ "==", "!=", "&&", "||" ]
                    let nextChar = line.charAt(pos + 1)
                    if twoCharOp.contains("\(char)\(nextChar)") {
                        queue.append(Token(type: .Symbol, value: "\(char)\(nextChar)", lineNum: lineNum))
                        pos += 2
                        continue
                    }
                }

                queue.append(Token(type: .Symbol, value: String(char), lineNum: lineNum))
                pos += 1
                continue
            }

            if char.isNumber {
                var target = ""

                repeat {
                    target.append(char)
                    pos += 1
                    if pos >= line.count {
                        break
                    }

                    char = line.charAt(pos)
                } while (char.isNumber)

                queue.append(Token(type: .Number, value: target, lineNum: lineNum))
                continue
            }

            if char.isLetter {
                var target = String(char)

                pos += 1
                while pos < line.count {
                    let nextChar = line.charAt(pos)
                    if !nextChar.isNumber && !nextChar.isLetter {
                        break
                    }
                    target.append(nextChar)
                    pos += 1
                }

                queue.append(Token(type: .Identifier, value: target, lineNum: lineNum))
                continue
            }

            if char == "\"" {
                var target = ""
                pos += 1
                while pos < line.count {
                    var nextChar = line.charAt(pos)
                    // 支持转义字符的解析
                    if nextChar == "\\" {
                        pos += 1
                        nextChar = line.charAt(pos)
                        if nextChar == "n" {
                            target.append("\n")
                        } else if nextChar == "\\" {
                            target.append("\\")
                        } else if nextChar == "\"" {
                            target.append("\"")
                        } else {
                            throw LexerError.InvalidEscape("Invalid escape sequence in literal: \\\(nextChar), line:\(lineNum)")
                        }
                        pos += 1
                        continue
                    }

                    if nextChar == "\"" {
                        break
                    }
                    target.append(nextChar)
                    pos += 1
                }
                pos += 1

                queue.append(Token(type: .String, value: target, lineNum: lineNum))
                continue
            }

            throw LexerError.UnknownCharacter("unknown char \(char) in line \(lineNum)")
        }
        queue.append(Token(type: .Identifier, value: Token.EOL, lineNum: lineNum))
    }
}

extension String {
    func charAt(_ index: Int) -> Character {
        let idx = self.index(self.startIndex, offsetBy: index)
        return self[idx]
    }
}

extension Character {
    func isSymbol() -> Bool {
        return "{}()[].,;+-*/%&|<>=!".contains(self)
    }
}
