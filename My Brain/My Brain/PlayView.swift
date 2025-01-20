import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
struct PlayView: View {
    let title: String
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var currentWordIndex: Int = 0
    @State private var audioText: AudioText = AudioText(text: "", words: [])
    @State private var timer: Timer?
    
    private var wordList: [Word] {
        audioText.words
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Wrapping text + auto-scroll
            ScrollViewReader { proxy in
                ScrollView {
                    Flow(spacing: 8) {
                        ForEach(wordList.indices, id: \.self) { index in
                            let word = wordList[index].word
                            Text(word)
                                .foregroundColor(index == currentWordIndex ? .black : .primary)
                                .background(index == currentWordIndex ? Color.yellow : Color.clear)
                                .font(index == currentWordIndex ? .headline : .body)
                                .id(index) // needed for scrollTo
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: currentWordIndex) { newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            // Play/Pause
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, 16)
        .navigationTitle(title)
        .onAppear {
            loadAudioText()
            setupAudioPlayer()
        }
        .onDisappear {
            timer?.invalidate()
            audioPlayer?.stop()
        }
    }
    
    // MARK: - JSON / Audio
    
    private func loadAudioText() {
        let jsonFileName = title.replacingOccurrences(of: " ", with: "")
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            print("JSON file \(jsonFileName).json not found.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedAudioText = try JSONDecoder().decode(AudioText.self, from: data)
            DispatchQueue.main.async {
                self.audioText = decodedAudioText
            }
        } catch {
            print("Error loading/parsing JSON: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioPlayer() {
        let audioFileName = title.replacingOccurrences(of: " ", with: "")
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3") else {
            print("Audio file \(audioFileName).mp3 not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    // MARK: - Playback
    
    private func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            timer?.invalidate()
        } else {
            player.play()
            startTimer()
        }
        isPlaying.toggle()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            currentTime = player.currentTime
            updateCurrentWord()
        }
    }
    
    private func updateCurrentWord() {
        for (index, w) in wordList.enumerated() {
            if currentTime >= w.start && currentTime <= w.end {
                if currentWordIndex != index {
                    currentWordIndex = index
                }
                break
            } else if currentTime > w.end && index == wordList.count - 1 {
                currentWordIndex = index
            }
        }
    }
}
