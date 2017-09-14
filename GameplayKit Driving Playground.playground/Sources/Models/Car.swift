import SpriteKit
import GameplayKit

// Car agent class for both police and normal cars
public class Car: SKNode, GKAgentDelegate {
    var agent: GKAgent2D!
    var node: SKSpriteNode!

    // Car colors are randomly generated from array of color options
    let colorChoices: [String] = [
        "car_red.png",
        "car_green.png",
        "car_blue.png",
        "car_purple.png",
        "car_white.png",
        "car_yellow.png",
        "car_rainbow.png",
        "car_usa.png"
    ]

    // Init car with location on scene and car type (normal/police)
    required public init(location: CGPoint, carType: CarType) {
        let texture: SKTexture!
        let contactMask: UInt32!

        switch carType {
        case .police:
            texture = SKTexture(imageNamed: "car_police.png")
            contactMask = Globals.Contacts.police
        case .normal:
            texture = SKTexture(imageNamed: colorChoices.randomElement())
            contactMask = Globals.Contacts.normal
        }
        
        node = SKSpriteNode(
            texture: texture,
            color: UIColor.red,
            size: CGSize(width: 40, height: 20)
        )
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.mass = 1.0
        node.physicsBody?.contactTestBitMask = contactMask
        node.physicsBody?.allowsRotation = true

        agent = GKAgent2D()
        agent.position = float2(location)
        agent.radius = Float(node.size.width)
        agent.maxSpeed = (carType == .police) ? 75.0 : 70.0
        agent.maxAcceleration = (carType == .police) ? 120.0 : 95.0
        agent.mass = 1.0

        super.init()

        node.position = location

        addChild(node)

        agent.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Update agent to any last-minute node physics changes
    public func agentWillUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent2D else { return }
        agent.position = float2(node.position)
        agent.rotation = Float(node.zRotation)
    }

    // Update node to agent position
    public func agentDidUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent2D else { return }
        node.position = CGPoint(agent.position)
        node.zRotation = CGFloat(agent.rotation)
    }
}
