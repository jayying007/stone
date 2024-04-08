//
//  ParameterList.swift
//  stone
//
//  Created by janezhuang on 2024/4/7.
//

import Foundation

class ParameterList: ASTList {

    func name(_ i: Int) -> String {
        return (child(i) as! ASTLeaf).token.value
    }
}
