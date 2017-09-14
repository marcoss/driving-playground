import SpriteKit
import GameplayKit
import AVFoundation

public class Scene: SKScene, SKPhysicsContactDelegate {
    // MARK: Instance vars
    lazy var agentSystem: GKComponentSystem = {
        return GKComponentSystem(componentClass: GKAgent2D.self)
    }()

    // Init with three player
    lazy var audioPlayers: [AVAudioPlayer] = [AVAudioPlayer]()

    var lastUpdateTime: TimeInterval!

    // Walls
    var barricades: [SKNode] = [SKSpriteNode]()

    // Grassy area
    var medianAgent: GKAgent2D!

    var carAgents: [GKAgent2D] = [GKAgent2D]()
    var policeAgents: [GKAgent2D] = [GKAgent2D]()
    var obstacles: [GKAgent2D] = [GKAgent2D]()

    // Keep track of nodes to remove from scene
    var carNodes: [Car] = [Car]()
    var policeNodes: [Car] = [Car]()

    // Buttons for scene interaction
    var buttonAddCar: SKSpriteNode?
    var buttonAddPolice: SKSpriteNode?
    var buttonDeleteAll: SKSpriteNode?

    // Customizable behavior for normal cars (edit in Playground file)
    public var carReachSpeed: Float = 60.0                 // Target speed
    public var carStayOnRoad: BehaviorWeight = .critical    // Importance to stay on path
    public var carAvoidObstacles: BehaviorWeight = .high    // Avoid obstacles
    public var carAvoidPolice: BehaviorWeight = .high       // Flee from police

    // Customizable behavior for police cars (edit in Playground file)
    public var policeReachSpeed: Float = 80.0              // Target speed
    public var policeStayOnRoad: BehaviorWeight = .high     // Stay on path
    public var policeAvoidObstacles: BehaviorWeight = .high // Avoid obstacles
    public var policeChaseCars: BehaviorWeight = .critical  // Chase cars

    // MARK: Entry point into scene, setup physics
    public override func didMove(to view: SKView) {
        setupWorld()
    }

    // Setup world gravity and physics behavior, get nearby walls and medians
    private func setupWorld() {
        // No gravity, prevent objects leaving frame region)
        physicsWorld.gravity = CGVector.zero
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // Detect contacts
        physicsWorld.contactDelegate = self

        // Add track border barricades
        enumerateChildNodes(withName: "wall") { node, _ in
            if let wall = node as? SKSpriteNode {
                wall.color = UIColor.red
                wall.physicsBody = SKPhysicsBody(texture: wall.texture!, size: wall.texture!.size())
                wall.physicsBody?.isDynamic = false
                wall.physicsBody?.contactTestBitMask = Globals.Contacts.wall

                self.barricades.append(wall)
            }
        }

        // Cars should avoid empty grassy median
        if let node = childNode(withName: "median") as? SKSpriteNode {
            let agent = GKAgent2D()
            agent.position = float2(node.position)
            agent.radius = Float(node.size.height)
            agent.mass = 100.0
            
            medianAgent = agent
        }

        // Add car button
        if let addCar = childNode(withName: "addCar") as? SKSpriteNode {
            addCar.zPosition = 50
            buttonAddCar = addCar
        }

        // Add police button
        if let addPolice = childNode(withName: "addPolice") as? SKSpriteNode {
            addPolice.zPosition = 50
            buttonAddPolice = addPolice
        }

        if let deleteAll = childNode(withName: "deleteAll") as? SKSpriteNode {
            deleteAll.zPosition = 50
            buttonDeleteAll = deleteAll
        }
    }
    // MARK: Add Car/Police/Obstacle functionality

    // Add car with delay
    public func addCar(withDelay: Double) {
        delay(withDelay) { 
            self.addCar()
        }
    }

    // Add car to scene, default behavior is to follow path and speed
    public func addCar() {
        let car = Car(location: CGPoint(x: 0, y: 160), carType: .normal)

        // Setup behaviors
        car.agent.behavior = carBehavior
        agentSystem.addComponent(car.agent)

        // Add to tracking array
        carAgents.append(car.agent)
        carNodes.append(car)

        updateCars()

//        playSound(sound: .carAdded)

        addChild(car)
    }

    // Add police with delay
    public func addPolice(withDelay: Double) {
        delay(withDelay) {
            self.addPolice()
        }
    }

