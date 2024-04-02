//
//  EvalVisitor.swift
//  stone
//
//  Created by janezhuang on 2024/4/2.
//

import Foundation

enum EvalError: Error {
    case Default(String)
}

class EvalVisitor: Visitor {
    var result: Any?
    var env = EvalEnv()

    func visit(_ number: NumberLiteral) throws {
        result = number.number()
    }

    func visit(_ name: Name) throws {
        let token = name.token
        if token.type == .Number {
            result = token.value
        } else if token.type == .Identifier {
            result = env.get(name: token.value)
        } else {
            throw EvalError.Default("unknown token \(token.value)")
        }
    }

    func visit(_ string: StringLiteral) {
        result = string.string()
    }

    func visit(_ primary: PrimaryExpr) throws {
        try primary.child(0).accept(self)
    }

    func visit(_ binary: BinaryExpr) throws {
        let op = binary.op()
        if op == "=" {
            try binary.right().accept(self)

            let left = binary.left()
            if left is Name {
                env.put(name: (left as! Name).name(), value: result)
            } else if left is PrimaryExpr {
                env.put(name: (left.child(0) as! Name).name(), value: result)
            } else {
                throw EvalError.Default("bad assignment \(left)")
            }
            return
        }

        try binary.left().accept(self)
        let r1 = result as! Int
        try binary.right().accept(self)
        let r2 = result as! Int

        if op == "+" {
            result = r1 + r2
        } else if op == "-" {
            result = r1 - r2
        } else if op == "*" {
            result = r1 * r2
        } else if op == "/" {
            result = r1 / r2
        } else if op == "%" {
            result = r1 % r2
        } else if op == ">" {
            result = r1 > r2 ? 1 : 0
        } else if op == "<" {
            result = r1 < r2 ? 1 : 0
        } else if op == "==" {
            result = r1 == r2 ? 1 : 0
        } else if op == "||" {
            result = r1 > 0 || r2 > 0 ? 1 : 0
        } else if op == "&&" {
            result = r1 > 0 && r2 > 0 ? 1 : 0
        } else {
            throw EvalError.Default("bad operator \(op)")
        }
    }

    func visit(_ unary: UnaryExpr)throws {
        let op = unary.op()
        try unary.value().accept(self)
        if op == "!" {
            result = result as! Int == 0 ? 1 : 0
        } else if op == "-" {
            result = -(result as! Int)
        } else {
            throw EvalError.Default("bad operator \(op)")
        }
    }

    func visit(_ ifStmnt: IfStmnt) throws {
        try ifStmnt.condition().accept(self)
        if result as! Int > 0 {
            try ifStmnt.thenBlock().accept(self)
        } else {
            try ifStmnt.elseBlock()?.accept(self)
        }
    }

    func visit(_ whileStmnt: WhileStmnt) throws {
        repeat {
            try whileStmnt.condition().accept(self)
            if result as! Int == 0 {
                break
            }
            try whileStmnt.body().accept(self)
        } while (true)
    }
}
