//
//  ContentView.swift
//  Bible Verse Picker
//
//  Created by Vernon AME on 9/8/24.
//

import SwiftUI


struct BibleVersion: Hashable {
    var name: String
    var id: String
}

struct BibleVersePicker: View {
    @State var version = "en-kjv"
    @State var book = ""
    @State var chapter = ""
    @State var verse = ""
    
    @State var verseParserVerse = ""
    
    @State var verseContent = [String]()
    //@State var verseContent: [String]
    
    @Binding var connectedVerseContent: String
    
    @State var selectedVersion = BibleVersion(name: "New International Version", id: "NIV")
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                    .frame(height: 25)
                
                Menu {
                    VStack {
                        ForEach(bibleVersions, id:\.self) { bibleVersion in
                            Button(action: {
                                selectedVersion = bibleVersion
                            }, label: {
                                Text("\(bibleVersion.id) - \(bibleVersion.name)")
                            })
                        }
                    }
                } label: {
                    Text("\(selectedVersion.id) - \(selectedVersion.name)")
                }

                
                TextField("Bible Verse", text: $verseParserVerse)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                    .onAppear() {
                        let bookParser = verseParserVerse.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                        
                        var verseParser: [Substring] = []
                        
                        if bookParser.count > 1 {
                            verseParser = bookParser[1].split(separator: ":")
                            
                            verseParser = verseParser.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)[...] }
                        }

                        if bookParser.count > 0 {
                            book = String(bookParser[0])
                        }
                        if verseParser.count > 0 {
                            chapter = String(verseParser[0])
                        }
                        if verseParser.count > 1 {
                            verse = String(verseParser[1])
                        }
                    }
                    .onChange(of: verseParserVerse, perform: { value in
                        var count = verseParserVerse.components(separatedBy: " ").count
                        var bookParsing = ""
                        if count > 1{
                            bookParsing = "\(verseParserVerse.first!)\(verseParserVerse.dropFirst(2))"
                        }
                        else {
                            bookParsing = verseParserVerse
                        }
                        
                        let bookParser = bookParsing.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                        
                        var verseParser: [Substring] = []
                        
                        if bookParser.count > 1 {
                            verseParser = bookParser[1].split(separator: ":")
                            
                            verseParser = verseParser.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)[...] }
                        }
                        
                        book = ""
                        chapter = ""
                        verse = ""

                        if bookParser.count > 0 {
                            if count > 1 {
                                book = String(bookParser[0])
                                book.insert(" ", at: bookParser[0].index(bookParser[0].startIndex, offsetBy: 1))
                            }
                            else {
                                book = String(bookParser[0])
                            }
                        }
                        if verseParser.count > 0 {
                            chapter = String(verseParser[0])
                        }
                        if verseParser.count > 1 {
                            verse = String(verseParser[1])
                        }
                        
                        fetchBibleContent2()
                    })
                Text("\(book) \(chapter)\(!verse.isEmpty ? ":": "")\(verse)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Red Color"))
                
                
                
                Button(action: {
                    for oneVerse in 0..<verseContent.count {
                        verseContent[oneVerse] = "(\(oneVerse + 1)) \(verseContent[oneVerse])"
                    }
                    connectedVerseContent = verseContent.joined(separator: "\n")
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color("Red Color"))
                        
                        HStack {
                            Text("Add Verses")
                            
                            Spacer()
                                .frame(width: 17)
                            
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                        }.foregroundStyle(Color(.white))
                            .padding(17)
                        
                    }.frame(width: 175, height: 50)
                        .cornerRadius(30)
                        .hoverEffect(.lift)
                })
                
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(verseContent, id: \.self) { verse in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Red Color"), lineWidth: 2)
                            
                            Text(verse)
                                .padding(5)
                        }
                    }
                }.padding(5)
            }
        }
    }
    
    func fetchBibleContent2() {
        verseContent.removeAll()
        fetchVerses2(version: selectedVersion.id, book: book, chapter: chapter) { result in
            switch result {
            case .success(let verses):
                var verseRange = verse.replacingOccurrences(of: " ", with: "").split(separator: "-")
                for oneVerse in verses {
                    print("Verse \(oneVerse.verseId): \(oneVerse.verse)")
                    if verseRange.count >= 2 {
                        if oneVerse.verseId >= Int(verseRange[0]) ?? 0 && oneVerse.verseId <= Int(verseRange[1]) ?? 200 {
                            verseContent.append(oneVerse.verse)
                        }
                    }
                    else if verseRange.count == 1 {
                        if oneVerse.verseId == Int(verse) {
                            verseContent.append(oneVerse.verse)
                        }
                    }
                    else {
                        verseContent.append(oneVerse.verse)
                    }
                }
            case .failure(let error):
                print("Error fetching verses: \(error.localizedDescription)")
            }
        }
    }
    
    /*func fetchBibleContent() {
        verseContent.removeAll()
        if verse.isEmpty || verse.contains("-") {
            fetchChapters(version: version.lowercased(), book: book.lowercased(), chapter: chapter) { result in
                switch result {
                case .success(let chapterVerses):
                    print("Fetched chapter verses: \(chapterVerses)")
                    if verse.contains("-") {
                        //var tempVerseContent = chapterVerses.map { $0.text }
                        var tempVerseContent = chapterVerses.map { $0 }

                        let verseParts = verse.split(separator: "-")
                        if verseParts.count == 2, let start = Int(verseParts[0]), let end = Int(verseParts[1]) {
                            // Ensure the range is within bounds
                            let startVerse = max(0, start - 1) // Assuming verses are 1-indexed
                            let endVerse = min(tempVerseContent.count, end) - 1
                            
                            if startVerse <= endVerse {
                                //verseContent = Array(tempVerseContent[startVerse...endVerse])
                                for thing in Array(tempVerseContent[startVerse...endVerse]) {
                                    verseContent.append("(\(thing.verse)) \(thing.text)")
                                }
                            } else {
                                // Handle the case where startVerse is greater than endVerse
                                verseContent = []
                            }
                        } else {
                            // Handle the case where the input string is not in the expected format
                            verseContent = []
                        }

                    }
                    else {
                        verseContent = chapterVerses.map { $0.text }
                    }
                case .failure(let error):
                    print("Error fetching chapters: \(error.localizedDescription)")
                }
            }
        } else {
            fetchVerse(version: version.lowercased(), book: book.lowercased(), chapter: chapter, verse: verse) { result in
                switch result {
                case .success(let verseResponse):
                    print("Fetched verse: \(verseResponse)")
                    verseContent.append(verseResponse.text)
                case .failure(let error):
                    print("Error fetching verse: \(error.localizedDescription)")
                }
            }
        }
    }*/
}

