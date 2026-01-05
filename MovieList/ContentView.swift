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
                VStack {
                    let _ = print(category)
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
                }
                .toolbar {
                    //                    ToolbarItem(placement: .navigationBarTrailing)
                    //                    {
                    EditButton()
                    //                    }
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
                    NavigationLink(destination: DetailView(movie: movie)) {
                        HStack {
                            WebImage(url: URL(string: "https://image.tmdb.org/t/p/original"+String(movie.poster))).resizable().frame(width: (geometry.size.height/18)*(2/3), height: geometry.size.height/18, alignment: .leading)
                            
                            Text(movie.title)
                                .frame(minWidth: geometry.size.width*(5/12), alignment: .center)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(movie.release)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems) // Swipe to delete
        }
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
