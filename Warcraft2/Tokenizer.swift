import Foundation

class Tokenizer {
    private var dataSource: DataSource
    private var delimiters: String

    init(dataSource: DataSource, delimiters: String = "") {
        self.dataSource = dataSource
        self.delimiters = delimiters.characters.count > 0 ? delimiters : " \t\r\n"
    }

    func readToken() -> String? {
        var token = ""
        var data = dataSource.readData(ofLength: 1)
        while data.count > 0 {
            let character = String(UnicodeScalar(data[0]))
            guard !delimiters.contains(character) else {
                break
            }
            token.append(character)
            data = dataSource.readData(ofLength: 1)
        }
        return token.characters.count > 0 ? token : nil
    }

    static func tokenize(data: String, delimiters: String = "") -> [String] {
        let delimiters = delimiters.characters.count > 0 ? delimiters : " \t\r\n"
        var tokens: [String] = []
        var currentToken = ""
        for character in data.characters {
            if !delimiters.contains(String(character)) {
                currentToken += String(character)
            } else if currentToken.characters.count > 0 {
                tokens.append(currentToken)
                currentToken.removeAll()
            }
        }
        if currentToken.characters.count > 0 {
            tokens.append(currentToken)
        }
        return tokens
    }
}
