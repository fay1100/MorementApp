import Foundation
import Combine

class BoardTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval
    var timer: Timer?
    
    init(timeRemaining: TimeInterval = 86400) { // 86400 seconds = 24 hours
        self.timeRemaining = timeRemaining
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTime() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            stop()
        }
    }
    
    deinit {
        stop()
    }
}
import SwiftUI

struct TimerView: View {
    @ObservedObject var boardTimer: BoardTimer
    
    var body: some View {
        Text(timeString(from: boardTimer.timeRemaining))
            .font(.headline)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
