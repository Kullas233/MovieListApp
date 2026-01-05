import SwiftUI
import Foundation

@Observable
class SharedMovieList {
    var allMovies: [Movie] = []
}

struct MainPage: View {
    @State private var categories: [String] = ["All", "Movies", "TV Shows"] // List of items
    @State private var sharedMovies = SharedMovieList()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Movie Lists")
                    .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly
            }
            .task {
                await loadMovieList()
            }
            VStack {
                // List of items with swipe-to-delete functionality
                List {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: ContentView(category: category, sharedMovies: sharedMovies)) {
                            Text(category)
                        }
                    }
                }
                // Add "+" button to start adding a new item
                NavigationLink(destination: AddMediaPage(sharedMovies:sharedMovies)) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Item")
                    }
                    .font(.title2)
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .frame(minWidth: 400, minHeight: 300) // Default size for macOS
    
    }
    
    private func loadMovieList() async {
        let _ = print("LOSD")
        sharedMovies.allMovies = []
        
        let file = "myMovieList.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(file)
            
//            do {
//                try "".write(to: fileURL, atomically: false, encoding: .utf8)
//            }
//            catch { print("warning: file write failed!") }

            //reading
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                let allMoviesFromFile = text.components(separatedBy: "\n")
                
                for movieFromFile in allMoviesFromFile {
                    if(movieFromFile == "") {
                        continue
                    }
                    
                    let movieFromFile = movieFromFile.components(separatedBy: "*$*@*")
                    print(movieFromFile)
                    
                    let newMovie = Movie(mediaType: movieFromFile[0], title: Substring(movieFromFile[1]), id: Substring(movieFromFile[2]), overview: Substring(movieFromFile[3]), genreIds: Substring(movieFromFile[4]), release: Substring(movieFromFile[5]), poster: Substring(movieFromFile[6]), backdrop: Substring(movieFromFile[7]), popularity: Substring(movieFromFile[8]))
//                    let newMovie = Movie()
                    sharedMovies.allMovies.append(newMovie)
                }
            }
            catch { print("warning: file read failed!") }
        }
    }
}

// Preview for both platforms
struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
            .previewDevice("iPhone 16 Pro")
        MainPage()
            .frame(width: 500, height: 400) // macOS preview
    }
}
