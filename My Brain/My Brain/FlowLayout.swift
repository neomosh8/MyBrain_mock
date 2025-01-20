import SwiftUI

/// A flow layout that places subviews horizontally, wrapping to a new line
/// when they no longer fit.
@available(iOS 16.0, *)
struct Flow: Layout {
    /// If you need to store info between layout passes, define a struct.
    /// Otherwise, Void is fine.
    typealias Cache = Void
    
    /// Horizontal spacing between items.
    var spacing: CGFloat = 8
    
    // 1) Create any needed cache (none here).
    func makeCache(subviews: Subviews) -> Cache {
        ()
    }
    
    // 2) Update cache if subviews or other data change (no-op here).
    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        // no caching needed
    }
    
    // 3) Measure how large our layout needs to be.
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        // Use the container's width if provided, else infinite
        let containerWidth = proposal.width ?? .infinity
        
        // Go through each subview, measuring them.
        for subview in subviews {
            // Ask the subview for its "ideal" size
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            // If it won't fit on this line, wrap to next line.
            if width + subviewSize.width > containerWidth {
                width = 0
                height += rowHeight
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, subviewSize.height)
            width += subviewSize.width + spacing
        }
        
        // Add the final row’s height
        height += rowHeight
        
        return CGSize(width: containerWidth, height: height)
    }
    
    // 4) Actually place each subview at the correct (x,y) in that space.
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            // If it doesn't fit in this row, wrap to next line.
            if xOffset + subviewSize.width > bounds.width {
                xOffset = 0
                yOffset += rowHeight
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: bounds.minX + xOffset, y: bounds.minY + yOffset),
                proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height)
            )
            
            xOffset += subviewSize.width + spacing
            rowHeight = max(rowHeight, subviewSize.height)
        }
    }
}
