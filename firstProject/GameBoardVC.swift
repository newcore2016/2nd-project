//
//  ViewController.swift
//  firstProject
//
//  Created by Tri on 10/13/16.
//  Copyright © 2016 efode. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class GameBoardVC: UIViewController {

    var cellGameArray = Array<CellGame>()
    
    var colNo = 2 // default column number
    
    var rowNo = 2 // default row number
    
    var image =  UIImage() // current playing image
    
    var boardGame = UIImageView()
    
    var isSecondClick = false // check if there is second click
    
    var previousCell : CellGame! // store previous cliked cell info
    
    var switchSound: AVAudioPlayer! // sound of switching tiles
    
    var successSound: AVAudioPlayer! // success sound
    
    var winningSound: AVAudioPlayer! // winning sound
    
    var seconds:Float = 0.0 // time on second
    
    var timer = Timer() // timer object
    
    var isFirstTap = true // check if first tab to active timer
    
    let timerBar = UIProgressView()
    
    // ------New feature: Random photo from list-----------------
    var playMode = 0 // 0: Tính giờ, 1: Không tính giờ
    var playLevel = 0 // 0: Dễ, 1: Khó
    var catalogue: Catalogue!
    var unsolvedImageList:[Image]!
    var solvedImageList = [Image]()
    var doingImage: Image!
    let numUpLevel = 3 // Number of solved images to increase level
    var upLevelTimes = 1 // Number of times of leveling
    let timeLimit:Float = 30 // seconds
    var firstCell: CellGame!
    var newCell: CellGame!
    var scoreLabel = UILabel()
    var score:Int = 0
    //------------------------------------------------------------
    
    //let imageView = UIImageView() // UIImange for reference original image
    // Switch sound
    var switchPath: String!
    var switchURL: URL!
    
    // Success Sound
    var successUrl: URL!
    var successPath: String!
    
    // Winning sound
    var winningPath: String!
    var winningURL: URL!
    var gameOverMenu: UIView!
    var audioBtn: UIButton!
    
    //audio
    var audioSound: AVAudioPlayer!
    var audioPath: String!
    var audioURL: URL!
    
    //continue button
    var continueBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, at: 0)
        // Switch sound
        switchPath = Bundle.main.path(forResource: "switch", ofType: "wav")
        switchURL = URL(fileURLWithPath: switchPath!)
        // Sinning sound
        winningPath = Bundle.main.path(forResource: "won", ofType: "wav")
        winningURL = URL(fileURLWithPath: winningPath!)
        successPath = Bundle.main.path(forResource: "success", ofType: "wav")
        successUrl = URL(fileURLWithPath: successPath!)
        createGame()
        
    }
    
    func createGame() {
        // Easy level
        if playLevel == 0 {
            colNo = 2
            rowNo = 2
        } else {
            // hard level
            colNo = 4
            rowNo = 4
        }
        // ------New feature: Random photo from list-----------------
        // load image list
        getImageListFromCatalogue()
        let randomIndex = random(max: unsolvedImageList.count)
        doingImage = unsolvedImageList.remove(at: randomIndex)
        image = UIImage(named: doingImage.fileName!)!
        // ----------------------------------------------------------
        self.view.isUserInteractionEnabled = true
        self.boardGame.isUserInteractionEnabled = true
        
        if(score > 0){
            scoreLabel.text = "\(score)"
        }else{
            scoreLabel.text = "0"
        }
        
        scoreLabel.font = UIFont(name: scoreLabel.font.fontName, size: 20)
        scoreLabel.frame = CGRect(x: UIScreen.main.bounds.width * 0.6, y: UIScreen.main.bounds.height * 0.01 , width: 50, height: 30)
        scoreLabel.textAlignment = .center
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.textColor = UIColor.white
        self.view.addSubview(scoreLabel)
        makeGameBoard()
        self.view.insertSubview(boardGame, at: 1)
        // --------- TODO ----------
        let advertiment = UILabel()
        advertiment.text = "Advertiment here!"
        advertiment.textAlignment = .center
        advertiment.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 30, width: UIScreen.main.bounds.width, height: 30)
        self.view.addSubview(advertiment)
        // -----------------------
        do {
            try switchSound = AVAudioPlayer(contentsOf: switchURL)
            try winningSound = AVAudioPlayer(contentsOf: winningURL)
            try successSound = AVAudioPlayer(contentsOf: successUrl)
        } catch(let err as NSError) {
            print(err.debugDescription)
        }
        playWinningSound() // FIXME change to welcome sound
    }
    
    // play switch cells sound
    func playSwitchSound() {
        if switchSound.isPlaying {
            switchSound.stop()
            do {
                try switchSound = AVAudioPlayer(contentsOf: switchURL)
            } catch(let err as NSError) {
                print(err.debugDescription)
            }
        }
        switchSound.play()
    }
    
    // play success sound
    func playSuccessSound() {
        if successSound.isPlaying {
            successSound.stop()
            do {
                try successSound = AVAudioPlayer(contentsOf: successUrl)
            } catch(let err as NSError) {
                print(err.debugDescription)
            }
        }
        successSound.play()
    }
    
    // play winning sound
    func playWinningSound() {
        if winningSound.isPlaying {
            winningSound.stop()
            do {
                try winningSound = AVAudioPlayer(contentsOf: winningURL)
            } catch(let err as NSError) {
                print(err.debugDescription)
            }
        }
        winningSound.play()
    }
    
    // cell tapped event
    func tapDetected(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let img = imageView.image
        let point = sender.location(in: imageView)
//        let point1 = sender.location(in: imageView)
        let color = imageView.getPixelColorAtPoint(point: point)
        scoreLabel.textColor = color

    }
    
    // find suiable point based on x, y in board game
    func findPoint(x: Int, y: Int) -> CGPoint {
        var point = CGPoint()
        point.x = boardGame.frame.width / CGFloat(colNo) * CGFloat(x - 1)
        point.y = boardGame.frame.height / CGFloat(rowNo) * CGFloat(y - 1)
        return point
    }
    
    func checkComplete() -> Bool {
        for cell in cellGameArray {
            if !isInDistance(cell.oldPoint, cell.frame.origin) {
                return false
            }
        }
        return true
    }
    
    
    var acceptDistance:CGFloat = 20
    func isInDistance(_ point1: CGPoint, _ point2: CGPoint) -> Bool {
        if abs(point1.x - point2.x) < acceptDistance && abs(point1.y - point2.y) < acceptDistance{
            return true
        }
        return false
    }
    
    var firstPoint: CGPoint!
    var isTouchable = false
    var xMove:CGFloat = 0.0
    var yMove:CGFloat = 0.0
    var viewMove: CellGame!
    var recognizerPoint: CGPoint!
    func panDetected(recognizer: UIPanGestureRecognizer) {
        // let translation  = recognizer.translation(in: recognizer.view)
        if recognizer.state == .began {
            
            viewMove = recognizer.view as! CellGame!
            isTouchable = false
            let imageView = recognizer.view as! UIImageView
            let point = recognizer.location(in: imageView)
            let color = imageView.getPixelColorAtPoint(point: point)
            if isNoColor(color) {
                recognizerPoint = recognizer.location(in: self.view)
                for cell in cellGameArray.reversed() {
                    var isChosen = false
                    if cell.frame.contains(recognizerPoint) {
                        let point2 = recognizer.location(in: cell)
                        let color2 = cell.getPixelColorAtPoint(point: point2)
                        if !isNoColor(color2) {
                            viewMove = cell
                            isTouchable = true
                            isChosen = true
                        }
                    }
                    if isChosen {
                        break
                    }
                }
                if !isTouchable {
                    return
                }
            } else {
                isTouchable = true
            }
            scoreLabel.textColor = color
            if isFirstTap == true {
                if playMode == 0 {
                    startTimer()
                }
                isFirstTap = false
            }
            firstPoint = viewMove.frame.origin
            xMove = firstPoint.x.subtracting(recognizer.location(in: self.boardGame).x)
            yMove = firstPoint.y.subtracting(recognizer.location(in: self.boardGame).y)
            self.view.bringSubview(toFront: viewMove)
        }
        
        if recognizer.state == .changed && isTouchable == true {
            // if cell inside gameboard, zoom in cell x3
            if (viewMove.frame.intersects(self.boardGame.frame)) {
                if viewMove.scaled == true {
                    viewMove.transform = (viewMove.transform.scaledBy(x: 3, y: 3))
                    viewMove.scaled = false
                }
            } else {
                if viewMove.scaled == false {
                    // if cell outside of gameboard, zoom out 3 times
                    viewMove.transform = (viewMove.transform.scaledBy(x: 1/3, y: 1/3))
                    viewMove.scaled = true
                }
            }
            // check if go out game board view
            if recognizer.location(in: self.view).x < 0 {
                viewMove.center.x = 0
            }
            
            if recognizer.location(in: self.view).x > self.view.frame.width {
                viewMove.center.x = self.view.frame.width
            }
            
            if recognizer.location(in: self.view).y < 0 {
                viewMove.center.y = 0
            }
            
            if recognizer.location(in: self.view).y > self.view.frame.height {
                viewMove.center.y = self.view.frame.height
            }
            
            viewMove.frame.origin.x = xMove.adding(recognizer.location(in: self.boardGame).x)
            viewMove.frame.origin.y = yMove.adding(recognizer.location(in: self.boardGame).y)
        }
        
        if recognizer.state == .ended && isTouchable == true {
            if isInDistance(viewMove.oldPoint, viewMove.frame.origin) {
//                viewMove.frame.origin = viewMove.oldPoint
                UIView.animate(withDuration: 0.3, animations: {
                    self.viewMove.frame.origin = self.viewMove.oldPoint
                })
                viewMove.isUserInteractionEnabled = false
                playSuccessSound()
            }

            if(checkComplete() == true) {
                solvedImageList.append(doingImage)
                let doingImgName = doingImage.fileName!
                
                // check if there is any unsolved image
                if unsolvedImageList.count != 0 {
                    
                    // remeove old tiles from board
                    for view in cellGameArray {
                        view.removeFromSuperview()
                    }
                    
                    let path = UIBezierPath()
                    
                    // create a new CAKeyframeAnimation that animates the objects position
                    let anim = CAKeyframeAnimation(keyPath: "position")
                    
                    // set the animations path to our bezier curve
                    anim.path = path.cgPath
                    
                    // set some more parameters for the animation
                    // this rotation mode means that our object will rotate so that it's parallel to whatever point it is currently on the curve
                    //                    anim.rotationMode = kCAAnimationRotateAuto
                    //                    anim.repeatCount = Float.infinity
                    anim.duration = 0.8
                    
                    // animation compelete picture
                    boardGame.image = image
                    boardGame.layer.add(anim, forKey: "animate position along path")
                    
                    let randomIndex = random(max: unsolvedImageList.count)
                    doingImage = unsolvedImageList.remove(at: randomIndex)
                    image = UIImage(named: doingImage.fileName!)!
                    print("abc")
                    stopTimer()
                    
                    playWinningSound()
                    //continue button
                    continueBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height * 0.005 , width: 70, height: 50))
                    continueBtn.setTitle("Chơi tiếp", for: .normal)
                    continueBtn.titleLabel?.text = "Chơi tiếp"
                    continueBtn.backgroundColor = UIColor.clear
                    continueBtn.setImage(UIImage(named: "Next-Arrow.png"), for: .normal)
                    continueBtn.addTarget(self, action: #selector(self.continueGame), for: .touchUpInside)

                    
                    //audio button
                    audioBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.005 , width: 80, height: 50))
                    audioBtn.accessibilityHint = doingImgName
                    //print(doingImage.fileName)
                    
                    //TODO : need to fix
                    //audioBtn.accessibilityHint = doingImage.audio
                    audioBtn.setTitle("Nghe", for: .normal)
                    audioBtn.titleLabel?.text = "Nghe"
                    audioBtn.setImage(UIImage(named: "PlayAudio.png"), for: .normal)
                    audioBtn.backgroundColor = UIColor.clear
                    
                    //print(doingImage.audio)
                    //print(doingImage.fileName)
                    audioBtn.addTarget(self, action: #selector(self.playAudio), for: .touchUpInside)
                    // if play mode is Tính giờ
                    if playMode == 0 {
                        score = score + Int(Float(rowNo * colNo) * ((timeLimit - seconds)/timeLimit) * 10000)
                        seconds = 0
                    } else {
                        score = score + 1
                    }
                    scoreLabel.text = "\(score)"
                    
                    self.view.addSubview(continueBtn)
                    self.view.addSubview(audioBtn)
                    
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//                        self.audioBtn.removeFromSuperview()
//                        self.startTimer()
//                        self.makeGameBoard()
//                    })
                } else {
                    // else, finish, update score
                    if playMode == 0 {
                        score = score + Int(Float(rowNo * colNo) * ((timeLimit - seconds)/timeLimit) * 10000)
                    } else {
                        score = score + 1
                    }
                    scoreLabel.text = "\(score)"
                    playWinningSound()
                    stopTimer()
                    updateHighScore()
                }
            }
