import SwiftUI
import Foundation
import SDWebImageSwiftUI

struct AddMediaPage: View {
    @State private var newItemName: String = "" // Holds the input for the new item
    @State private var searchItems: [Movie] = [] // Holds the input for the new item
    @State private var showPopup: Bool = false
    @State private var popupText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Add")
                    .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly

                // Show text field
                HStack {
                    TextField("Enter item name", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Search") {
                        searchItems = []
                        searchItem()
                    }
                    .padding()
                    .disabled(newItemName.isEmpty) // Disable if the text field is empty
                    
                    Button("Clear") {
                        newItemName = "" // Clear text field
                        searchItems = []
                    }
                    .padding()
                }
                
                if(showPopup)
                {
                    VStack {
                        Text(popupText)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Dismiss") {
                            showPopup = false
                        }
                        .padding()
                    }
                    .border(Color.black, width: 2)
                    .presentationCompactAdaptation(.none) // Forces popover style in compact size classes
                }
                
                // List of items from search
                List {
                    ForEach(searchItems, id: \.self) { item in
                        Button(action: { addItem(movieToAdd: item) }) {
                            SearchItemView(item: item)
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    // Function to add a new item
    private func searchItem() 
    {
        let _ = Task
        {
            let url = URL(string: "https://api.themoviedb.org/3/search/multi")!
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: newItemName),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            ]
            components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZTA1MDViMWE2Yjg4MGFmOWE1M2JiNTIyMTNlNjA4YSIsIm5iZiI6MTc0MDE4OTk2NS44MDgsInN1YiI6IjY3YjkzMTBkZDM2MzE2OTQ2NjQ2NDMxZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AXjW2KApOE0a3uNlz3RHZ8V3my5uRsG1-cZiMia8hcY"
            ]

            let (data, _) = try await URLSession.shared.data(for: request)
//            print(String(decoding: data, as: UTF8.self))
            let siteData = String(decoding: data, as: UTF8.self)

            let searchItemsText = siteData.components(separatedBy: "{\"adult\":")
            var mediaType = ""
            for movie in searchItemsText.dropFirst()
            {
                let fixedMovie = movie.replacing("\n", with: "")
                print(fixedMovie)
                print("######################################################################")
                print("######################################################################")
                print("######################################################################")
                
                mediaType = ""
                if(fixedMovie.contains("\"media_type\":\"person\""))
                {
                    continue
                }
                else if(fixedMovie.contains("\"original_title\":"))
                {
                    mediaType = "Movie"
                }
                else if(fixedMovie.contains("\"original_name\":"))
                {
                    mediaType = "TV"
                }
                
                var title: Substring = ""
                var id: Substring = ""
                var release: Substring = ""
                if(mediaType == "Movie")
                {
                    let startTitle = fixedMovie.range(of: "\"title\":\"")!.upperBound
                    let endTitle = fixedMovie.suffix(from: startTitle).range(of: "\",\"")!.lowerBound
                    let rangeTitle = startTitle..<endTitle
                    title = fixedMovie[rangeTitle]
                    
                    let startId = fixedMovie.range(of: "\"id\":")!.upperBound
                    let endId = fixedMovie.suffix(from: startId).range(of: ",\"title")!.lowerBound
                    let rangeId = startId..<endId
                    id = fixedMovie[rangeId]
                    
                    let startRelease = fixedMovie.range(of: "\"release_date\":\"")!.upperBound
                    let endRelease = fixedMovie.suffix(from: startRelease).range(of: "\",\"")!.lowerBound
                    let rangeRelease = startRelease..<endRelease
                    release = fixedMovie[rangeRelease]
                }
                else if(mediaType == "TV")
                {
                    let startName = fixedMovie.range(of: "\"name\":\"")!.upperBound
                    let endName = fixedMovie.suffix(from: startName).range(of: "\",\"")!.lowerBound
                    let rangeName = startName..<endName
                    title = fixedMovie[rangeName]
                    
                    let startId = fixedMovie.range(of: "\"id\":")!.upperBound
                    let endId = fixedMovie.suffix(from: startId).range(of: ",\"name")!.lowerBound
                    let rangeId = startId..<endId
                    id = fixedMovie[rangeId]
                    
                    let startRelease = fixedMovie.range(of: "\"first_air_date\":\"")!.upperBound
                    let endRelease = fixedMovie.suffix(from: startRelease).range(of: "\",\"")!.lowerBound
                    let rangeRelease = startRelease..<endRelease
                    release = fixedMovie[rangeRelease]
                }
                else
                {
                    print("person")
                }
                
                let startOverview = fixedMovie.range(of: "\"overview\":\"")!.upperBound
                let endOverview = fixedMovie.suffix(from: startOverview).range(of: "\",\"")!.lowerBound
                let rangeOverview = startOverview..<endOverview
                let overview = fixedMovie[rangeOverview]
                
                let startGenre = fixedMovie.range(of: "\"genre_ids\":[")!.upperBound
                let endGenre = fixedMovie.suffix(from: startGenre).range(of: "],\"")!.lowerBound
                let rangeGenre = startGenre..<endGenre
                let genreIds = fixedMovie[rangeGenre]
                
                var backdrop: Substring = ""
                if(!fixedMovie.contains("\"backdrop_path\":null"))
                {
                    let startBackdrop = fixedMovie.range(of: "\"backdrop_path\":\"")!.upperBound
                    let endBackdrop = fixedMovie.suffix(from: startBackdrop).range(of: "\",\"")!.lowerBound
                    let rangeBackdrop = startBackdrop..<endBackdrop
                    backdrop = fixedMovie[rangeBackdrop]
                }
                else
                {
                    backdrop = "null"
                }
                
                var poster: Substring = ""
                if(!fixedMovie.contains("\"poster_path\":null"))
                {
                    let startPoster = fixedMovie.range(of: "\"poster_path\":\"")!.upperBound
                    let endPoster = fixedMovie.suffix(from: startPoster).range(of: "\",\"")!.lowerBound
                    let rangePoster = startPoster..<endPoster
                    poster = fixedMovie[rangePoster]
                }
                else
                {
                    poster = "null"
                }
                
                let startPopularity = fixedMovie.range(of: "\"popularity\":")!.upperBound
                let endPopularity = fixedMovie.suffix(from: startPopularity).range(of: ",\"")!.lowerBound
                let rangePopularity = startPopularity..<endPopularity
                let popularity = fixedMovie[rangePopularity]

                let newMovie = Movie(mediaType: mediaType, title: title, id: id, overview: overview, genreIds: genreIds, release: release, poster: poster, backdrop: backdrop, popularity: popularity)
                searchItems.append(newMovie)
                
            //     // Console Output
                // print(title)
                // print(overview)
                // print(id)
    //              let genreInts = genreList.split(separator: ",")
                // Loop through the resulting collection
    //              for genre in genreInts {
    //                  print(Genres[String(genre)] ?? "!!!New Genre!!!")
    //              }
    //              print(popularity)
                // print(release)
            //     print(movieData)
                
                
            //     // Update Screen
            //     Title = String(title)
            //     Description = String(overview)
            //     Genre = genreOutput
            //     ReleaseDate = String(release)
            //     ImageURL = "https://image.tmdb.org/t/p/original"+String(backdrop)
            }
        }
    }

    // Function to add a new item
    private func addItem(movieToAdd: Movie) {
        let filename = "myMovieList.txt"
            
        // Get the document directory path
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)

            guard let data = movieToAdd.getData().data(using: .utf8) else {
                popupText = "Internal Error"
                showPopup = true
                print("Failed to convert string to data")
                return
            }
            
            //reading
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                let find = "*$*@*" + movieToAdd.id + "*$*@*"
                if(text.contains(find)) {
                    popupText = "This item is already in your list!"
                    showPopup = true
                    return
                }
            }
            catch { popupText = "Internal Error" ; showPopup = true ; print("warning: file read failed!") }
            
            // differnt writing
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    defer {
                        fileHandle.closeFile()
                    }
                    fileHandle.seekToEndOfFile() // Move the file pointer to the end
                    fileHandle.write(data) // Write the new data
                } else {
                    popupText = "Internal Error"
                    showPopup = true
                    print("Failed to open file handle for writing")
                }
            } else {
                // If the file does not exist, create it with the initial content
                do {
                    try data.write(to: fileURL, options: .atomic)
                } catch {
                    popupText = "Internal Error"
                    showPopup = true
                    print("Failed to create file: \(error.localizedDescription)")
                }
            }
        }
        popupText = movieToAdd.title+" was added to your list!"
        showPopup = true
    }
}

struct SearchItemView: View {
    let item: Movie
    var body: some View {
        VStack(alignment: .center) {
            let screenSize: CGRect = UIScreen.main.bounds
            
            ScrollView(.horizontal) {
                Text(item.title)
                    .font(.title2)
            }
            .defaultScrollAnchor(.center, for: .alignment)
            
            HStack {
                WebImage(url: URL(string: "https://image.tmdb.org/t/p/original"+String(item.poster))).resizable().frame(width: (screenSize.height/10)*(2/3), height: screenSize.height/10, alignment: .center)
                
                ScrollView(.vertical) {
                    Text(item.overview)
                }
                .frame(width: (screenSize.width-screenSize.width*0.2)-((screenSize.height/10)*(2/3)), height: (screenSize.height/10))
                .defaultScrollAnchor(.leading, for: .alignment)
            }
                
            Text(item.release)
        }
    }
}

// Preview for both platforms
struct AddMediaPage_Previews: PreviewProvider {
    static var previews: some View {
        AddMediaPage()
            .previewDevice("iPhone 16 Pro")
        AddMediaPage()
            .frame(width: 500, height: 400) // macOS preview
    }
}