    // Add police to scene, default behavior is to chase/intercept cars
    public func addPolice() {
        let police = Car(location: CGPoint(x: 0, y: 160), carType: .police)

        // Setup behaviors
        police.agent.behavior = policeBehavior
        agentSystem.addComponent(police.agent)

        // Add to tracking array
        policeAgents.append(police.agent)
        policeNodes.append(police)

        updateCars()

//        playSound(sound: .police)

        addChild(police)
    }

    // Update car behaviors for all agents in scene
    private func updateCars() {
        if !carAgents.isEmpty {
            for car in carAgents {
                car.behavior = carBehavior
            }
        }

        if !policeAgents.isEmpty {
            for police in policeAgents {
                police.behavior = policeBehavior
            }
        }
    }

    // Called from touch delegate, add obstacle to scene at point and update car behaviors to avoid obstacle
    private func addObstacle(atPoint: CGPoint) {
        let obstacle = Obstacle(location: atPoint)

        agentSystem.addComponent(obstacle.agent)

        // Add to tracking array
        obstacles.append(obstacle.agent)

        // Update all car behaviors
        updateCars()

//        playSound(sound: .obstacleAdded)

        addChild(obstacle)
    }

    // Remove ALL moving cars from the scene
    private func removeCars() {
        // Remove cars
        for car in carNodes {
            agentSystem.removeComponent(car.agent)
            car.removeFromParent()
        }

        carAgents.removeAll()
        carNodes.removeAll()

        // Remove police
        for police in policeNodes {
            agentSystem.removeComponent(police.agent)
            police.removeFromParent()
        }

        policeAgents.removeAll()
        policeNodes.removeAll()

        // Update all cars
        updateCars()
    }

    // MARK: Car/Police behavior
    // Car behaviors - includes staying on path, avoiding obstacles, reaching speed, and fleeing police
    var carBehavior: GKBehavior {
        var goals = [GKGoal]()
        var weights = [NSNumber]()

        let path = GKPath(points: Globals.trackPath, radius: 60.0, cyclical: true)

        goals.append(GKGoal(toStayOn: path, maxPredictionTime: 2.0))
        weights.append(carStayOnRoad.rawValue)

        goals.append(GKGoal(toFollow: path, maxPredictionTime: 2.0, forward: true))
        weights.append(carStayOnRoad.rawValue)

        goals.append(GKGoal(toReachTargetSpeed: carReachSpeed))
        weights.append(50.0)

        goals.append(GKGoal(toAvoid: obstacles, maxPredictionTime: 30.0))
        weights.append(carAvoidObstacles.rawValue)

        goals.append(GKGoal(toAvoid: [medianAgent], maxPredictionTime: 30.0))
        weights.append(140.0)

        // Avoid police on map if added to scene
        if !policeAgents.isEmpty {
            goals.append(GKGoal(toAvoid: policeAgents, maxPredictionTime: 10.0))
            weights.append(carAvoidPolice.rawValue)
        }

        return GKBehavior(goals: goals, andWeights: weights)
    }

    // Police behaviors - includes staying on path, avoiding obstacles, reaching speed, and intercepting agents
    var policeBehavior: GKBehavior {
        var goals = [GKGoal]()
        var weights = [NSNumber]()

        let path = GKPath(points: Globals.trackPath, radius: 60.0, cyclical: true)

        goals.append(GKGoal(toStayOn: path, maxPredictionTime: 2.0))
        weights.append(policeStayOnRoad.rawValue)

        goals.append(GKGoal(toFollow: path, maxPredictionTime: 2.0, forward: true))
        weights.append(policeStayOnRoad.rawValue)

        goals.append(GKGoal(toAvoid: obstacles, maxPredictionTime: 30.0))
        weights.append(policeAvoidObstacles.rawValue)

        goals.append(GKGoal(toAvoid: [medianAgent], maxPredictionTime: 30.0))
        weights.append(200.0)

        // Only intercept if cars on map
        if !carAgents.isEmpty {
            // Intercepting speed
            goals.append(GKGoal(toReachTargetSpeed: policeReachSpeed))
            weights.append(50.0)

            goals.append(GKGoal(toInterceptAgent: carAgents.randomElement(), maxPredictionTime: 3.0))
            weights.append(policeChaseCars.rawValue)
        } else {
            // Cruising speed with no cars to intercept
            goals.append(GKGoal(toReachTargetSpeed: 40.0))
            weights.append(50.0)
        }

        return GKBehavior(goals: goals, andWeights: weights)
    }

