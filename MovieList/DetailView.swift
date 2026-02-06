import SwiftUI
import Foundation
import SDWebImageSwiftUI

// string[x] Substring extension
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

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
                        
                        if(movie.release != "") {
                            let date = movie.release.split(separator: "-")
                            Text("Release Date: \(date[1])/\(date[2])/\(date[0])")
                                .font(.headline)
                        }
                        
                        if(movie.runtime != "[]") {
                            let hours: Int = Int(movie.runtime)!/60
                            let mins: Int = Int(movie.runtime)!%60
                            switch hours {
                                case 0:
                                    Text("Runtime: \(mins) minutes")
                                        .font(.headline)
                                case 1:
                                    Text("Runtime: \(hours) hour \(mins) minutes")
                                        .font(.headline)
                                case 2...:
                                    Text("Runtime: \(hours) hours \(mins) minutes")
                                        .font(.headline)
                                default:
                                    let _ = print("negative runtime?")
                            }
                        }
                        
                        Text("Description:")
                            .font(.headline)
                            .padding(.bottom, -5)
                        Text("\(movie.overview)")
                        
                        Divider()
                        
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
                        
                        Divider()
                        
                        if(movie.seasons != "") {
                            Text("# of Season: \(movie.seasons)")
                                .font(.headline)
                        }
                        
                        if(movie.episodes != "") {
                            Text("# of Episodes: \(movie.episodes)")
                                .font(.headline)
                        }
                        
                        if(movie.budget != "") {
                            Text("Budget: \(makeMoneyString(money: movie.budget))")
                                .font(.headline)
                        }
                            
                        if(movie.revenue != "") {
                            Text("Revenue: \(makeMoneyString(money: movie.revenue))")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        Text("TMDB User Rating: \(Int(Double(movie.voteAverage)!*10))%")
                            .font(.headline)
                        
                        Text("Vote Count: \(movie.voteCount)")
                            .font(.headline)
                        
                        let formattedPopularity: Double = (Double(movie.popularity)! * 100).rounded() / 100
                        let formattedPopularityStr = String(format: "%.2f", formattedPopularity)
                        Text("Popularity: \(formattedPopularityStr)")
                            .font(.headline)
                        
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
    
    private func makeMoneyString(money: Substring) -> String {
        var result = ""
        let moneyStr = String(money)
        var count = 0
        
        for x in (0...moneyStr.count-1).reversed() {
            if count == 3 {
                count = 0
                result = "," + result
            }
            result = moneyStr[x] + result
            count+=1
        }
        
        return "$" + result
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
