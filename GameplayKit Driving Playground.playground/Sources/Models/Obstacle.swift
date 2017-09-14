import SpriteKit
import GameplayKit

// Obstacle agent class, depicted as a safety cone on scene
public class Obstacle: SKNode, GKAgentDelegate {
    var agent: GKAgent2D!
    var node: SKSpriteNode!

    // Init obstacle with location on scene
    required public init(location: CGPoint) {
        node = SKSpriteNode(
            texture: SKTexture(imageNamed: "obstacle_cone.png"),
            color: UIColor.orange,
            size: CGSize(width: 15, height: 15)
        )
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.height / 2.2)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.mass = 0.001
        node.physicsBody?.contactTestBitMask = Globals.Contacts.obstacle
        node.physicsBody?.allowsRotation = true

        agent = GKAgent2D()
        agent.position = float2(location)
        agent.radius = Float(node.size.height)
        agent.mass = 0.001
        agent.maxSpeed = 0.0
        agent.maxAcceleration = 0.0

        super.init()

        node.position = location

        addChild(node)

        agent.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func agentWillUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent2D else { return }
        agent.position = float2(node.position)
        agent.rotation = Float(node.zRotation)
    }

    public func agentDidUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent2D else { return }
        node.position = CGPoint(agent.position)
        node.zRotation = CGFloat(agent.rotation)
    }
}
