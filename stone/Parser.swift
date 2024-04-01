//
//  Parser.swift
//  stone
//
//  Created by janezhuang on 2024/3/28.
//

import Foundation

enum ParserError: Error {
    case Default(String)
    case OrNotMatch(String)
    case UnExpectedToken(String)
    case TokenNotMatch(String)
}

class Parser {

    var lexer: Lexer

    init(lexer: Lexer) {
        self.lexer = lexer
    }

    func ast() throws -> ASTree {
        let parseImpl = ParserDSL.program

        var astList = [ASTree]()

        while lexer.peek(i: 0).type != .EOF {
            if let ast = try parseImpl.parse(lexer: lexer) {
                astList.append(ast)
            }
        }

        return astList.count == 1 ? astList[0] : ASTList(children: astList)
    }
}

// parse 组合子
class ParserDSL {
    // 语法规则
    static var binaryOps: Operators = {
        let ops = Operators()
        ops.add(name: "=", prec: 1, leftAccoc: Operators.RIGHT)
        ops.add(name: "&&", prec: 1, leftAccoc: Operators.LEFT)
        ops.add(name: "||", prec: 1, leftAccoc: Operators.LEFT)
        ops.add(name: "==", prec: 2, leftAccoc: Operators.LEFT)
        ops.add(name: ">", prec: 2, leftAccoc: Operators.LEFT)
        ops.add(name: "<", prec: 2, leftAccoc: Operators.LEFT)
        ops.add(name: "+", prec: 3, leftAccoc: Operators.LEFT)
        ops.add(name: "-", prec: 3, leftAccoc: Operators.LEFT)
        ops.add(name: "*", prec: 4, leftAccoc: Operators.LEFT)
        ops.add(name: "/", prec: 4, leftAccoc: Operators.LEFT)
        ops.add(name: "%", prec: 4, leftAccoc: Operators.LEFT)
        return ops
    }()
    static var unaryOps = [ "-", "!" ]

    static var expr0 = rule("expr")
    static var primary = rule(PrimaryExpr.self).or(rule().sep("(").ast(expr0).sep(")"),
                                                   rule().number(cls: NumberLiteral.self),
                                                   rule().identifier(cls: Name.self),
                                                   rule().string(cls: StringLiteral.self))
    static var factor = rule("factor").or(rule("UnaryExpr").unary(cls: UnaryExpr.self, subExpr: primary, operators: unaryOps), primary)
    static var expr = expr0.expression(cls: BinaryExpr.self, subExpr: factor, operators: binaryOps)

    static var statement0 = rule("statement")
    static var block = rule(BlockStmnt.self).sep("{").option(statement0).repeats(rule().sep(";", Token.EOL).option(statement0)).sep("}")
    static var statement = statement0.or(rule(IfStmnt.self).sep("if").ast(expr).ast(block).option(rule().sep("else").ast(block)),
                                         rule(WhileStmnt.self).sep("while").ast(expr).ast(block),
                                         expr)
    static var program = rule("program").or(statement, rule(NullStmnt.self)).sep(";", Token.EOL)
    //
    var name: String?
    var elements = [Element]()
    var cls: ASTree.Type?

    init(name: String? = nil, elements: [any ParserDSL.Element] = [Element](), cls: ASTree.Type?) {
        self.elements = elements
        self.cls = cls
        self.name = (name != nil) ? name! : String(describing: cls)
    }

    func parse(lexer: Lexer) throws -> ASTree? {
        var astList = [ASTree]()

        for element in elements {
            try element.parse(lexer: lexer, res: &astList)
        }

        if astList.count == 0 {
            return nil
        } else if astList.count == 1 && (cls == nil || cls is ASTLeaf.Type) {
            return astList[0]
        } else {
            return (cls as! ASTList.Type).init(children: astList)
        }
    }

    func match(lexer: Lexer) -> Bool {
        // 匹配空语句
        if elements.count == 0 {
            return true
        }
        return elements[0].match(lexer: lexer)
    }

    static func rule() -> ParserDSL {
        return rule("", nil)
    }

    static func rule(_ cls: ASTree.Type?) -> ParserDSL {
        let parser = ParserDSL(name: nil, cls: cls)
        return parser
    }

    static func rule(_ name: String) -> ParserDSL {
        return rule(name, nil)
    }

