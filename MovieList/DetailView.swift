import SwiftUI
import Foundation
import SDWebImageSwiftUI

struct DetailView: View {
    let movie: Movie // Non-editable title
    @State private var imdbId: String = "" // Holds the input for the link
    @State private var mdId: Int32 = -1 // Holds the input for the link
    @State private var savedId: String? // Stores the saved link
    
    // Placeholder IMDb-like information
    @State private var Title: String = "N/A"
    @State private var Genre: String = "N/A"
    @State private var ReleaseDate: String = "N/A"
    @State private var Popularity: String = "N/A"
    @State private var Description: String = "N/A"
    @State private var ImageURL: String = "N/A"
    
    var body: some View {
        let screenSize: CGRect = UIScreen.main.bounds
        VStack(alignment: .leading) {
            // Static title
            Text(movie.title)
                .font(.largeTitle)
                .bold()
                .padding()
                .frame(alignment: .center)
            
            Divider()
            
            // IMDb-like fields
            ScrollView(.vertical) {

                WebImage(url: URL(string: ImageURL)).resizable().frame(width: screenSize.width-20, height: (screenSize.width-20)/1.778, alignment: .center)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Title: \(Title)")
                        .font(.headline)
                    
                    Text("Genre: \(Genre)")
                        .font(.headline)
                    
                    Text("Release Date: \(ReleaseDate)")
                        .font(.headline)
                    
                    Text("Popularity: \(Popularity)")
                        .font(.headline)
                    
                    Text("Description:")
                        .font(.headline)
                        .padding(.bottom, -5)
                    
                    TextField(Description, text: $Description, axis: .vertical)
                }
                .padding()
                .frame(alignment: .center)
            }
            .frame(maxWidth: screenSize.width, alignment: .center)
            .onAppear {
                loadMovieDetails()
            }
        }
        .frame(maxWidth: screenSize.width)
    }
    // Function to simulate loading IMDb-like details
    private func loadMovieDetails() {
        // In a real app, you would fetch this data from an API like IMDb or TMDb.
        ImageURL = "https://image.tmdb.org/t/p/original"+String(movie.backdrop)
        Title = String(movie.title)
        Genre = String(movie.getGenres())
        ReleaseDate = String(movie.release)
        Popularity = String(movie.popularity)
        Description = String(movie.overview)
    }
}

// Preview for both platforms
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let movie: Movie = Movie.init()
        DetailView(movie: movie)
            .previewDevice("iPhone 16 Pro")
        DetailView(movie: movie)
            .frame(width: 500, height: 400) // macOS preview
    }
}
