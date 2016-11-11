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
    
    let imageView = UIImageView() // UIImange for reference original image
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "grass")
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
        
        
//        let backgroundImage = UIImageView(frame:boardGame.bounds)
//        backgroundImage.image = UIImage(named: "wood")
//        self.boardGame.insertSubview(backgroundImage, at: 0)
//        boardGame.image = UIImage(named: "wood")
        // reference original photo view
        imageView.frame = CGRect(x: UIScreen.main.bounds.width/4, y: 60 , width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height / 4)
//        self.view.addSubview(imageView)
        scoreLabel.text = "0"
        scoreLabel.font = UIFont(name: scoreLabel.font.fontName, size: 30)
        scoreLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2 - 90 , width: UIScreen.main.bounds.width, height: 40)
        scoreLabel.textAlignment = .center
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.textColor = UIColor.red
        self.view.addSubview(scoreLabel)
        makeGameBoard()
//        self.view.addSubview(boardGame)
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
//        imageView.transform = imageView.transform
//        print(point)
//        print((imageView.getPixelColorAtPoint(point: point)))
//        print(imageView1[Int(point.x), Int(point.y)])
//        if isFirstTap == true {
//            // if mode is Tính giờ
//            if playMode == 0 {
//                startTimer()
//            }
//            isFirstTap = false
//        }
//        let cell = findCell(point: sender.location(in: boardGame))
//        if previousCell != nil {
//            if !(cell.x == previousCell?.x && cell.y == previousCell?.y) {
//                let xTmp = previousCell?.x
//                let yTmp = previousCell?.y
//                let imageTmp = previousCell?.image
//                previousCell?.x = cell.x
//                previousCell?.y = cell.y
//                previousCell?.image = cell.image
//                cell.x = xTmp
//                cell.y = yTmp
//                cell.image = imageTmp
//                // play switch pies sound
//                playSwitchSound()
//                // check complete
//                if(checkComplete() == true) {
//                    solvedImageList.append(doingImage)
//                    if unsolvedImageList.count != 0 {
//                        let randomIndex = random(max: unsolvedImageList.count)
//                        doingImage = unsolvedImageList.remove(at: randomIndex)
//                        image = UIImage(named: doingImage.fileName!)!
//                        makeGameBoard()
//                        playWinningSound()
//                    } else {
//                        playWinningSound()
//                        stopTimer()
//                        updateHighScore()
//                    }
//                }
//            }
//            previousCell?.layer.opacity = 1
//            previousCell = nil
//        } else {
//            previousCell = cell
//            cell.layer.opacity = 0.2
//            
//        }
//        self.view.setNeedsDisplay()
    }
    
    // find cell based on x, y coordinate
//    func findCell(point: CGPoint) -> CellGame {
//        let xFloat = Float(point.x / (boardGame.frame.width / CGFloat(colNo)))
//        var x:Int = Int(xFloat)
//        if x != 0 && floorf(xFloat) == xFloat {
//            x = x - 1
//        }
//        let yFloat = Float(point.y / (boardGame.frame.height / CGFloat(rowNo)))
//        var y:Int = Int(yFloat)
//        if y != 0 && floorf(yFloat) == yFloat {
//            y = y - 1
//        }
//        return cellGameArray[x][y]
//    }
    
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
//            recognizer.view = cellGameArray[0][0]
            
            viewMove = recognizer.view as! CellGame!
            isTouchable = false
            let imageView = recognizer.view as! UIImageView
            let point = recognizer.location(in: imageView)
            let color = imageView.getPixelColorAtPoint(point: point)
            if isNoColor(color) {
                recognizerPoint = recognizer.location(in: self.view)
//                cellGameArray.sort(by: { (cell1, cell2)  -> Bool in
//                    return cell1.tag > cell2.tag
//                })
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
//                viewMove = cellGameArray[0]
//                isTouchable = true
//                return
            } else {
                isTouchable = true
            }
//            print(imageView1[Int(point.x), Int(point.y)])
            scoreLabel.textColor = color
