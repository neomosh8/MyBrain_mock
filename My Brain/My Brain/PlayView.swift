import SwiftUI
import AVFoundation

struct PlayView: View {
    let title: String
    
    // MARK: - Properties
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var currentWordIndex: Int = 0
    @State private var audioText: AudioText = AudioText(text: "", words: [])
    @State private var timer: Timer?
    
    // Computed property to split text into words
    private var wordList: [Word] {
        audioText.words
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 40) {
            // Text Highlighting Section
            ScrollView {
                Text(highlightedText())
                    .font(.title2)
                    .padding()
            }
            
            // Play Button
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
    
    // MARK: - Functions
    
    /// Load the AudioText data from JSON file
    private func loadAudioText() {
        // Derive the JSON filename from the title
        // Assuming JSON filenames have no spaces and end with .json
        let jsonFileName = title.replacingOccurrences(of: " ", with: "") // e.g., "Chill Vibes" -> "ChillVibes"
        
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
    
    /// Setup the AVAudioPlayer
    private func setupAudioPlayer() {
        // Use the updated filename without spaces
        let audioFileName = title.replacingOccurrences(of: " ", with: "") // e.g., "Chill Vibes" -> "ChillVibes"
        
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
    
    /// Toggle playback state
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
    
    /// Start the timer to track playback time
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            currentTime = player.currentTime
            updateCurrentWord()
        }
    }
    
    /// Update the current word index based on currentTime
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
    
    /// Generate the highlighted text
    private func highlightedText() -> AttributedString {
        var attributed = AttributedString(audioText.text)
        
        for (index, word) in wordList.enumerated() {
            // Find the range of the word in the full text
            // This simplistic approach assumes words are unique and in order
            if let range = attributed.range(of: word.word) {
                if index == currentWordIndex && isPlaying {
                    attributed[range].foregroundColor = .blue
                    attributed[range].font = .headline
                } else {
                    attributed[range].foregroundColor = .primary
                    attributed[range].font = .body
                }
            }
        }
        
        return attributed
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(title: "ChillVibes") // Use the updated title without spaces
    }
}
