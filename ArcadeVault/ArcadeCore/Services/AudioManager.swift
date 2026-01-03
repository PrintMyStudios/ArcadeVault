import AVFoundation

/// Manages procedural audio SFX
final class AudioManager {
    static let shared = AudioManager()

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private let format: AVAudioFormat

    var isEnabled: Bool {
        get { PersistenceStore.shared.soundEnabled }
        set { PersistenceStore.shared.soundEnabled = newValue }
    }

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("AudioManager: Failed to start audio engine: \(error)")
        }
    }

    func play(_ sound: SoundType) {
        guard isEnabled else { return }

        let frequency: Float
        let duration: Float
        let volume: Float

        switch sound {
        case .menuSelect:
            frequency = 880
            duration = 0.05
            volume = 0.3
        case .gameStart:
            frequency = 440
            duration = 0.15
            volume = 0.4
        case .collect:
            frequency = 1320
            duration = 0.08
            volume = 0.35
        case .hit:
            frequency = 220
            duration = 0.1
            volume = 0.5
        case .gameOver:
            frequency = 165
            duration = 0.3
            volume = 0.5
        case .powerUp:
            frequency = 660
            duration = 0.2
            volume = 0.45
        case .waveComplete:
            frequency = 880
            duration = 0.25
            volume = 0.5
        }

        playTone(frequency: frequency, duration: duration, volume: volume)
    }

    private func playTone(frequency: Float, duration: Float, volume: Float) {
        guard let player = playerNode, let engine = audioEngine else { return }

        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return }

        let angularFrequency = 2.0 * Float.pi * frequency / sampleRate

        for frame in 0..<Int(frameCount) {
            let sample = sin(angularFrequency * Float(frame))
            let envelope = 1.0 - (Float(frame) / Float(frameCount))
            channelData[frame] = sample * envelope * volume
        }

        if !engine.isRunning {
            try? engine.start()
        }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    func stopAll() {
        playerNode?.stop()
    }
}
