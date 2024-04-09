//
//  Visitor.swift
//  stone
//
//  Created by janezhuang on 2024/4/2.
//

import Foundation

protocol Visitor {

    func visit(_ number: NumberLiteral) throws

    func visit(_ name: Name) throws

    func visit(_ string: StringLiteral) throws

    func visit(_ primary: PrimaryExpr) throws

    func visit(_ binary: BinaryExpr) throws

    func visit(_ unary: UnaryExpr) throws

    func visit(_ ifStmnt: IfStmnt) throws

    func visit(_ whileStmnt: WhileStmnt) throws

    func visit(_ defStmnt: DefStmnt) throws

    func visit(_ arguments: Arguments) throws

    func visit(_ classStmnt: ClassStmnt) throws

    func visit(_ dot: Dot) throws
}
