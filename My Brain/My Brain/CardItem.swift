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
                    .foregroundColor(.secondary)
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
