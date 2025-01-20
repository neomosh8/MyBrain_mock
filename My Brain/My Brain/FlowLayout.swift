import SwiftUI

/// A simple flow layout that places items horizontally until they no longer fit,
/// then wraps to the next line. Works in SwiftUI >= iOS 13.
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geo in
            generateContent(in: geo)
        }
    }
    
    private func generateContent(in geo: GeometryProxy) -> some View {
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(data, id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { dimension in
                        // If the next item won't fit in this row, move to next row:
                        if (xOffset + dimension.width) > geo.size.width {
                            xOffset = 0
                            yOffset += rowHeight
                            rowHeight = 0
                        }
                        let result = xOffset
                        xOffset += dimension.width + spacing
                        rowHeight = max(rowHeight, dimension.height)
                        return -result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = yOffset
                        return -result
                    }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    totalHeight = geo.size.height
                }
            }
        )
    }
}