    // MARK: Scene interaction and updates
    // Touch began on scene interaction, add obstacle onto scene at location of touch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)

            // Nil-coalescing
            // Check if touch was for a button
            if buttonAddCar?.contains(point) ?? true {
                addCar()
                return
            }

            // Check if touch was for a button
            if buttonAddPolice?.contains(point) ?? true {
                addPolice()
                return
            }

            // Check if touch was for a button
            if buttonDeleteAll?.contains(point) ?? true {
                removeCars()
                return
            }

            // Touch intended to add obstacle
            addObstacle(atPoint: point)
        }
    }

    // Delegate called for scene updates, send update to agent system
    public override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == nil {
            lastUpdateTime = currentTime
        }

        let delta = TimeInterval(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime

        agentSystem.update(deltaTime: delta)
    }

    // MARK: Music/sound playback
    private func playSound(sound: SoundType, volume: Float = 1.0) {
        // Enum contains MP3 filename
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)

            // Condition 1: Init first player
//            if audioPlayers.isEmpty {
//                let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//                audioPlayers.append(player)
//
//                playWithPlayer(player: player, volume: volume)
//                return
//            }

            // Condition 2: Iterate and find empty player
//            for (i, player) in audioPlayers.enumerated() {
//                if !player.isPlaying {
//                    audioPlayers[i] = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//                    playWithPlayer(player: audioPlayers[i], volume: volume)
//                    return
//                }
//            }

            // Don't excessively create too many audio players, better to skip sounds than ruin performance
//            if (audioPlayers.count > 10) {
//                return
//            }

            // Condition 3: Create new player
//            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//            audioPlayers.append(player)

//            playWithPlayer(player: player, volume: volume)
        } catch let error as NSError {
            print("Audio error: \(error.localizedDescription)")
        }
    }

    // Simple handler to play sounds with player
    private func playWithPlayer(player: AVAudioPlayer, volume: Float) {
        player.volume = volume
        player.play()
    }

    // MARK: Police capture interaction
    // Handle police capturing/intercepting an agent
    // Find/delete the car node in tracking arrays, remove from scene and play sound effect
    private func handlePoliceCapture(carNode: SKNode, index: Int) {
        if let path = Bundle.main.path(forResource: "SmokeParticle", ofType: "sks") {
            let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            
            particle.position = carNode.position
            particle.targetNode = scene

            // Gracefully remove particles from scene
            delay(2.0, closure: {
                particle.particleAlphaSpeed = -1.0

                delay(0.5, closure: { 
                    particle.removeFromParent()
                })
            })

            addChild(particle)
        }

        carNode.removeFromParent()

        carNodes.remove(at: index)
        carAgents.remove(at: index)

        // Play sound
//        playSound(sound: .police)

        updateCars()
    }

    // MARK: Contact collisions
    // Handle collisions between police and intercepted cars, or cars and obstacles
    public func didBegin(_ contact: SKPhysicsContact) {
        // Ignore collisions into wall
        if contact.bodyA.contactTestBitMask == Globals.Contacts.wall ||
            contact.bodyB.contactTestBitMask == Globals.Contacts.wall {
            return
        }

        // If colliding into obstacle, ignore for now
        if contact.bodyA.contactTestBitMask == Globals.Contacts.obstacle ||
            contact.bodyB.contactTestBitMask == Globals.Contacts.obstacle {
//            playSound(sound: .obstacleHit, volume: 0.2)
            return
        }

        // Handle police contacts, capture and remove car node
        if contact.bodyA.contactTestBitMask == Globals.Contacts.police {
            if let contactNode = contact.bodyB.node {
                for (i, node) in carNodes.enumerated() {
                    if node.node.isEqual(to: contactNode) {
                        handlePoliceCapture(carNode: node.node, index: i)
                    }
                }
            }
        }

        // Handle police contacts, capture and remove car node
        if contact.bodyB.contactTestBitMask == Globals.Contacts.police {
            if let contactNode = contact.bodyA.node {
                for (i, node) in carNodes.enumerated() {
                    if node.node.isEqual(to: contactNode) {
                        handlePoliceCapture(carNode: node.node, index: i)
                    }
                }
            }
        }
    }
}
