//
//  UnaryExpr.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class UnaryExpr: ASTList {

    func op() -> String {
        return (child(0) as! ASTLeaf).token.value
    }

    func value() -> ASTree {
        return child(1)
    }
}