//            enableAllCells()
        }
        
        if recognizer.state == .failed {
//            enableAllCells()
        }
        
        if recognizer.state == .cancelled {
//            enableAllCells()
        }
        self.view.setNeedsDisplay()
    }
    
    // create game board
    func makeGameBoard(){
        
        //make left side
        let leftView = UIView()
        leftView.frame = CGRect(x:0, y : 0, width : UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height)
        let leftImageView = UIImageView()
        leftImageView.frame = CGRect(x:0, y : 0, width : UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height)
        leftImageView.image = UIImage(named : "go")
        leftView.addSubview(leftImageView)
        
        self.view.addSubview(leftView)
        
        
        //leftView.back
        
        
        
        

        //imageView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        //imageView.addGestureRecognizer(singleTap)
        //imageView.image = image
        boardGame.image = image.maskWithColor(color: UIColor.brown)
        boardGame.frame = CGRect(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.2, width: ((UIScreen.main.bounds.width * 0.8) - 30) ,
                                 height: (UIScreen.main.bounds.height) * 0.7)
        boardGame.isExclusiveTouch = true
//        // remeove old tiles from board
        for view in cellGameArray {
            view.removeFromSuperview()
        }
        // setting row and col number based on mode and number of solved photo
        // Mode Tính giờ
        if playMode == 0 {
            // timer progress bar
            timerBar.progressImage = UIImage(named: "progressBar")
            timerBar.trackTintColor = UIColor.blue
            timerBar.frame = CGRect(x: UIScreen.main.bounds.width/2 - 40, y: UIScreen.main.bounds.height * 0.05, width: UIScreen.main.bounds.width/8, height: 5)
            timerBar.transform = timerBar.transform.scaledBy(x: 1, y: 5)
            self.view.addSubview(timerBar)
            // if player has solved more than specified x pics, increase level
            if solvedImageList.count > (numUpLevel * upLevelTimes) {
                if colNo > rowNo {
                    rowNo = rowNo + 1
                } else {
                    colNo = colNo + 1
                }
                upLevelTimes = upLevelTimes + 1
            }
        } else {
            // Mode không tính giờ
            // if player has solved more than specified x pics, increase level
            if solvedImageList.count > (numUpLevel * upLevelTimes) {
                if colNo > rowNo {
                    rowNo = rowNo + 1
                } else {
                    colNo = colNo + 1
                }
                upLevelTimes = upLevelTimes + 1
            }
        }
        cellGameArray = [CellGame]()
        // create tiles
        var count = 0
        for i in 1...colNo {
            for j in 1...rowNo {
                let tmpImageView = CellGame()
                let x = CGFloat(i - 1) * (boardGame.frame.width / CGFloat(colNo)) + boardGame.frame.minX
                let y = CGFloat(j - 1) * (boardGame.frame.height / CGFloat(rowNo)) + boardGame.frame.minY
                print("===")
                print(x, y)
                print(boardGame.frame.width / CGFloat(colNo), boardGame.frame.height / CGFloat(rowNo))
                print("===")
                tmpImageView.frame = CGRect(x: x  , y: y , width: boardGame.frame.width / CGFloat(colNo), height: boardGame.frame.height / CGFloat(rowNo))
                let tmpImage = image.splitImage(rowNo: CGFloat(rowNo), colNo: CGFloat(colNo), xOrder: CGFloat(i-1), yOrder: CGFloat(j-1))
                tmpImageView.image = tmpImage
                tmpImageView.oldPoint = tmpImageView.frame.origin
                tmpImageView.isExclusiveTouch = true
                tmpImageView.transform = tmpImageView.transform.scaledBy(x: 1/3, y: 1/3)
                tmpImageView.scaled = true
                tmpImageView.tag = count
                count += 1
                cellGameArray.append(tmpImageView)
                self.view.addSubview(tmpImageView)
            }
        }
        for i in 0..<cellGameArray.count {
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
                singleTap.numberOfTapsRequired = 1
                singleTap.numberOfTouchesRequired = 1
                let tmpImage = cellGameArray[i]
                tmpImage.isUserInteractionEnabled = true
                let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected))
                pan.maximumNumberOfTouches = 1
                tmpImage.addGestureRecognizer(singleTap)
                tmpImage.addGestureRecognizer(pan)
        }
        // random cells
        mixingCells(times: 5)
    }
    
    func random(max: Int) -> Int {
        let randomNum:UInt32 = arc4random_uniform(UInt32(max)) // range is 0 to max - 1
        return Int(randomNum)
    }
    
    func mixingCells(times: Int) {
        cellGameArray.shuffle()
        let cell1 = cellGameArray[0] as CellGame
//        let startX:CGFloat = (self.view.frame.width - (4 * cell1.frame.width)) / 2
//        let startY:CGFloat = 80
//        var j = 0
//        for i in 0..<cellGameArray.count {
//            let cell = cellGameArray[i] as CellGame
//            if ( j > 3) {
//                j = 0
//            }
//            let x = startX + (cell.frame.width + 5) * CGFloat(j)
//            let y = startY + (cell.frame.width + 5) * CGFloat((i / 4))
//            j += 1
//            cell.frame.origin = CGPoint(x: x, y: y)
//        }
        
        let startX:CGFloat = 30
        let startY:CGFloat = (self.view.frame.height - (4 * cell1.frame.height)) / 2
        for i in 0..<cellGameArray.count{
            let cell = cellGameArray[i] as CellGame
            let x = startX
            let y = startY + (cell.frame.height + 5) * CGFloat(i)
            cell.frame.origin = CGPoint(x:x, y:y)
        }
    }

    // back button pressed
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // start timer: 0.1s
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    // update time : add 0.1s
    func updateTime() {
        if seconds <= timeLimit {
            seconds += 0.1
            timerBar.progress = seconds.divided(by: timeLimit)
        } else {
            // finish game TODO het gio
            timer.invalidate()
            updateHighScore()
        }
    }
    
    // stop timer
    func stopTimer() {
        timer.invalidate()
    }
    
    func getImageListFromCatalogue(){
        do {
            let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "toCatalogue == %@", catalogue)
            let sort = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            unsolvedImageList = try context.fetch(fetchRequest)
        } catch {
            fatalError("Failed")
        }
    }
    
    func updateHighScore() {
        var pointInfoList: [PointInfo]!
        var isNewRecord = false
        do {
            let fetchRequest: NSFetchRequest<PointInfo> = PointInfo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "toCatalogue == %@ && modeType == %d", catalogue, playMode)
            let sort = NSSortDescriptor(key: "topPlace", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            pointInfoList = try context.fetch(fetchRequest)
            for i in 0..<pointInfoList.count {
                if Int64(score) > pointInfoList[i].totalPoint {
                    let oldPoint = pointInfoList[i].totalPoint
                    pointInfoList[i].totalPoint = Int64(score)
                    score = Int(oldPoint)
                    if i == 0 {
                        isNewRecord = true
                    }
                }
            }
            try context.save()
        } catch {
            fatalError("Failed")
        }
        // TODO thong bao neu co ky luc moi
        if isNewRecord {
            print("New record: \(pointInfoList[0].totalPoint)")
        }
        
        // for debug FIXME
        for i in 0..<pointInfoList.count {
            print(pointInfoList[i].totalPoint)
        }
        
        // Menu game over
        gameOverMenu = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let gameOver = UIView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0))
        gameOver.backgroundColor = UIColor.red
        
        let replayBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        replayBtn.titleLabel?.text = "Chơi lại"
        replayBtn.setTitle("Chơi lại", for: .normal)
        replayBtn.backgroundColor = UIColor.blue
        replayBtn.addTarget(self, action: #selector(self.replay), for: .touchUpInside)
        
        
        let stopBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        stopBtn.setTitle("Thoát", for: .normal)
        stopBtn.titleLabel?.text = "Thoát"
        stopBtn.backgroundColor = UIColor.purple
        stopBtn.addTarget(self, action: #selector(self.stop), for: .touchUpInside)
        
        gameOver.addSubview(replayBtn)
        gameOver.addSubview(stopBtn)
        gameOverMenu.addSubview(gameOver)
        self.view.addSubview(gameOverMenu)
//        print(gameOver.center)
//        print(replayBtn.center)
        
        //Call whenever you want to show it and change the size to whatever size you want
        UIView.animate(withDuration: 0.5, animations: {
            gameOver.frame.size = CGSize(width: 300, height: 300)
            gameOver.center = self.view.center
            replayBtn.center = CGPoint(x: gameOver.frame.width/2 , y: gameOver.frame.height/2 - 30)
            stopBtn.center = CGPoint(x: gameOver.frame.width/2 , y: gameOver.frame.height/2 + 30)
        })
    }
    
    func playAudio(sender: UIButton){
        let name: String! = sender.accessibilityHint
        if name != nil {
            audioPath = Bundle.main.path(forResource: name, ofType: "mp3")
            audioURL = URL(fileURLWithPath: audioPath!)
            do {
                try audioSound = AVAudioPlayer(contentsOf: audioURL)
            } catch(let err as NSError) {
                print(err.debugDescription)
            }
            if audioSound.isPlaying {
                audioSound.stop()
                do {
                    try audioSound = AVAudioPlayer(contentsOf: audioURL)
                } catch(let err as NSError) {
                    print(err.debugDescription)
                }
            }
            audioSound.play()
        }
        
    }
    
    func continueGame(){
        continueBtn.removeFromSuperview()
        audioBtn.removeFromSuperview()
        if(playMode == 0){
            startTimer()
        }
        //gameOverMenu.removeFromSuperview()
        boardGame.isUserInteractionEnabled = true
        boardGame.removeFromSuperview()
        for view in cellGameArray {
            view.isUserInteractionEnabled = true
            view.removeFromSuperview()
        }
        createGame()
        playWinningSound()
    }
    
    func replay() {
        seconds = 0
        timerBar.progress = 0
        isFirstTap = true
        solvedImageList.removeAll()
        upLevelTimes = 1
        score = 0
        gameOverMenu.removeFromSuperview()
        boardGame.isUserInteractionEnabled = true
        boardGame.removeFromSuperview()
        //imageView.removeFromSuperview()
        scoreLabel.removeFromSuperview()
        for view in cellGameArray {
            view.isUserInteractionEnabled = true
            view.removeFromSuperview()
        }
        createGame()
    }
    
    func stop() {
            self.dismiss(animated: true, completion: nil)
    }
    
    func isNoColor(_ color: UIColor) -> Bool {
        let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        if color.isEqual(color1) {
            return true
        } else {
            return false
        }
    }

}

class CellGame: UIImageView {
    var x: Int?
    
    var y: Int?
    
    var oldPoint: CGPoint!
    
    var scaled = false
}


// add split image extension for UIImage
extension UIImage {
    func splitImage(rowNo: CGFloat, colNo: CGFloat, xOrder: CGFloat, yOrder: CGFloat) -> UIImage? {
        guard let
            newImage = self.cgImage!.cropping(to: CGRect(origin: CGPoint(x: size.width/colNo * xOrder, y: size.height/rowNo * yOrder), size: CGSize(width:
                size.width/colNo, height: size.height/rowNo)))
            else { return nil }
        return UIImage(cgImage: newImage, scale: 1, orientation: imageOrientation)
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: newWidth,height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}


extension UIImageView {
    func getPixelColorAtPoint(point:CGPoint) -> UIColor{
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate(capacity: 4)
        return color
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (unshuffledCount, firstUnshuffled) in zip(stride(from: c, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}


