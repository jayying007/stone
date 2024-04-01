//
//  ASTree.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

protocol ASTree {

    func child(_ i: Int) -> ASTree

    func numChildren() -> Int
}

class ASTLeaf: ASTree {

    var token: Token

    required init(token: Token) {
        self.token = token
    }

    func child(_ i: Int) -> ASTree {
        assert(false) as! ASTree
    }

    func numChildren() -> Int {
        return 0
    }
}

class ASTList: ASTree {

    var children: [ASTree]

    required init(children: [ASTree]) {
        self.children = children
    }

    func child(_ i: Int) -> ASTree {
        return children[i]
    }

    func numChildren() -> Int {
        return children.count
    }
}
