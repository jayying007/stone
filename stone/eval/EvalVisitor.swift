//
//  EvalVisitor.swift
//  stone
//
//  Created by janezhuang on 2024/4/2.
//

import Foundation

enum EvalError: Error {
    case Default(String)
    case Undefined(String)
}

class EvalVisitor: Visitor {
    var result: Any?
    var stack: [Environment]
    var env: Environment {
        get {
            stack.last!
        }
    }

    init() {
        self.stack = [Environment()]
        env.put(name: "printf", value: NativeFunction.find("print"))
        env.put(name: "array", value: NativeFunction.find("array"))
        env.put(name: "arrayGet", value: NativeFunction.find("arrayGet"))
        env.put(name: "arraySet", value: NativeFunction.find("arraySet"))
    }

    func visit(_ number: NumberLiteral) throws {
        result = number.number
    }

    func visit(_ name: Name) throws {
        let token = name.token
        if token.type == .Identifier {
            result = env.get(name: token.value)
        }
        if result == nil {
            throw EvalError.Undefined("token \(token.value)")
        }
    }

    func visit(_ string: StringLiteral) {
        result = string.string
    }
    // 形如a().b.c(d)
    func visit(_ primary: PrimaryExpr) throws {
        for child in primary.children {
            try child.accept(self)
        }
    }

    func visit(_ ifStmnt: IfStmnt) throws {
        try ifStmnt.condition.accept(self)
        guard let result = result as? Int else {
            throw EvalError.Default("expect expression, got \(String(describing: result))")
        }
        if result > 0 {
            try ifStmnt.thenBlock.accept(self)
        } else {
            try ifStmnt.elseBlock?.accept(self)
        }
    }

    func visit(_ whileStmnt: WhileStmnt) throws {
        repeat {
            try whileStmnt.condition.accept(self)
            guard let result = result as? Int else {
                throw EvalError.Default("expect expression, got \(String(describing: result))")
            }
            if result == 0 {
                break
            }
            try whileStmnt.body.accept(self)
        } while (true)
    }
}
// 数学运算
extension EvalVisitor {
    func visit(_ binary: BinaryExpr) throws {
        let op = binary.op
        if op == "=" {
            try computeAssign(binary)
            return
        }

        try binary.left.accept(self)
        let r1 = result
        try binary.right.accept(self)
        let r2 = result

        if r1 is Int && r2 is Int {
            try computeNumber(r1: r1 as! Int, r2: r2 as! Int, op: op)
        } else if op == "+" {
            result = String(describing: r1!) + String(describing: r2!)
        } else {
            throw EvalError.Default("bad binary expression \(binary.left) \(op) \(binary.right)")
        }
    }

    func visit(_ unary: UnaryExpr)throws {
        let op = unary.op
        try unary.value.accept(self)
        if op == "!" && result is Int {
            result = result as! Int == 0 ? 1 : 0
        } else if op == "-" && result is Int {
            result = -(result as! Int)
        } else {
            throw EvalError.Default("bad unary expression \(op) \(String(describing: result))")
        }
    }

    func computeAssign(_ binary: BinaryExpr) throws {
        try binary.right.accept(self)
        let value = result

        let left = binary.left
        if let left = left as? PrimaryExpr {
            // visit all postfix
            for (i, child) in left.children.enumerated() {
                if i == left.numChildren() - 1 {
                    break
                }
                try child.accept(self)
            }

            let lastChild = left.child(left.numChildren() - 1)
            if lastChild is Dot && result is StoneObject {
                let dot = lastChild as! Dot
                try (result as! StoneObject).write(member: dot.name, value: value)
            } else if lastChild is Name {
                env.put(name: (lastChild as! Name).name, value: value)
            } else {
                throw EvalError.Default("bad assignment \(left)")
            }
        } else {
            throw EvalError.Default("bad assignment \(left)")
        }
    }

    func computeNumber(r1: Int, r2: Int, op: String) throws {
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
        } else if op == "!=" {
            result = r1 != r2 ? 1 : 0
        } else {
            throw EvalError.Default("bad operator \(op)")
        }
    }
}
// 函数调用
extension EvalVisitor {
    func visit(_ defStmnt: DefStmnt) throws {
        let functionName = defStmnt.name
        let functionImp = Function(parameters: defStmnt.parameters, body: defStmnt.body, env: env)
        env.put(name: functionName, value: functionImp)
    }

    func visit(_ arguments: Arguments) throws {
        if let function = result as? NativeFunction {
            var args = [Any]()
            for child in arguments.children {
                try child.accept(self)
                args.append(result!)
            }
            result = function.invoke(args: args)
            return
        }

        if let function = result as? Function {
            let params = function.parameters

            let newEnv = Environment(env: function.env)
            for (i, child) in arguments.children.enumerated() {
                try child.accept(self)
                newEnv.putNew(name: params.name(i), value: result)
            }

            stack.append(newEnv)
            try function.body.accept(self)
            stack.removeLast()
            return
        }

        throw EvalError.Default("expect to be function: \(String(describing: result))")
    }
}
// 面向对象
extension EvalVisitor {
    func visit(_ classStmnt: ClassStmnt) throws {
        let className = classStmnt.name
        let classInfo = ClassInfo(definition: classStmnt, env: env)
        env.put(name: className, value: classInfo)
    }

    func visit(_ dot: Dot) throws {
        if result is ClassInfo && dot.name == "new" {
            let classInfo = result as! ClassInfo
            let newEnv = Environment(env: classInfo.env)
            let obj = StoneObject(env: newEnv)
            newEnv.putNew(name: "this", value: obj)

            stack.append(newEnv)
            try initObject(classInfo: classInfo)
            stack.removeLast()

            result = obj
            return
        }

        if result is StoneObject {
            result = try (result as! StoneObject).read(member: dot.name)
            return
        }

        throw EvalError.Default("unknown member \(result!)")
    }

    func initObject(classInfo: ClassInfo) throws {
        if classInfo.superClass != nil {
            try initObject(classInfo: classInfo.superClass!)
        }
        try classInfo.body().accept(self)
    }
}
