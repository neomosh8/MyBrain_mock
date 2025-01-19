//CardItem.Swift
import SwiftUI

// MARK: - CardItem
struct CardItem: View {
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Cover image on the left
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Title + subtitle on the right
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        // Ultra-thin material for a glossy effect
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        // Optional stroke for an extra border highlight
        // .overlay(
        //    RoundedRectangle(cornerRadius: 12)
        //        .stroke(Color.white.opacity(0.2), lineWidth: 1)
        // )
    }
}