    static func rule(_ name: String, _ cls: ASTree.Type?) -> ParserDSL {
        let parser = ParserDSL(name: name, cls: cls)
        return parser
    }

    func sep(_ strings: String...) -> ParserDSL {
        elements.append(Skip(tokens: strings))
        return self
    }

    func or(_ parsers: ParserDSL...) -> ParserDSL {
        elements.append(OrTree(parsers: parsers))
        return self
    }

    func option(_ p: ParserDSL) -> ParserDSL {
        elements.append(Repeat(parser: p, onlyOnce: true))
        return self
    }

    func repeats(_ p: ParserDSL) -> ParserDSL {
        elements.append(Repeat(parser: p, onlyOnce: false))
        return self
    }

    func ast(_ p: ParserDSL) -> ParserDSL {
        elements.append(Tree(parser: p))
        return self
    }

    func number(cls: ASTree.Type) -> ParserDSL {
        elements.append(NumToken(cls: cls))
        return self
    }

    func identifier(cls: ASTree.Type) -> ParserDSL {
        elements.append(IdToken(cls: cls))
        return self
    }

    func string(cls: ASTree.Type) -> ParserDSL {
        elements.append(StrToken(cls: cls))
        return self
    }

    func expression(cls: ASTree.Type, subExpr: ParserDSL, operators: Operators) -> ParserDSL {
        elements.append(Expr(cls: cls, factor: subExpr, ops: operators))
        return self
    }

    func unary(cls: ASTree.Type, subExpr: ParserDSL, operators: [String]) -> ParserDSL {
        elements.append(UnaryExpression(cls: cls, factor: subExpr, ops: operators))
        return self
    }
}

// parse 组合子实现
extension ParserDSL {

    protocol Element {
        // 使用该元素解析
        func parse(lexer: Lexer, res: inout [ASTree]) throws
        // 检测是否可以使用该元素解析
        func match(lexer: Lexer) -> Bool
    }

    class Tree: Element {
        var parser: ParserDSL

        init(parser: ParserDSL) {
            self.parser = parser
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            if let ast = try parser.parse(lexer: lexer) {
                res.append(ast)
            }
        }

        func match(lexer: Lexer) -> Bool {
            return parser.match(lexer: lexer)
        }
    }

    class OrTree: Element {
        var parsers: [ParserDSL]

        init(parsers: [ParserDSL]) {
            self.parsers = parsers
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            let parser = findMatchedParser(lexer: lexer)
            if parser == nil {
                throw ParserError.OrNotMatch("token:\(lexer.peek(i: 0)) don't match any option")
            } else {
                if let ast = try parser!.parse(lexer: lexer) {
                    res.append(ast)
                }
            }
        }

        func match(lexer: Lexer) -> Bool {
            return findMatchedParser(lexer: lexer) != nil
        }

        func findMatchedParser(lexer: Lexer) -> ParserDSL? {
            for parser in parsers {
                if parser.match(lexer: lexer) {
                    return parser
                }
            }
            return nil
        }
    }

    class Repeat: Element {
        var parser: ParserDSL
        var onlyOnce: Bool

        init(parser: ParserDSL, onlyOnce: Bool) {
            self.parser = parser
            self.onlyOnce = onlyOnce
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            while match(lexer: lexer) {
                if let ast = try parser.parse(lexer: lexer) {
                    res.append(ast)
                }
                if onlyOnce {
                    break
                }
            }
        }

        func match(lexer: Lexer) -> Bool {
            return parser.match(lexer: lexer)
        }
    }

    class Leaf: Element {
        var tokens: [String]

        init(tokens: [String]) {
            self.tokens = tokens
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            let token = lexer.read()
            if token.type == .Identifier || token.type == .Symbol {
                for tk in tokens {
                    if token.value == tk {
                        find(token: token, res: &res)
                        return
                    }
                }
            }
            throw ParserError.UnExpectedToken("expect \(tokens[0]), got (\(token.type),\(token.value))")
        }

        func match(lexer: Lexer) -> Bool {
            let token = lexer.peek(i: 0)
            if token.type == .Identifier || token.type == .Symbol {
                for tk in tokens {
                    if token.value == tk {
                        return true
                    }
                }
            }
            return false
        }

        func find(token: Token, res: inout [any ASTree]) {
            res.append(ASTLeaf(token: token))
        }
    }

