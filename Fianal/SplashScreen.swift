import SwiftUI
import AVKit



struct SplashScreen: View {
    @State private var isActive = false
    @State private var isOnboardingCompleted = false
    @Environment(\.scenePhase) private var scenePhase
    private let splashDelay = 3.0
    var body: some View {
        ZStack {
            VideoPlayerView(videoName: "splashVideo")
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            isOnboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
            print("Is Onboarding Completed: \(isOnboardingCompleted)")
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDelay) {
                self.isActive = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && !isActive {
                // Optional reset or adjust behavior when app comes to foreground
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if isOnboardingCompleted {
                MainView()
            } else {
                OnboardingView()
            }
        }
    }
}




struct VideoPlayerView: UIViewRepresentable {
    let videoName: String
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .zero, videoName: videoName)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No update logic needed for now
    }
}

class LoopingPlayerUIView: UIView {
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?

    init(frame: CGRect, videoName: String) {
        super.init(frame: frame)
        let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")!
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVQueuePlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer!)

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    @objc private func playerItemDidReachEnd(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
