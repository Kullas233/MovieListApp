import SwiftUI
import Foundation
import SDWebImageSwiftUI

struct DetailView: View {
    let movie: Movie // Non-editable title
    
    var body: some View {
        VStack(alignment: .center) {
            Text(movie.title)
                .font(.custom("Helvetica-Bold", size: 35)) // Apply font directly
                .multilineTextAlignment(.center)
        }
        
        Divider()
            .padding()
        
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                // IMDb-like fields
                ScrollView(.vertical) {
                    
                    WebImage(url: URL(string: "https://image.tmdb.org/t/p/original"+String(movie.backdrop))).resizable().frame(width: geometry.size.width-20, height: (geometry.size.width-20)/1.778, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Title: \(movie.title)")
                            .font(.headline)
                        
                        Text("Genre: \(movie.getGenres())")
                            .font(.headline)
                        
                        Text("Release Date: \(movie.release)")
                            .font(.headline)
                        
                        Text("Popularity: \(movie.popularity)")
                            .font(.headline)
                        
                        Text("Description:")
                            .font(.headline)
                            .padding(.bottom, -5)
                        Text("\(movie.overview)")
                        
                        Divider()
                        
                        Text("Vote Average: \(movie.voteAverage)")
                            .font(.headline)
                        
                        Text("Vote Count: \(movie.voteCount)")
                            .font(.headline)
                        
                        if(movie.mediaType == "Movie") {
                            Text("Director: \(movie.director)")
                                .font(.headline)
                        } else if(movie.mediaType == "TV") {
                            Text("Creator: \(movie.director)")
                                .font(.headline)
                        } else {
                            let _ = print("person")
                        }
                        
                        HStack {
                            Text("Actors: ")
                                .font(.headline)
                            ScrollView(.horizontal) {
                                Text("\(movie.varToString(array: movie.actors))")
                                    .font(.headline)
                            }
                        }
                        
                        HStack {
                            Text("Characters: ")
                                .font(.headline)
                            ScrollView(.horizontal) {
                                Text("\(movie.varToString(array: movie.characters))")
                                    .font(.headline)
                            }
                        }
                        
                        if(movie.runtime != "[]") {
                            Text("Runtime: \(movie.runtime)")
                                .font(.headline)
                        }
                        
                        if(movie.seasons != "") {
                            Text("# of Season: \(movie.seasons)")
                                .font(.headline)
                        }
                        
                        if(movie.episodes != "") {
                            Text("# of Episodes: \(movie.episodes)")
                                .font(.headline)
                        }
                        
                        if(movie.budget != "") {
                            Text("Budget: \(movie.budget)")
                                .font(.headline)
                        }
                            
                        if(movie.revenue != "") {
                            Text("Revenue: \(movie.revenue)")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        let providersString = movie.getWhereToWatchDisplayFormat()
//                        let _ = print(providersString)
                        if(providersString != "{}") {
                            var types: [String] {
                                providersString.split(separator: "\n").map(String.init)
                            }
//                            let _ = print(types.count)
                            Text("Watch Providers:")
                                .font(.headline)
                            
                            ForEach(types, id: \.self) { type in
                                var splitTypes: [String] {
                                    type.split(separator: ",,").map(String.init)
                                }
                                HStack {
                                    Text("\(splitTypes[0].uppercased()): ")
                                        .font(.headline)
                                    ScrollView(.horizontal) {
                                        Text("\(splitTypes[1])")
                                            .font(.headline)
                                    }
                                }
                            }
                        } else {
                            Text("Watch Providers: None that I know of ;(")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .frame(alignment: .center)
                }
                .frame(maxWidth: geometry.size.width, alignment: .center)
            }
        }
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