    class Skip: Leaf {
        override func find(token: Token, res: inout [any ASTree]) {

        }
    }

    class UnaryExpression: Element {
        var cls: ASTree.Type
        var factor: ParserDSL
        var ops: [String]

        init(cls: ASTree.Type, factor: ParserDSL, ops: [String]) {
            self.cls = cls
            self.factor = factor
            self.ops = ops
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            var astList = [ASTree]()
            astList.append(ASTLeaf(token: lexer.read()))
            guard let ast = try factor.parse(lexer: lexer) else {
                throw ParserError.Default("不是一个primary")
            }
            astList.append(ast)

            res.append((cls as! ASTList.Type).init(children: astList))
        }

        func match(lexer: Lexer) -> Bool {
            let token = lexer.peek(i: 0)
            if token.type == .Symbol {
                for op in ops {
                    if op == token.value {
                        return true
                    }
                }
            }
            return false
        }
    }

    class Expr: Element {
        var cls: ASTree.Type
        var factor: ParserDSL
        var ops: Operators

        init(cls: ASTree.Type, factor: ParserDSL, ops: Operators) {
            self.cls = cls
            self.factor = factor
            self.ops = ops
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            guard var right = try factor.parse(lexer: lexer) else {
                return
            }

            while true {
                let prec = nextOperator(lexer: lexer)
                if prec != nil {
                    right = try doShift(lexer: lexer, left: right, prec: prec!.value)
                } else {
                    break
                }
            }

            res.append(right)
        }

        func match(lexer: Lexer) -> Bool {
            return factor.match(lexer: lexer)
        }

        func doShift(lexer: Lexer, left: ASTree, prec: Int) throws -> ASTree {
            var astList = [ASTree]()
            astList.append(left)
            astList.append(ASTLeaf(token: lexer.read()))

            var right = try factor.parse(lexer: lexer)!
            while true {
                let nextPrec = nextOperator(lexer: lexer)
                guard let nextPrec = nextPrec else {
                    break
                }
                // 下一个操作符优先级更高，合并right
                if rightIsExpr(prec: prec, nextPrec: nextPrec) {
                    right = try doShift(lexer: lexer, left: right, prec: nextPrec.value)
                } else {
                    break
                }
            }
            astList.append(right)

            return (cls as! ASTList.Type).init(children: astList)
        }

        func nextOperator(lexer: Lexer) -> Precedence? {
            let token = lexer.peek(i: 0)
            if token.type == .Symbol {
                return ops.get(name: token.value)
            } else {
                return nil
            }
        }

        func rightIsExpr(prec: Int, nextPrec: Precedence) -> Bool {
            if nextPrec.leftAssoc {
                return prec < nextPrec.value
            } else {
                return prec <= nextPrec.value
            }
        }
    }

    class Precedence {
        var value: Int
        var leftAssoc: Bool; // left associative

        init(value: Int, leftAssoc: Bool) {
            self.value = value
            self.leftAssoc = leftAssoc
        }
    }

    class Operators {
        static var LEFT = true
        static var RIGHT = false
        var ops = [String: Precedence]()

        func add(name: String, prec: Int, leftAccoc: Bool) {
            ops[name] = Precedence(value: prec, leftAssoc: leftAccoc)
        }

        func get(name: String) -> Precedence? {
            return ops[name]
        }
    }

    class AToken: Element {
        var cls: ASTree.Type

        init(cls: ASTree.Type) {
            self.cls = cls
        }

        func parse(lexer: Lexer, res: inout [any ASTree]) throws {
            let token = lexer.read()
            if test(token: token) {
                res.append((cls as! ASTLeaf.Type).init(token: token))
            } else {
                throw ParserError.TokenNotMatch("token:\(token)")
            }
        }

        func match(lexer: Lexer) -> Bool {
            let token = lexer.peek(i: 0)
            return test(token: token)
        }

        func test(token: Token) -> Bool {
            assert(false, "override by subclass")
            return false
        }
    }

    class IdToken: AToken {
        override func test(token: Token) -> Bool {
            return token.type == .Identifier && token.value != "\n"
        }
    }

    class NumToken: AToken {
        override func test(token: Token) -> Bool {
            return token.type == .Number
        }
    }

    class StrToken: AToken {
        override func test(token: Token) -> Bool {
            return token.type == .String
        }
    }
}
