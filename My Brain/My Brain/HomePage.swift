// HomeView.swift
import SwiftUI

struct HomeView: View {
    let cardData: [CardModel] = [
        CardModel(title: "Chill Vibes", subtitle: "Relaxing music", imageName: "cover1"),
        CardModel(title: "Focus Beats", subtitle: "Stay on task", imageName: "cover2"),
        CardModel(title: "Top 50",     subtitle: "Today’s hits",  imageName: "cover3"),
        CardModel(title: "Throwback",  subtitle: "Classic tunes", imageName: "cover4")
    ]
    
    var body: some View {
        NavigationView {
            // Main vertical stack
            VStack(alignment: .leading, spacing: 16) {
                
                // Top row: "MyBrain" + icons on the right
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
                        Image(systemName: "brain")
                            .font(.title2)
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            // Ultra-thin material background
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 40) // top padding to avoid notch
                
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
                            // Wrap each CardItem in a NavigationLink
                            NavigationLink(destination: PlayView(title: item.title)) {
                                CardItem(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    imageName: item.imageName
                                )
                            }
                            .buttonStyle(PlainButtonStyle()) // Removes the default NavigationLink styling
                        }
                    }
                    .padding(.vertical, 8)
                    // Add a bit of horizontal padding here
                    // to give cards some room on the left/right
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .background(
                // Set a background color or image if needed
                Color.black.edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
