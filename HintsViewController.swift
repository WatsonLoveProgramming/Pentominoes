//
//  HintsViewController.swift
//  Pentominoes
//
//  Created by Watson Li on 9/17/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

protocol HintsDelegate : class {
    func dismissHints()
}

class HintsViewController: UIViewController {
    
    @IBOutlet weak var hintBoardView: UIImageView!
    weak var delegate : HintsDelegate?
    let pentoModel = PentoModel()
    let boardSquareLength:CGFloat = 30
    var currentPuzzle: Int?
    var currentHint: Int?
    var hintBoardPieceView: [UIView] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        hintBoardView.image = UIImage.init(named: "Board\(currentPuzzle!)")
        
        //add all pieces into the Board's view array
        for i in 0..<currentHint! {
            let pieceImage = UIImage(named: pentoModel.pieceName(index: i)!)
            let pieceView = UIImageView(image: pieceImage)
            pieceView.frame = CGRect.zero
            pieceView.frame.size = pieceImage!.size
            pieceView.contentMode = .center
            hintBoardView.addSubview(pieceView)
            hintBoardPieceView.append(pieceView)
        }
        loadPieces()
    }

    //grab info from old view controller
    func configure(with _currentHint: Int, for _currentPuzzle: Int) {
        currentPuzzle = _currentPuzzle
        currentHint = _currentHint
    }
    
    func loadPieces(){
        if currentPuzzle != 0{
            pentoModel.solve(forBoard: currentPuzzle!)   //specify which puzzle is the user playing
        }
        
        //load each piece into the board according to the number of hints user clicked
        for i in 0..<currentHint! {
            hintBoardPieceView[i].center = hintBoardView.convert(hintBoardPieceView[i].center, from: hintBoardPieceView[i].superview)
            hintBoardView.addSubview(hintBoardPieceView[i])
            
            let xInfo = CGFloat(self.pentoModel.getPento(index: i)!.x)
            let yInfo = CGFloat(self.pentoModel.getPento(index: i)!.y)
            let rotationInfo = CGFloat(self.pentoModel.getPento(index: i)!.rotations)
            let flipsInfo = CGFloat(self.pentoModel.getPento(index: i)!.flips)
            let newPosition = CGPoint(x: hintBoardView.bounds.origin.x + boardSquareLength * xInfo,
                                      y: hintBoardView.bounds.origin.y + boardSquareLength * yInfo)
            
            let rotation = CGAffineTransform(rotationAngle: rotationInfo * ( CGFloat.pi / 2))
            let flip = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
            hintBoardPieceView[i].transform = Int(flipsInfo) == 1 ? flip.concatenating(rotation) : rotation
            hintBoardPieceView[i].frame = CGRect(x: newPosition.x,
                                                 y: newPosition.y,
                                                 width: hintBoardPieceView[i].frame.width,
                                                 height: hintBoardPieceView[i].frame.height)
        }
    }
    
    //dismiss this view
    @IBAction func dismiss(_ sender: Any) {
        if let delegate = delegate {
            delegate.dismissHints()
        }
    }

}
