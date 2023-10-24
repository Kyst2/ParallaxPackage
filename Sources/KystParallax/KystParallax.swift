
import Foundation
import SwiftUI
import CoreMotion

#if os(iOS)
@available(iOS 13.0, *)
public struct ParallaxLayer:View {
    @ObservedObject var manager = MotionManager()
    
    var image:Image
    var magnitude:Double
    
    public var body: some View {
        image
            .modifier(ParallaxMotionModifier(manager: manager, magnitude: magnitude ))
    }
    
    public init(image: Image, magnitude: Double) {
        self.image = image
        self.magnitude = magnitude
    }
}


@available(iOS 13.0, *)
struct ParallaxMotionModifier: ViewModifier {
    @ObservedObject var manager: MotionManager
    var magnitude: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class MotionManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    private var manager: CMMotionManager
    
    public init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
        self.manager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let motionData = motionData {
                self.pitch = motionData.attitude.pitch
                self.roll = motionData.attitude.roll
            }
        }
    }
}

#elseif os(macOS)

@available(macOS 10.15, *)
public struct ParallaxLayer: View {
    let image: Image
    let speed: CGFloat
    
    @State private var absXOffset: CGFloat = 0
    @State private var absYOffset: CGFloat = 0
    
    @State private var isMouseInside: Bool = false
    @State private var previousMousePosition: CGPoint = .zero
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
//            .scaledToFit()
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .offset(x: absXOffset  , y: absYOffset )
            .animation(.easeInOut(duration: 0.1), value: absYOffset) //Y changed after X and we can play smooth animation
            .onAppear { subscribeParallaxAnim() }
    }
    
    private func subscribeParallaxAnim() {
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .mouseEntered, .mouseExited]) { event in
            guard let window = NSApp.windows.first(where: { $0.isVisible }),
                  let contentView = window.contentView else {
                return event
            }
            
            let mouseLocation = event.locationInWindow
            let mouseInView = contentView.convert(mouseLocation, from: nil)
            
            if event.type == .mouseEntered {
                isMouseInside = true
            } else if event.type == .mouseExited {
                isMouseInside = false
            }
            
            if isMouseInside {
                let windowRect = window.frame
                let windowOrigin = windowRect.origin
                
                let windowCenter = NSPoint(x: windowOrigin.x + windowRect.width / 2, y: windowOrigin.y + windowRect.height / 2)
                
                let mousePosRelatedToWndCenter = NSPoint(x: mouseInView.x - windowCenter.x, y: mouseInView.y - windowCenter.y)
                
                // -1...1 * speed
                let deltaXRel = (mouseInView.x / windowRect.width - 0.5) * 2 * speed
                let deltaYRel = (mouseInView.y / windowRect.height - 0.5) * 2 * speed
                
                let deltaFinalX = (deltaXRel - absXOffset)
                let deltaFinalY = (deltaYRel - absYOffset)
                
                absXOffset += deltaFinalX
                absYOffset += deltaFinalY
                
                previousMousePosition = mousePosRelatedToWndCenter
            }
            
            return event
        }
    }
    
    public init(image: Image, speed: CGFloat = 1) {
        self.image = image
        self.speed = speed
    }
}

#endif
