import SwiftUI
import Foundation
import SDWebImageSwiftUI
//import /Users/dkullas/Documents/Xcode/TestList/IOSList/TestListIOS/TestListIOS/Genres.swift

struct ContentView: View {
    let category: String // Non-editable title
    let backNeeded: Bool // Non-editable title
    @State private var allMovies: [Movie] = [] // List of items
    @State private var newItemName: String = "" // Holds the input for the new item
    @State private var isAddingNewItem: Bool = false // Toggles text field visibility
    
    var body: some View
    {
        NavigationStack {
            VStack(alignment: .center) {
                Text(category)
                    .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly
            }
            VStack {
                // List of items with swipe-to-delete functionality
                List {
                    ForEach(allMovies, id: \.self) { movie in
                        if(movie.mediaType == category.prefix(2) || movie.mediaType == category.prefix(category.count-1) || category == "All")
                        {
                            NavigationLink(destination: DetailView(movie: movie)) {
                                let screenSize: CGRect = UIScreen.main.bounds
                                HStack {
                                    WebImage(url: URL(string: "https://image.tmdb.org/t/p/original"+String(movie.poster))).resizable().frame(width: (screenSize.height/18)*(2/3), height: screenSize.height/18, alignment: .center)
                                    
                                    Text(movie.title)
                                        .font(.title)
                                    Text(movie.release)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems) // Swipe to delete
                }
                .onAppear {
                    loadMovieList()
                }
                
                // Add "+" button to start adding a new item
                NavigationLink(destination: AddMediaPage()) {
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
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    EditButton()
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300) // Default size for macOS
    }
    
    // Function to delete items
    private func deleteItems(at offsets: IndexSet) {
        var deleteIndex = 0
        for index in offsets{
            deleteIndex = index
        }
        let deletedMovie = allMovies.remove(at: deleteIndex)
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
    
    // Function to delete items
    private func loadMovieList() {
        allMovies = []
        
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
                    allMovies.append(newMovie)
                }
            }
            catch { print("warning: file read failed!") }
        }
    }
}

// Preview for both platforms
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(category: "All", backNeeded: false)
            .previewDevice("iPhone 16 Pro")
        ContentView(category: "All", backNeeded: false)
            .frame(width: 500, height: 400) // macOS preview
    }
}
