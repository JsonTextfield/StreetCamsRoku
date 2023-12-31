function GetSectionIndex(character) as string
    letters = CreateObject("roRegex", "[A-ZÀ-Ö]", "i")
    numbers = CreateObject("roRegex", "[0-9]", "i")
    special = CreateObject("roRegex", "[^0-9A-ZÀ-Ö]", "i")

    if special.IsMatch(character) then return "*"
    if numbers.IsMatch(character) then return "#"
    return UCase(character)

end function

function GetSortableName(name, city) as string
    if name = invalid then return ""
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

function GetCameraImage(camera) as string
    if camera.city <> m.global.city.ottawa then return camera.url
    file = "tmp:/" + CreateObject("roDeviceInfo").GetRandomUUID() + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL(camera.url)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    if camera.city = m.global.city.ottawa
        utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    end if
    utrans.GetToFile(file)

    return file
end function

function GetVancouverImages(url) as object
    htmlRequest = CreateObject("roURLTransfer")
    htmlRequest.SetURL(url)
    htmlRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")

    response = htmlRequest.GetToString()

    regex = CreateObject("roRegex", "cameraimages/.*?" + Chr(34), "i")
    data = regex.MatchAll(response)

    result = []
    for each array in data
        uuid = CreateObject("roDeviceInfo").GetRandomUUID()
        cameraId = array[0].Replace(Chr(34), "")
        result.Push("https://trafficcams.vancouver.ca/" + cameraId + "?uuid=" + uuid)
    end for

    return result
end function