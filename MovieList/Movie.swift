//
//  Movie.swift
//  TestListIOS
//
//  Created by Dylan Kullas on 1/1/26.
//

strct Movie: Identifiable, Hashable {
    // Properties stored data
    let mediaType: String
    let title: Substring
    let id: Substring
    let overview: Substring
    let genreIds: Substring
    let release: Substring
    let poster: Substring
    let backdrop: Substring
    let popularity: Substring
    
    init() {
        self.mediaType = "Movie"
        self.title = ""
        self.id = ""
        self.overview = ""
        self.genreIds = ""
        self.release = ""
        self.poster = ""
        self.backdrop = ""
        self.popularity = ""
    }
    
    init(mediaType: String, title: Substring, id: Substring, overview: Substring, genreIds: Substring, release: Substring, poster: Substring, backdrop: Substring, popularity: Substring) {
        self.mediaType = mediaType
        self.title = title
        self.id = id
        self.overview = overview
        self.genreIds = genreIds
        self.release = release
        self.poster = poster
        self.backdrop = backdrop
        self.popularity = popularity
    }
    
    func getData() -> String {
        let data = mediaType + "*$*@*" + title + "*$*@*" + id + "*$*@*" + overview + "*$*@*" + genreIds + "*$*@*" + release + "*$*@*" + poster + "*$*@*" + backdrop + "*$*@*" + popularity + "*$*@*\n"
        return String(data)
    }
    
    func getGenres() -> String {
        let genreInts = genreIds.split(separator: ",")
        var Genres: [String : String]
        
        if(mediaType == "Movie")
        {
            Genres = MovieGenres
        }
        else if(mediaType == "TV")
        {
            Genres = TVGenres
        }
        else
        {
            Genres = ["":""]
            print("***NEW TYPE***")
        }
        
    //  Loop through the resulting collection
        var returnString = ""
        var first = true
        for genre in genreInts {
            if(!first)
            {
                returnString = returnString + ", "
            }
            else
            {
                first = false
            }
            returnString = returnString + (Genres[String(genre)] ?? "!!!New Genre!!!")
        }
        return returnString
    }
}
