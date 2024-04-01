//
//  BinaryExpr.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class BinaryExpr: ASTList {

    func left() -> ASTree {
        return child(0)
    }

    func op() -> String {
        return (child(1) as! ASTLeaf).token.value

    }

    func right() -> ASTree {
        return child(2)
    }
}
