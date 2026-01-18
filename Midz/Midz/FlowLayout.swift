//
//  FlowLayout.swift
//  Midz
//
//  Custom layout that arranges views in a horizontal
//  flow and wraps them onto new lines as needed.
//

import SwiftUI

/// A layout that positions subviews horizontally and
/// wraps them to the next line when space runs out.
/// Commonly used for tag or chip-style content.
struct FlowLayout: Layout {

    /// Space between items in the layout
    var spacing: CGFloat = 8

    /// Calculates the total size needed to fit all subviews
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {

        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )

        return result.size
    }

    /// Places subviews within the given bounds
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {

        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.frames[index].minX,
                    y: bounds.minY + result.frames[index].minY
                ),
                proposal: .unspecified
            )
        }
    }

    /// Stores calculated frames and overall size
    /// for the flow layout
    struct FlowResult {

        /// Frames for each subview
        var frames: [CGRect] = []

        /// Total size required by the layout
        var size: CGSize = .zero

        /// Computes layout positions based on available width
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {

            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                // Wrap to next line if the current item exceeds max width
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(
                    CGRect(
                        x: currentX,
                        y: currentY,
                        width: size.width,
                        height: size.height
                    )
                )

                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            // Final layout size
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

