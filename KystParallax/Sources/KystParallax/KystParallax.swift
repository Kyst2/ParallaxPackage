
import Foundation
import SwiftUI
import CoreMotion

#if os(iOS)
public struct ParallaxLayer:View {
    @ObservedObject var manager = MotionManager()
    var image:Image
    var magnitude:Int
    var body: some View {
        image
            .modifier(ParallaxMotionModifier(manager: manager, magnitude: magnitude ))
    }
    init(image: Image, magnitude: Int) {
        self.image = image
        self.magnitude = magnitude
    }
}

struct ParallaxMotionModifier: ViewModifier {
    
    @ObservedObject var manager: MotionManager
    var magnitude: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
    }
}

class MotionManager: ObservableObject {
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    private var manager: CMMotionManager
    
    init() {
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
public struct ParallaxLayer:View {
    var image:Image
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    public var body: some View{
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
                    let mouseLocation = event.locationInWindow
                    let windowLocation = NSApp.windows[0].frame.origin
                    let mouseInView = CGPoint(x: mouseLocation.x - windowLocation.x, y: mouseLocation.y - windowLocation.y)
                    xOffset = ((NSScreen.main!.frame.width / 2) - mouseInView.x) / 50
                    yOffset = (mouseInView.y - (NSScreen.main!.frame.height / 2)) / 50
                    return event
                }
            }
    }
    init(image: Image) {
        self.image = image
    }
}
#endif
