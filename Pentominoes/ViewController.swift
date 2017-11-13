//
//  ViewController.swift
//  Pentominoes
//
//  Created by Watson Li on 9/8/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HintsDelegate {
    
    @IBOutlet weak var board: UIImageView!      //main board to display solution
    @IBOutlet weak var selectBoard: UIView!     //botton panel to display all pentominoes
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var hintsButton: UIButton!
    @IBOutlet var boardButton: [UIButton]!
    
    let pentoModel = PentoModel()
    let boardSquareLength:CGFloat = 30
    let piecePadding: CGFloat = 20.0
    let moveScaleUpFactor: CGFloat = 1.2
    let moveScaleDownFactor: CGFloat = 1 / 1.2
    let numberOfPieceViews = 12
    let numberOfPieceRow = 2
    let numberOfPieceCol = 6
    let numberOfBoard = 6
    var currentHint = 0
    var currentPuzzle = 0
    var selectBoardView: [UIView] = []
    var oldPosition: [CGPoint] = [] //record position at the botton board for "reset"
    var currentRotation: [CGFloat] = []
    var currentFlip: [Bool] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.isUserInteractionEnabled = true
        
        //add all pieces into the mainBoard's view and set their frames
        for i in 0..<numberOfPieceViews {
            let pieceImage = UIImage(named: pentoModel.pieceName(index: i)!)
            let pieceView = UIImageView(image: pieceImage)
            pieceView.frame = CGRect.zero
            pieceView.frame.size = pieceImage!.size
//            pieceView.contentMode = .center
//            pieceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            selectBoard.addSubview(pieceView)
            selectBoardView.append(pieceView)
            currentRotation.append(0)
            currentFlip.append(false)

            //add pan gesture
            pieceView.isUserInteractionEnabled = true
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.movePiece(_:)))
            pieceView.addGestureRecognizer(panGesture)
            
            //add single tap gesture
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.rotatePiece(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            pieceView.addGestureRecognizer(singleTapGesture)
            
            //add double tap gesture
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipPiece(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            singleTapGesture.require(toFail: doubleTapGesture)
            pieceView.addGestureRecognizer(doubleTapGesture)
        }
        
        board.image = UIImage.init(named: "Board\(currentPuzzle)")
        solveButton.isEnabled = false
        hintsButton.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //resize the pieces'frame and add them to the selectBoard with paddings
        let selectBoardSize = selectBoard.bounds.size
        let pieceWidth = selectBoardSize.width / CGFloat(numberOfPieceCol)
        let pieceHeight = selectBoardSize.height / CGFloat(numberOfPieceRow)
        
        for i in 0..<numberOfPieceViews {
            let pieceCol = i % numberOfPieceCol
            let pieceRow = i / numberOfPieceCol
            let x = CGFloat(pieceCol) * pieceWidth
            let y = CGFloat(pieceRow) * pieceHeight
            let pieceview = selectBoardView[i]
            
            pieceview.frame = CGRect(x: x + piecePadding,
                                     y: y + piecePadding,
                                     width: pieceview.frame.width,
                                     height: pieceview.frame.height)
            oldPosition.append(CGPoint(x: pieceview.frame.minX,y: pieceview.frame.minY))
        }
        resetButton.isEnabled = false
    }
    
    
    /*
     This method executes when user changes a board (the puzzle)
     */
    @IBAction func changeBoard(_ sender: UIButton) {
        currentPuzzle = sender.tag
        currentHint = 0
        board.image = UIImage.init(named: "Board\(currentPuzzle)")
        if(currentPuzzle != 0){
            solveButton.isEnabled = true
            hintsButton.isEnabled = true
        }else{
            solveButton.isEnabled = false
            hintsButton.isEnabled = false
        }
    }
    
    /*
     This method move all pentominos to the main board to solve the puzzle
     */
    @IBAction func solvePuzzle(_ sender: UIButton) {
        sender.isEnabled = false
        resetButton.isEnabled = false
        for button in boardButton {
            button.isEnabled = false
        }
        
        self.board.layer.zPosition = 1
        if currentPuzzle != 0{
            pentoModel.solve(forBoard: currentPuzzle)   //specify which puzzle is the user playing
        }
        
        for i in 0..<numberOfPieceViews {
            //change superview of pentos to the mainBoard
            selectBoardView[i].center = board.convert(selectBoardView[i].center, from: selectBoardView[i].superview)
            board.addSubview(selectBoardView[i])
            
            //get infomation x,y coordinates and rotation, flip from model
            let xInfo = CGFloat(self.pentoModel.getPento(index: i)!.x)
            let yInfo = CGFloat(self.pentoModel.getPento(index: i)!.y)
            let rotationInfo = CGFloat(self.pentoModel.getPento(index: i)!.rotations)
            let flipsInfo = CGFloat(self.pentoModel.getPento(index: i)!.flips)
            
            //final position in mainBoard after translation
            let newPosition = CGPoint(x: board.bounds.origin.x + boardSquareLength * xInfo,
                                      y: board.bounds.origin.y + boardSquareLength * yInfo)
            
            //animation
            UIView.animate(withDuration: 2, animations: {
                let rotation = CGAffineTransform(rotationAngle: rotationInfo * ( CGFloat.pi / 2))
                let flip = CGAffineTransform(scaleX: -1.0, y: 1.0)
                
                self.selectBoardView[i].transform = Int(flipsInfo) == 1 ? flip.concatenating(rotation) : rotation
                self.selectBoardView[i].frame = CGRect(x: newPosition.x,
                                                       y: newPosition.y,
                                                       width: self.selectBoardView[i].frame.width,
                                                       height: self.selectBoardView[i].frame.height)
            }, completion: {(finished) in
                self.resetButton.isEnabled = true
                self.board.layer.zPosition = -1
            })
        }
        
    }
    
    /*
     This method move all pentominos back to the select board
     */
    @IBAction func resetPuzzle(_ sender: UIButton) {
        sender.isEnabled = false
        if currentPuzzle != 0{
            pentoModel.solve(forBoard: currentPuzzle)
        }
        
        for i in 0..<numberOfPieceViews {
            //change superview of pentos back to the selectBoard
            selectBoardView[i].center = selectBoard.convert(selectBoardView[i].center, from: selectBoardView[i].superview)
            selectBoard.addSubview(selectBoardView[i])
            
            //animation
            UIView.animate(withDuration: 2, animations: {
                self.selectBoardView[i].transform = CGAffineTransform.identity
                
                self.selectBoardView[i].frame = CGRect(x: self.oldPosition[i].x,
                                                       y: self.oldPosition[i].y,
                                                       width: self.selectBoardView[i].frame.width,
                                                       height: self.selectBoardView[i].frame.height)
            }, completion: {(finished) in
                self.solveButton.isEnabled = true
                self.resetButton.isEnabled = false
                for button in self.boardButton {
                    button.isEnabled = true
                }
            })
        }
        
    }
    
    //call when user rotates the piece
    func rotatePiece(_ sender: UITapGestureRecognizer) {
        //single tap to rotate the piece 90 degrees
        let piece = sender.view!
        if let index = self.selectBoardView.index(of: piece){
            currentRotation[index] = (currentRotation[index] + 1).truncatingRemainder(dividingBy: 4)
            UIView.animate(withDuration: 0.5, animations: {
                let rotation = CGAffineTransform (rotationAngle: self.currentRotation[index] * (CGFloat.pi / 2))
                self.selectBoardView[index].transform = rotation
            })
        }
    }
    
    //call when user flips the piece
    func flipPiece(_ sender: UITapGestureRecognizer) {
        //double tap to flip a piece over
        let piece = sender.view!
        if let index = self.selectBoardView.index(of: piece){
            currentFlip[index] = !currentFlip[index]
            UIView.animate(withDuration: 0.5, animations: {
                let flip = self.currentFlip[index] ? CGAffineTransform(scaleX: -1.0, y: 1.0) : CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.selectBoardView[index].transform = flip
            })
        }
    }
    
    //call when user moves the piece
    func movePiece(_ sender: UIPanGestureRecognizer) {
        let piece = sender.view!
        switch sender.state {
            case .began:  // scale up
                piece.transform = piece.transform.concatenating(CGAffineTransform(scaleX: moveScaleUpFactor, y: moveScaleUpFactor))

            case .changed:  //moving a piece
                piece.center = sender.location(in: piece.superview)
            
            case .ended:  //scale down
                piece.transform = piece.transform.concatenating(CGAffineTransform(scaleX: moveScaleDownFactor, y: moveScaleDownFactor))
                let newOrigin = (self.board.convert(piece.frame.origin, from: piece.superview))
                piece.frame = CGRect(x: newOrigin.x,
                                     y: newOrigin.y,
                                     width: piece.frame.width,
                                     height: piece.frame.height)
                let testRect = CGRect(x: newOrigin.x + self.board.frame.origin.x,
                                     y: newOrigin.y + self.board.frame.origin.y,
                                     width: piece.frame.width,
                                     height: piece.frame.height)
                
                if board.frame.contains(testRect){      //move and snap onto board
                    board.addSubview(piece)
                    let snapPoint = CGPoint(x: boardSquareLength * floor((newOrigin.x / boardSquareLength) + 0.5),
                                            y: boardSquareLength * floor((newOrigin.y / boardSquareLength) + 0.5));
                    UIView.animate(withDuration: 0.5, animations: {
                        piece.frame = CGRect(x:snapPoint.x, y:snapPoint.y, width:piece.frame.size.width, height:piece.frame.size.height)

                    })
                }else{                                  //move back to home position
                    let oldOrigin = (self.selectBoard.convert(piece.frame.origin, from: self.board))
                    piece.frame = CGRect(x: oldOrigin.x,
                                         y: oldOrigin.y,
                                         width: piece.frame.width,
                                         height: piece.frame.height)
                    UIView.animate(withDuration: 0.5, animations: {
                        let index = self.selectBoardView.index(of: piece)
                        self.selectBoardView[index!].frame = CGRect(x: self.oldPosition[index!].x,
                                                               y: self.oldPosition[index!].y,
                                                               width: self.selectBoardView[index!].frame.width,
                                                               height: self.selectBoardView[index!].frame.height)
                    })
                }
            
            default:
                break
        }
    }
    
    //switch to hint view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        currentHint = currentHint < 12 ? currentHint + 1 : currentHint
        let hintsViewController = segue.destination as! HintsViewController
        hintsViewController.configure(with: currentHint, for: currentPuzzle)
        hintsViewController.delegate = self
    }
    
    //dismiss hint view
    func dismissHints() {
        dismiss(animated: true, completion: nil)
    }
    
}






