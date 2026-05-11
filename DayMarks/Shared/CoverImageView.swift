import SwiftUI
import UIKit

struct CoverImageView: View {
    let fileName: String?
    let colorHex: String

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color(hex: colorHex)
                Image(systemName: "calendar")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
    }

    private var image: UIImage? {
        guard let fileName else { return nil }
        return UIImage(contentsOfFile: EventStorage.coverURL(fileName: fileName).path)
    }
}

