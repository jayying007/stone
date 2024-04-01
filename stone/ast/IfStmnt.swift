//
//  IfStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class IfStmnt: ASTList {

    func condition() -> ASTree {
        return child(0)
    }

    func thenBlock() -> ASTree {
        return child(1)
    }

    func elseBlock() -> ASTree? {
        return numChildren() > 2 ? child(2) : nil
    }
}
