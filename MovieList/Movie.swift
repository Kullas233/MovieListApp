//
//  Movie.swift
//  TestListIOS
//
//  Created by Dylan Kullas on 1/1/26.
//

import Foundation

struct Movie: Identifiable, Hashable {
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
    let voteAverage: Substring
    let voteCount: Substring
    
    
    var director: Substring       // creator
    var actors: [Substring]
    var characters: [Substring]
    var runtime: Substring
    var seasons: Substring
    var episodes: Substring
    var whereToWatch: [Substring: [Substring]]
    var budget: Substring
    var revenue: Substring
    
    
    
    init() {
        //First search
        self.mediaType = "Movie"
        self.title = ""
        self.id = ""
        self.overview = ""
        self.genreIds = ""
        self.release = ""
        self.poster = ""
        self.backdrop = ""
        self.popularity = ""
        self.voteAverage = ""
        self.voteCount = ""
        
        self.director = ""
        self.actors = []
        self.characters = []
        self.runtime = ""
        self.seasons = ""
        self.episodes = ""
        self.whereToWatch = [Substring: [Substring]]()
        self.budget = ""
        self.revenue = ""
    }
    
    //new half
    init(mediaType: String, title: Substring, id: Substring, overview: Substring, genreIds: Substring, release: Substring, poster: Substring, backdrop: Substring, popularity: Substring, voteAverage: Substring, voteCount: Substring) {
        //First search
        self.mediaType = mediaType
        self.title = title
        self.id = id
        self.overview = overview
        self.genreIds = genreIds
        self.release = release
        self.poster = poster
        self.backdrop = backdrop
        self.popularity = popularity
        
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        
        self.director = ""
        self.actors = []
        self.characters = []
        self.runtime = ""
        self.seasons = ""
        self.episodes = ""
        self.whereToWatch = [Substring: [Substring]]()
        self.budget = ""
        self.revenue = ""
    }
    
    //new all
    init(mediaType: String, title: Substring, id: Substring, overview: Substring, genreIds: Substring, release: Substring, poster: Substring, backdrop: Substring, popularity: Substring, voteAverage: Substring, voteCount: Substring, director: Substring, actors: [Substring], characters: [Substring], runtime: Substring, seasons: Substring, episodes: Substring, whereToWatch: [Substring: [Substring]], budget: Substring, revenue: Substring) {
        //First search
        self.mediaType = mediaType
        self.title = title
        self.id = id
        self.overview = overview
        self.genreIds = genreIds
        self.release = release
        self.poster = poster
        self.backdrop = backdrop
        self.popularity = popularity
        
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        
        self.director = director
        self.actors = actors
        self.characters = characters
        self.runtime = runtime
        self.seasons = seasons
        self.episodes = episodes
        self.whereToWatch = whereToWatch
        self.budget = budget
        self.revenue = revenue
    }
    
    func getData() -> String {
        var data = ""
        data += mediaType + "*$*@*" + title + "*$*@*" + id + "*$*@*" + overview + "*$*@*" + genreIds + "*$*@*" + release + "*$*@*" + poster + "*$*@*" + backdrop + "*$*@*" + popularity + "*$*@*"
        data += voteAverage + "*$*@*" + voteCount + "*$*@*" + director + "*$*@*" + varToString(array: actors) + "*$*@*" + varToString(array: characters) + "*$*@*"
        data += runtime + "*$*@*" + seasons + "*$*@*" + episodes + "*$*@*" + varToString(dictionary: whereToWatch) + "*$*@*" + budget + "*$*@*" + revenue + "*$*@*\n"
        return String(data)
    }
    
    func varToString(array: [Substring]) -> Substring {
        return Substring(array.joined(separator: ", "))
    }
    func varToString(dictionary: [Substring: [Substring]]) -> Substring {
        var result: Substring = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            let string = String(data: data, encoding: .utf8)!
            result = Substring(string)
        } catch {
            print("FACK")
        }
        return result
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
    
    func getWhereToWatchDisplayFormat() -> String {
        var result = ""
        for (title, array) in whereToWatch {
            result += title + ",,"
            for provider in array {
                result += provider + ", "
            }

            result = String(result[..<result.index(result.endIndex, offsetBy: -2)])
            result += "\n"
        }
        return result
    }
}

func arrayFromString(string: String) -> [Substring] {
    let array: [Substring] = string.split(separator: ", ")
    return array
}

func dictFromString(string: String) -> [Substring: [Substring]] {
    var result = [Substring: [Substring]]()
    do {
        let data = Data(string.utf8)
        result = try JSONSerialization.jsonObject(with: data) as! [Substring: [Substring]]
    } catch {
        print("FACK")
    }
    return result
}
