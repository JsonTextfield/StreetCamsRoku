function GetSectionIndex(character) as string
    letters = CreateObject("roRegex", "[A-ZÀ-Ö]", "i")
    numbers = CreateObject("roRegex", "[0-9]", "i")
    special = CreateObject("roRegex", "[^0-9A-ZÀ-Ö]", "i")

    if special.IsMatch(character) then return "*"
    if numbers.IsMatch(character) then return "#"
    return character

end function

function GetSortableName(name, city) as string
    if city = m.global.city.montreal
        startIndex = 0

        if name.StartsWith("Avenue ")
            startIndex = "Avenue ".Len()
        else if name.StartsWith("Boulevard ")
            startIndex = "Boulevard ".Len()
        else if name.StartsWith("Chemin ")
            startIndex = "Chemin ".Len()
        else if name.StartsWith("Rue ")
            startIndex = "Rue ".Len()
        end if

        name = Mid(name, startIndex + 1)
    end if

    regex = CreateObject("roRegex", "[^0-9A-ZÀ-Ö]", "i")

    return regex.ReplaceAll(name, "")
end function

' Function to convert a string to title case
function ToTitleCase(inputString as string) as string
    ' Split the input string into words
    words = inputString.Tokenize(" ")

    ' Initialize an empty result string
    result = ""

    ' Loop through the words and capitalize the first letter of each word
    for each word in words
        if word <> ""
            ' Capitalize the first letter and add the word to the result
            result = result + UCase(Left(word, 1)) + LCase(Mid(word, 2)) + " "
        end if
    end for

    ' Remove trailing space and return the result
    return result.Trim()
end function