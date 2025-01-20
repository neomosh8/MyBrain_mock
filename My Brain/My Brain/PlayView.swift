import SwiftUI
import AVFoundation

struct PlayView: View {
    let title: String
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var currentWordIndex: Int = 0
    @State private var audioText: AudioText = AudioText(text: "", words: [])
    @State private var timer: Timer?
    
    // Computed property to get array of Word objects
    private var wordList: [Word] {
        audioText.words
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Wrapped Text
            ScrollViewReader { proxy in
                ScrollView {
                    FlowLayout(
                        data: wordList.indices,   // each Int index
                        spacing: 8
                    ) { index in
                        let word = wordList[index].word
                        // Explicit `return` so Swift knows we produce a View
                        return Text(word)
                            .foregroundColor(index == currentWordIndex ? .black : .primary)
                            .background(index == currentWordIndex ? Color.yellow : Color.clear)
                            .font(index == currentWordIndex ? .headline : .body)
                            .id(index)   // needed for scrollTo()
                    }
                    .padding()
                }
                .onChange(of: currentWordIndex) { newValue in
                    // Auto-scroll to highlighted word
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            // MARK: - Playback Button
            Button(action: {
                togglePlayback()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
            }
        }
        .padding()
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
    
    // MARK: - Audio/JSON Helpers
    
    private func loadAudioText() {
        let jsonFileName = title.replacingOccurrences(of: " ", with: "")
        
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            print("JSON file \(jsonFileName).json not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedAudioText = try decoder.decode(AudioText.self, from: data)
            DispatchQueue.main.async {
                self.audioText = decodedAudioText
            }
        } catch {
            print("Error loading or parsing JSON: \(error.localizedDescription)")
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
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Logic
    
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
        for (index, word) in wordList.enumerated() {
            if currentTime >= word.start && currentTime <= word.end {
                if currentWordIndex != index {
                    currentWordIndex = index
                }
                break
            } else if currentTime > word.end && index == wordList.count - 1 {
                currentWordIndex = index
            }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(title: "ChillVibes")
    }
}