//            disableOtherCells()
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
//            playSwitchSound()
//            let lastPoit = recognizer.view?.center
//            recognizer.view?.frame.origin = firstPoint
//            firstPoint = recognizer.view?.center
//            firstCell = findCell(point: firstPoint)
//            newCell = findCell(point: lastPoit!)
//            let xTmp = newCell.x
//            let yTmp = newCell.y
//            let imageTmp = newCell.image
//            newCell.x = firstCell.x
//            newCell.y = firstCell.y
//            newCell.image = firstCell.image
//            firstCell.x = xTmp
//            firstCell.y = yTmp
//            firstCell.image = imageTmp
            if(checkComplete() == true) {
                solvedImageList.append(doingImage)
                
                
                // check if there is any unsolved image
                if unsolvedImageList.count != 0 {
                    
                    // remeove old tiles from board
                    for view in cellGameArray {
                        view.removeFromSuperview()
                    }
                    
                    let path = UIBezierPath()
                    path.move(to: boardGame.center)
                    path.addCurve(to: CGPoint(x: 301, y: 239), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))
                    //                    path.addLine(to: self.view.center)
                    
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
                    // update score
                    // if play mode is Tính giờ
                    if playMode == 0 {
                        score = score + Int(Float(rowNo * colNo) * ((timeLimit - seconds)/timeLimit) * 10000)
                        seconds = 0
                    } else {
                        score = score + 1
                    }
                    scoreLabel.text = "\(score)"
                    
                    stopTimer()
//                    makeGameBoard()
                    playWinningSound()
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
        // end - timer progress bar
//        imageView.frame.size = image.size
//        let newWidth = (image.size.width) * (imageView.frame.size.width / (image.size.width))
//        let newHeight = (image.size.height) * (imageView.frame.size.height / (image.size.height))
//        image = image.resizeImage(newWidth: newWidth, newHeight: newHeight)
        
//        imageView.image = image
//        imageView.contentMode = .scaleAspectFit
        

        imageView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(singleTap)
        imageView.image = image
//        boardGame.image = image
        boardGame.image = image.maskWithColor(color: UIColor.brown)
        boardGame.frame = CGRect(x: 10, y: UIScreen.main.bounds.height/2 - 30, width: UIScreen.main.bounds.width-20 , height: (UIScreen.main.bounds.height)/2)
        boardGame.isExclusiveTouch = true
//        // remeove old tiles from board
//        for view in cellGameArray {
//            view.removeFromSuperview()
//        }
        // setting row and col number based on mode and number of solved photo
        // Mode Tính giờ
        if playMode == 0 {
            // timer progress bar
            timerBar.progressImage = UIImage(named: "progressBar")
            timerBar.trackTintColor = UIColor.blue
            timerBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2 - 40, width: UIScreen.main.bounds.width, height: 5)
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
                tmpImageView.frame = CGRect(x: x  , y: y , width: boardGame.frame.width / CGFloat(colNo), height: boardGame.frame.height / CGFloat(rowNo))
                let tmpImage = image.splitImage(rowNo: CGFloat(rowNo), colNo: CGFloat(colNo), xOrder: CGFloat(i-1), yOrder: CGFloat(j-1))
//                let newWidth = (tmpImage?.size.width)! * (tmpImageView.frame.size.width / (tmpImage?.size.width)!)
//                let newHeight = (tmpImage?.size.height)! * (tmpImageView.frame.size.height / (tmpImage?.size.height)!)
//                tmpImage = tmpImage?.resizeImage(newWidth: newWidth, newHeight: newHeight)
                tmpImageView.image = tmpImage
//                tmpImageView.x = i
//                tmpImageView.y = j
//                tmpImageView.tobeX = i
//                tmpImageView.tobeY = j
                tmpImageView.oldPoint = tmpImageView.frame.origin
                tmpImageView.isExclusiveTouch = true
//                tmpImageView.layer.borderWidth = 1
//                tmpImageView.layer.borderColor = UIColor.brown.cgColor
//                tmpImageView.layer.masksToBounds = true
//                tmpImageView.layer.cornerRadius = 10.0
//                tmpImageView.layer.shadowRadius = 10
//                tmpImageView.alpha = 0.5
//                tmpImageView.layer.op
                tmpImageView.transform = tmpImageView.transform.scaledBy(x: 1/3, y: 1/3)
//                tmpImageView.image?.scale = 1/3
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
//        while checkComplete() {
////            mixingCells(times: 5)
//        }
    }
    
    func random(max: Int) -> Int {
        let randomNum:UInt32 = arc4random_uniform(UInt32(max)) // range is 0 to max - 1
        return Int(randomNum)
    }
    
    func mixingCells(times: Int) {
        for _ in 1...times {
            for i in 0..<cellGameArray.count {
//                    let cell1 = cellGameArray[col][row]
//                    let xTmp = cell1.x
//                    let yTmp = cell1.y
//                    let imageTmp = cell1.image
//                    let cell2 = cellGameArray[random(max: colNo)][random(max: rowNo)]
//                    cell1.x = cell2.x
//                    cell1.y = cell2.y
//                    cell1.image = cell2.image
//                    cell2.x = xTmp
//                    cell2.y = yTmp
//                    cell2.image = imageTmp
                let cell = cellGameArray[i] as CellGame
                let randomX = random(max: Int(self.view.frame.width - 20)) + 10
                let randomY = random(max: Int(boardGame.frame.minY - 10)) + 10
                cell.frame.origin = CGPoint(x: randomX, y: randomY)
            }
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
        // -- TODO load from database
        //        for img in catalogue.toImage! {
        //            images.append(img as! Image)
        //        }
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
//        for point in catalogue.toPointInfo! {
//            let p = point as! PointInfo
//            if p.modeType == Int64(playMode) {
//                print(p.totalPoint)
//            }
//        }
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
    
    func replay() {
        seconds = 0
        timerBar.progress = 0
        isFirstTap = true
        solvedImageList.removeAll()
        upLevelTimes = 1
        score = 0
        gameOverMenu.removeFromSuperview()
        boardGame.removeFromSuperview()
        imageView.removeFromSuperview()
        scoreLabel.removeFromSuperview()
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


