//
//  PentoModel.swift
//  Pentominoes
//
//  Created by Watson Li on 9/8/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import Foundation

//pentominos struct
struct Pento {
    var shape: String
    var x: Int
    var y: Int
    var rotations: Int
    var flips: Int
}

class PentoModel {
    let boardCount = 6
    let pieceCount = 12
    let puzzleCount = 5
    private let boards: [String]
    private let piecesName: [String]
    private let tileShape: [Character]
    private let solution: [Dictionary<String,AnyObject>]
    private var pieceInfo: [Pento] = []
    
    init() {
        var _boards = [String]()
        var _piecesName = [String]()
        tileShape = ["X","V","T","U","N","Y","L","I","F","W","Z","P"]
        
        //add the six boards into an array
        for i in 0..<boardCount {
            _boards.append("Board\(i)")
        }
        
        //add the twelve pentominoes into an array
        for letter in tileShape {
            _piecesName.append("Piece\(letter)")
        }
        boards = _boards
        piecesName = _piecesName
        
        //get the solution info from plist file
        let filepath = Bundle.main.path(forResource: "Solutions", ofType: "plist")
        solution = (NSArray(contentsOfFile: filepath!) as? Array<Dictionary<String,AnyObject>>)!
        
    }
    
    /*
     This method return a specify board among the six boards
     */
    func boardName(index i:Int) -> String? {
        guard boards.indices.contains(i) else {return nil}
        return boards[i]
    }
    
    /*
     This method return a pentomino name
     */
    func pieceName(index i:Int) -> String? {
        guard piecesName.indices.contains(i) else {return nil}
        return piecesName[i]
    }
    
    /*
     This method return a pentomino struct
     */
    func getPento(index i:Int) -> Pento? {
        guard pieceInfo.indices.contains(i) else {return nil}
        return pieceInfo[i]
    }
    
    /*
     This method create structs from the solution
     */
    func solve(forBoard i:Int) {
        pieceInfo.removeAll()
        let pieceDict = solution[i - 1]
        
        for piece in pieceDict{
            let info = piece.value as! Dictionary<String,Int>
            let pento = Pento(shape:piece.key, x:info["x"]!, y:info["y"]!, rotations:info["rotations"]!, flips:info["flips"]!)
            pieceInfo.append(pento)
        }
    }
    
}