func fetchVerse(version: String, book: String, chapter: String, verse: String, completion: @escaping (Result<Verse, Error>) -> Void) {
    let urlString = "https://cdn.jsdelivr.net/gh/wldeh/bible-api/bibles/\(version)/books/\(book)/chapters/\(chapter)/verses/\(verse).json"
    print("Fetching verse from URL: \(urlString)")
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    let request = URLRequest(url: url)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data returned")
            let error = NSError(domain: "dataNilError", code: -1001, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        print("Data received: \(String(describing: String(data: data, encoding: .utf8)))")
        
        do {
            let decoder = JSONDecoder()
            let verseResponse = try decoder.decode(Verse.self, from: data)
            completion(.success(verseResponse))
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

func fetchChapters(version: String, book: String, chapter: String, completion: @escaping (Result<[ChapterVerse], Error>) -> Void) {
    let urlString = "https://cdn.jsdelivr.net/gh/wldeh/bible-api/bibles/\(version)/books/\(book)/chapters/\(chapter).json"
    print("Fetching chapters from URL: \(urlString)")
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    let request = URLRequest(url: url)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No data returned")
            let error = NSError(domain: "dataNilError", code: -1001, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        print("Data received: \(String(describing: String(data: data, encoding: .utf8)))")
        
        do {
            let decoder = JSONDecoder()
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: data)
            completion(.success(chapterResponse.data))
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

struct Verse: Codable {
    let verse: String
    let text: String
}

struct ChapterVerse: Codable {
    let book: String
    let chapter: String
    let verse: String
    let text: String
}

struct ChapterResponse: Codable {
    let data: [ChapterVerse]
}


struct VerseResponse: Codable {
    let id: Int
    let book: Book
    let chapterId: Int
    let verseId: Int
    let verse: String
}

struct Book: Codable {
    let id: Int
    let name: String
    let testament: String
}

func fetchVerses2(version: String, book: String, chapter: String, completion: @escaping (Result<[VerseResponse], Error>) -> Void) {
    let urlString = "https://bible-go-api.rkeplin.com/v1/books/\(String(booksOfTheBible[book] ?? 1))/chapters/\(chapter)?translation=\(version)" // Replace with your actual API URL
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let verses = try decoder.decode([VerseResponse].self, from: data)
            completion(.success(verses))
        } catch let decodingError {
            completion(.failure(decodingError))
        }
    }
    
    task.resume()
}



let bibleVersions = [
    BibleVersion(name: "New International Version", id: "NIV"),
    BibleVersion(name: "King James Version", id: "KJV"),
    BibleVersion(name: "New Living Translation", id: "NLT"),
    BibleVersion(name: "American Standard Version", id: "ASV"),
    BibleVersion(name: "English Standard Version", id: "ESV"),
]



let booksOfTheBible: [String: Int] = [
    "Genesis": 1,
    "Exodus": 2,
    "Leviticus": 3,
    "Numbers": 4,
    "Deuteronomy": 5,
    "Joshua": 6,
    "Judges": 7,
    "Ruth": 8,
    "1 Samuel": 9,
    "2 Samuel": 10,
    "1 Kings": 11,
    "2 Kings": 12,
    "1 Chronicles": 13,
    "2 Chronicles": 14,
    "Ezra": 15,
    "Nehemiah": 16,
    "Esther": 17,
    "Job": 18,
    "Psalm": 19,
    "Proverbs": 20,
    "Ecclesiastes": 21,
    "Song of Solomon": 22,
    "Isaiah": 23,
    "Jeremiah": 24,
    "Lamentations": 25,
    "Ezekiel": 26,
    "Daniel": 27,
    "Hosea": 28,
    "Joel": 29,
    "Amos": 30,
    "Obadiah": 31,
    "Jonah": 32,
    "Micah": 33,
    "Nahum": 34,
    "Habakkuk": 35,
    "Zephaniah": 36,
    "Haggai": 37,
    "Zechariah": 38,
    "Malachi": 39,
    "Matthew": 40,
    "Mark": 41,
    "Luke": 42,
    "John": 43,
    "Acts": 44,
    "Romans": 45,
    "1 Corinthians": 46,
    "2 Corinthians": 47,
    "Galatians": 48,
    "Ephesians": 49,
    "Philippians": 50,
    "Colossians": 51,
    "1 Thessalonians": 52,
    "2 Thessalonians": 53,
    "1 Timothy": 54,
    "2 Timothy": 55,
    "Titus": 56,
    "Philemon": 57,
    "Hebrews": 58,
    "James": 59,
    "1 Peter": 60,
    "2 Peter": 61,
    "1 John": 62,
    "2 John": 63,
    "3 John": 64,
    "Jude": 65,
    "Revelation": 66
]

