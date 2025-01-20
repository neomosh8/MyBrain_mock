import SwiftUI
import AVFoundation


// MARK: - View
@available(iOS 16.0, *)
struct PlayView: View {
    let title: String
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var currentWordIndex: Int = 0
    @State private var audioText: AudioText = AudioText(text: "", words: [])
    
    // We will fill this with indexes of the first occurrence of our “special words.”
    @State private var highlightIndices: Set<Int> = []
    
    // Words that should appear bigger, bold, and with a blue highlight—ONLY on the first occurrence
    // (Adjust this list to be exactly the words and punctuation you want to highlight.)
    let specialWords: Set<String> = [
        "Emma",
        "bored",

    ]
    
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
                            let wordItem = wordList[index]
                            let theWord   = wordItem.word
                            
                            // Check if this is the current word being played
                            let isCurrent = (index == currentWordIndex)
                            // Check if this index is in our "highlight me" set
                            let isHighlight = highlightIndices.contains(index)
                            
                            // Decide styling:
                            if isCurrent && isHighlight {
                                Text(theWord)
                                    .font(.title)            // larger font
                                    .bold()                   // bold
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.blue)   // blue background
                                    .id(index)                // so we can scroll to it
                            }
                            else if isCurrent {
                                // currently playing, but NOT one of the highlight words
                                Text(theWord)
                                    .foregroundColor(.black)
                                    .background(Color.yellow)
                                    .font(.headline)
                                    .id(index)
                            }
                            else if isHighlight {
                                // highlight word, but not currently playing
                                Text(theWord)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .id(index)
                            }
                            else {
                                // Normal word
                                Text(theWord)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .id(index)
                            }
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
}

// MARK: - Private Methods
@available(iOS 16.0, *)
extension PlayView {
    
    private func loadAudioText() {
        let jsonFileName = title.replacingOccurrences(of: " ", with: "")
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            print("JSON file \(jsonFileName).json not found.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedAudioText = try JSONDecoder().decode(AudioText.self, from: data)
            
            // Once loaded, figure out which word indices should be specially highlighted
            buildHighlightIndices(for: decodedAudioText)
            
            DispatchQueue.main.async {
                self.audioText = decodedAudioText
            }
        } catch {
            print("Error loading/parsing JSON: \(error.localizedDescription)")
        }
    }
    
    /// Only mark the *first* occurrence of each special word in highlightIndices
    private func buildHighlightIndices(for decodedAudioText: AudioText) {
        var usedWords = Set<String>()
        var newHighlights = Set<Int>()
        
        for (index, w) in decodedAudioText.words.enumerated() {
            let token = w.word
            
            // If it's in our specialWords set and we haven't used it yet, mark it
            if specialWords.contains(token) && !usedWords.contains(token) {
                newHighlights.insert(index)
                usedWords.insert(token)
            }
        }
        
        // Update state
        self.highlightIndices = newHighlights
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
            }
            else if currentTime > w.end && index == wordList.count - 1 {
                currentWordIndex = index
            }
        }
    }
}
