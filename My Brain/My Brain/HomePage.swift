import SwiftUI
import UserNotifications

struct HomeView: View {
    let cardData: [CardModel] = [
        CardModel(title: "Chill Vibes", subtitle: "Relaxing music", imageName: "cover1"),
        CardModel(title: "Focus Beats", subtitle: "Stay on task", imageName: "cover2"),
        CardModel(title: "Top 50",     subtitle: "Today’s hits",  imageName: "cover3"),
        CardModel(title: "Throwback",  subtitle: "Classic tunes", imageName: "cover4")
    ]
    
    // State variable that tracks whether notifications are active
    @State private var isTimerActive = false
    
    // NEW: Track whether to navigate to PerformanceView
    @State private var showPerformanceView = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Top row
                HStack {
                    Text("MyBrain")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Glossy container with icons
                    HStack(spacing: 16) {
                        
                        Image(systemName: "headphones")
                            .font(.title2)
                        
                        // Brain icon -> on tap, show PerformanceView
                        Image(systemName: "brain")
                            .font(.title2)
                            .onTapGesture {
                                showPerformanceView = true
                            }
                        
                        // Example: Underline text-based "Settings":
                        VStack(spacing: 4) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            // Show a small line if isTimerActive is true
                            if isTimerActive {
                                Rectangle()
                                    .frame(height: 2)
                                    .frame(width: 10)
                                    .foregroundColor(.white)
                            }
                        }
                        .onTapGesture {
                            toggleNotification()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                
                // Secondary title
                Text("My Thoughts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
                // Scrollable list of cards
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(cardData) { item in
                            NavigationLink(destination: PlayView(title: item.title)) {
                                CardItem(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    imageName: item.imageName
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // Hidden NavigationLink that is activated by tapping the brain icon
                NavigationLink(
                    destination: PerformanceView(),
                    isActive: $showPerformanceView
                ) {
                    EmptyView()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            checkIfNotificationIsActive()
        }
    }
    
    // MARK: - Local Notification Helpers
    
    func scheduleNotification(everyMinutes minutes: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted, error == nil {
                
                let content = UNMutableNotificationContent()
                content.title = "You have a new thought 💡"
                content.body = "Tap here to explore your new thought: 'Where does sesami come from?'"
                content.sound = .default
                
                // Repeats every X minutes
                let trigger = UNTimeIntervalNotificationTrigger(
                    // timeInterval: Double(minutes * 60),
                    timeInterval: Double(minutes),
                    repeats: true
                )
                
                let request = UNNotificationRequest(
                    identifier: "MyScheduledNotification",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Notification permission not granted or error occurred.")
            }
        }
    }
    
    func cancelScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["MyScheduledNotification"]
        )
    }
    
    func checkIfNotificationIsActive() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isScheduled = requests.contains { $0.identifier == "MyScheduledNotification" }
            DispatchQueue.main.async {
                self.isTimerActive = isScheduled
            }
        }
    }
    
    func toggleNotification() {
        if isTimerActive {
            cancelScheduledNotification()
            isTimerActive = false
        } else {
            scheduleNotification(everyMinutes: 60)
            isTimerActive = true
        }
    }
}

// MARK: - PerformanceView
struct PerformanceView: View {
    var body: some View {
        VStack {
            Text("Performance View")
                .font(.largeTitle)
                .bold()
        }
        .padding()
    }
}
