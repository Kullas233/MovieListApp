import SwiftUI
import Foundation
import SDWebImageSwiftUI

class SharedMovie {
    var movie: Movie = Movie()
}

@Observable
class SharedPopup {
    var showPopup: Bool = false
    var popupText: String = ""
}

struct ContentView: View {
    let category: String // Non-editable title
    //    @State private var allMovies: [Movie] = [] // List of items
    let sharedMovies: SharedMovieList
    @State var sharedMovie = SharedMovie()
    @State private var newItemName: String = "" // Holds the input for the new item
    @State private var isAddingNewItem: Bool = false // Toggles text field visibility
    let SharedPopup: SharedPopup
    
    var body: some View
    {
        GeometryReader { geometry in
            NavigationStack() {
                VStack(alignment: .center) {
                    Text(category)
                        .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                if(SharedPopup.showPopup)
                {
                    VStack {
                        Text(SharedPopup.popupText)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Dismiss") {
                            SharedPopup.showPopup = false
                        }
                        .padding()
                    }
                    .frame(minWidth: geometry.size.width/2)
                    .border(Color.black, width: 2)
                    .padding()
                    .padding(EdgeInsets(top: -30, leading: 0, bottom: 10, trailing: 0))
                    .presentationCompactAdaptation(.none) // Forces popover style in compact size classes
                }
                
                VStack {
                    MovieListView(geometry: geometry, category: category, sharedMovies: sharedMovies, sharedMovie: sharedMovie, SharedPopup: SharedPopup)
                    
                    HStack {
                        // Add "+" button to start adding a new item
                        NavigationLink(destination: AddMediaPage(sharedMovies: sharedMovies)) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Item")
                            }
                            .font(.title2)
                        }
                        .buttonStyle(.bordered)
                        .frame(alignment: .center)
                        .padding()
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                        
                        Button("Random") {
                            let chosen = chooseRandom(sharedMovies: sharedMovies)
                            SharedPopup.popupText = String(chosen.title)
                            SharedPopup.showPopup = true
                            
                        }
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: -80))
                        .frame(alignment: .trailing)
                    }
                    .frame(width: geometry.size.width)
                }
                .toolbar {
                    EditButton()
                }
            }
            .frame(minWidth: 400, minHeight: 300) // Default size for macOS
        }
    }
    
    private func chooseRandom(sharedMovies: SharedMovieList) -> Movie {
        for movie in sharedMovies.allMovies {
            print(movie.title)
        }
        
        var type = ""
        var randomInt = -1
        while(randomInt == -1 || (type != category.prefix(2) && type != category.prefix(category.count-1) && category != "All")) {
            
            randomInt = Int.random(in: 0...sharedMovies.allMovies.count-1)
            type = sharedMovies.allMovies[randomInt].mediaType
        }
        
        return sharedMovies.allMovies[randomInt]
    }
}

struct MovieListView: View {
    let geometry: GeometryProxy
    let category: String
    let sharedMovies: SharedMovieList
    let sharedMovie: SharedMovie
    let SharedPopup: SharedPopup
    
    var body: some View {
        // List of items with swipe-to-delete functionality
        List {
            ForEach(sharedMovies.allMovies, id: \.self) { movie in
                if(movie.mediaType == category.prefix(2) || movie.mediaType == category.prefix(category.count-1) || category == "All")
                {
//                    sharedMovie.movie = movie
                    MovieView(geometry: geometry, movie: movie, SharedPopup: SharedPopup)
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
    let SharedPopup: SharedPopup
    
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
        let sharedPopup = SharedPopup()
        ContentView(category: "All", sharedMovies: sharedMovies, SharedPopup: sharedPopup)
            .previewDevice("iPhone 16 Pro")
        ContentView(category: "All", sharedMovies: sharedMovies, SharedPopup: sharedPopup)
            .frame(width: 500, height: 400) // macOS preview
    }
}
