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

    init(filePath: String) {
        do {
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = data.components(separatedBy: .newlines)
            for (i, line) in lines.enumerated() {
                try readTokens(from: line, lineNum: i + 1)
            }
        } catch {
            print(error)
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
            let index = line.index(line.startIndex, offsetBy: pos)
            var char = line[index]

            if char == " " {
                pos += 1
                continue
            }
            // 单行注释
            if char == "/" {
                let nextIndex = line.index(line.startIndex, offsetBy: pos)
                let nextChar = line[nextIndex]
                if nextChar == "/" {
                    break
                }
            }

            if isSymbol(char: char) {
                queue.append(Token(type: .Symbol, value: String(char), lineNum: lineNum))
                pos+=1
                continue
            }

            if isDigit(char: char) {
                var target = ""

                repeat {
                    target.append(char)
                    pos += 1
                    let nextIndex = line.index(line.startIndex, offsetBy: pos)
                    char = line[nextIndex]
                } while (isDigit(char: char))

                queue.append(Token(type: .Number, value: target, lineNum: lineNum))
                continue
            }

            if isLetter(char: char) {
                var target = String(char)

                pos += 1
                while pos < line.count {
                    let nextIndex = line.index(line.startIndex, offsetBy: pos)
                    let nextChar = line[nextIndex]
                    if !isDigit(char: nextChar) && !isLetter(char: nextChar) {
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
                    var nextIndex = line.index(line.startIndex, offsetBy: pos)
                    var nextChar = line[nextIndex]
                    // 支持转义字符的解析
                    if nextChar == "\\" {
                        pos += 1
                        nextIndex = line.index(line.startIndex, offsetBy: pos)
                        nextChar = line[nextIndex]
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
    }

    func isSymbol(char: Character) -> Bool {
        return "{}()[].,;+-*/%&|<>=".contains(char)
    }

    func isDigit(char: Character) -> Bool {
        return char >= "0" && char <= "9"
    }

    func isLetter(char: Character) -> Bool {
        return (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
    }
}
