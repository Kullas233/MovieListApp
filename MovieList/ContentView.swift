import SwiftUI
import Foundation
import SDWebImageSwiftUI

class SharedMovie {
    var movie: Movie = Movie()
}

struct ContentView: View {
    let category: String // Non-editable title
    //    @State private var allMovies: [Movie] = [] // List of items
    let sharedMovies: SharedMovieList
    @State var sharedMovie = SharedMovie()
    @State private var newItemName: String = "" // Holds the input for the new item
    @State private var isAddingNewItem: Bool = false // Toggles text field visibility
    
    var body: some View
    {
        GeometryReader { geometry in
            NavigationStack() {
                VStack(alignment: .center) {
                    Text(category)
                        .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                VStack {
                    MovieListView(geometry: geometry, category: category, sharedMovies: sharedMovies, sharedMovie: sharedMovie)
                    
                    // Add "+" button to start adding a new item
                    NavigationLink(destination: AddMediaPage(sharedMovies: sharedMovies)) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Item")
                        }
                        .font(.title2)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                }
                .toolbar {
                    EditButton()
                }
            }
            .frame(minWidth: 400, minHeight: 300) // Default size for macOS
        }
    }
}

struct MovieListView: View {
    let geometry: GeometryProxy
    let category: String
    let sharedMovies: SharedMovieList
    let sharedMovie: SharedMovie
    var body: some View {
        // List of items with swipe-to-delete functionality
        List {
            ForEach(sharedMovies.allMovies, id: \.self) { movie in
                if(movie.mediaType == category.prefix(2) || movie.mediaType == category.prefix(category.count-1) || category == "All")
                {
//                    sharedMovie.movie = movie
                    MovieView(geometry: geometry, movie: movie)
                }
            }
            .onDelete(perform: deleteItems) // Swipe to delete
        }
        .scrollContentBackground(.hidden) // Hides the default background
        .background(Color(red: 0.87, green: 0.87, blue: 0.87, opacity: 1.0))
        .padding(EdgeInsets(top: -20, leading: 0, bottom: -20, trailing: 0))
    }
    
    // Function to delete items
    private func deleteItems(at offsets: IndexSet) {
        var deleteIndex = 0
        for index in offsets{
            deleteIndex = index
        }
        let deletedMovie = sharedMovies.allMovies.remove(at: deleteIndex)
        var newFileText = ""
        
        let file = "myMovieList.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(file)

            //reading
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                let allMoviesFromFile = text.components(separatedBy: "\n")
                
                for movieFromFile in allMoviesFromFile {
                    if(movieFromFile == "") {
                        continue
                    }
                    
                    let movieTextFromFile = movieFromFile.components(separatedBy: "*$*@*")
                    if(movieTextFromFile[2] != deletedMovie.id)
                    {
                        newFileText = newFileText+movieFromFile+"\n"
                    }
                }
            }
            catch { print("warning: file read failed!") }
            
            //writing
            do {
                try newFileText.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch { print("warning: file write failed!") }
        }
    }
}

struct MovieView: View {
    let geometry: GeometryProxy
    let movie: Movie
    
    var body: some View {
        NavigationLink(destination: DetailView(movie: movie)) {
            
            
            HStack {
                Text("")
                WebImage(url: URL(string: "https://image.tmdb.org/t/p/original"+String(movie.poster))).resizable().frame(width: (geometry.size.height/13)*(2/3), height: geometry.size.height/13, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
                
                Text(movie.title)
                    .lineLimit(3)
                    .frame(minWidth: geometry.size.width*(5/12), maxHeight: geometry.size.height/11, alignment: .center)
                    .multilineTextAlignment(.center)
                    .font(.custom("Avenir-Black", size: 30))
                    .minimumScaleFactor(0.05) // Allow it to shrink to 5% of original size
                Text(movie.release)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height/18, alignment: .trailing)
            }
        }
        .listRowBackground(Color(red: 0.95, green: 0.95, blue: 0.95, opacity: 1.0))
    }
}

// Preview for both platforms
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let sharedMovies = SharedMovieList()
        ContentView(category: "All", sharedMovies: sharedMovies)
            .previewDevice("iPhone 16 Pro")
        ContentView(category: "All", sharedMovies: sharedMovies)
            .frame(width: 500, height: 400) // macOS preview
    }
}
