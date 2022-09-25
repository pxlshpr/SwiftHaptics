#if canImport(UIKit)
import UIKit
import CoreHaptics

@available(iOS 13.0, *)

public class Haptics {

    public static func feedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.impactOccurred()
    }
    
    public static func selectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    public static func transientHaptic() {
        guard haveNotPlayedRecently else { return }

        startIfNeeded()
        let events = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        ], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [events], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
            lastPlayedDate = Date()
        } catch {
            print("Error playing haptic: \(error)")
        }
    }
    
    public static func errorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    public static func successFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    public static func warningFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    //MARK: - Private
    private struct Constants {
        static let minimumPlayInterval: TimeInterval = 0.2
    }
    
    private static var engine: CHHapticEngine?
    private static var hasStarted: Bool = false
    private static var lastPlayedDate: Date? = nil

    private static var haveNotPlayedRecently: Bool {
        guard let lastPlayedDate = lastPlayedDate else { return true }
        let timeInterval = Date().timeIntervalSince(lastPlayedDate)
        return timeInterval >= Self.Constants.minimumPlayInterval
    }
    
    private static func startIfNeeded() {
        if !hasStarted {
            startEngine()
            addObservers()
        }
    }
    
    private static func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground),
                                               name: UIScene.willEnterForegroundNotification, object: nil)
    }
     
    @objc private static func appMovedToForeground(notification: Notification) {
        ///restart engine whenever we move back to foreground
        startEngine()
    }
    
    private static func startEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
//            print("Haptics not supported")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            hasStarted = true
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
}

#endif
