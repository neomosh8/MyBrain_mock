import SwiftUI

struct CardItem: View {
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Larger cover image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Bigger text sizes
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)            // Bigger headline
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.body)              // Larger subheadline
                    .foregroundColor(
                            Color(UIColor { traitCollection in
                                // If the system is in Light Mode, return a darker gray
                                // Otherwise, return the system's default secondary label color
                                traitCollection.userInterfaceStyle == .light
                                ? .black
                                : .secondaryLabel
                            })
                        )
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

