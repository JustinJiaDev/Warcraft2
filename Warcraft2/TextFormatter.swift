import Foundation

class textFormatter {
    static func integerToPrettyString(val: Int) -> String {
        var simpleString = String(val)
        var returnString = ""
        var charUntilComma = simpleString.characters.count % 3
        var charactersLeft = simpleString.characters.count

        if charUntilComma == 0 {
            charUntilComma = 3
        }

        for char in simpleString.characters {
            returnString.append(char)
            charUntilComma -= 1
            charactersLeft -= 1
            if charUntilComma == 0 {
                charUntilComma = 3
                if charactersLeft != 0 {
                    returnString.append(",")
                }
            }
        }

        return returnString
    }
}
