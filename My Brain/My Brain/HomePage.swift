import SwiftUI
import UserNotifications

struct HomeView: View {
    let cardData: [CardModel] = [
        CardModel(
            title: "Maximize Your Mornings",
            subtitle: "A quick routine can energize your entire day.",
            imageName: "cover1"
        ),

        CardModel(
            title: "The Mindset Mentor Podcast EP #117",
            subtitle: "Define goals and pursue them wholeheartedly.",
            imageName: "cover2"
        ),

        CardModel(
            title: "Atomic Habits by James Clear",
            subtitle: "Small daily changes create big results.",
            imageName: "cover3"
        ),

        CardModel(
            title: "On Purpose with Jay Shetty EP #76",
            subtitle: "Turn setbacks into opportunities for growth.",
            imageName: "cover4"
        ),

        CardModel(
            title: "Embrace Lifelong Learning",
            subtitle: "Invest in skills that expand your horizon.",
            imageName: "cover5"
        ),

        CardModel(
            title: "Deep Work by Cal Newport",
            subtitle: "Guard your focus to achieve meaningful output.",
            imageName: "cover6"
        ),

        CardModel(
            title: "Unlocking Us with Brené Brown EP #42",
            subtitle: "Use vulnerability to build genuine connections.",
            imageName: "cover7"
        ),

        CardModel(
            title: "Think Again by Adam Grant",
            subtitle: "Reevaluate beliefs for continuous growth.",
            imageName: "cover8"
        ),

        CardModel(
            title: "The 1% Better Principle",
            subtitle: "Tiny improvements lead to major milestones.",
            imageName: "cover9"
        ),

        CardModel(
            title: "Blockchain for Everyday Use",
            subtitle: "Secure, decentralized solutions beyond crypto.",
            imageName: "cover7"
        )

    ]
    
    /// 1) Create a PerformanceViewModel instance
    @StateObject private var performanceViewModel = PerformanceViewModel()
    
    // State variable that tracks whether notifications are active
    @State private var isTimerActive = false
    
    // New: Flag to control navigation to PerformanceView
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
                        
//                        Image(systemName: "headphones")
                        Image("headphone")
                            .resizable()  // Makes the image resizable
                            .aspectRatio(contentMode: .fit)  // Maintains aspect ratio
                            .frame(width: 30, height: 30)  // Common size for interface icons
                            .font(.title2)
                        
                        /// 2) On tap, set `showPerformanceView` to true,
                        ///    which triggers the NavigationLink below
                        Image(systemName: "brain")
                            .font(.title2)
                            .onTapGesture {
                                showPerformanceView = true
                            }
                        
                        VStack(spacing: 4) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.white)
                            
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
                
                /// 3) Hidden NavigationLink that becomes active when
                ///    `showPerformanceView` is set to true
                NavigationLink(
                    destination: PerformanceView(viewModel: performanceViewModel),
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
                content.body = "Explore your new thought: 'Habits, Deep Focus & Lifelong Learning'"

                content.sound = .default
                
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
