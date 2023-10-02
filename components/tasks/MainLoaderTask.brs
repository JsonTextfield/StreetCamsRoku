' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub


sub GetContent()

    m.prefs = CreateObject("roRegistrySection", "prefs")

    if not m.prefs.Exists("city") then m.prefs.Write("city", "ottawa")
    if not m.prefs.Exists("viewMode") then m.prefs.Write("viewMode", "list")
    if not m.prefs.Exists("sortMode") then m.prefs.Write("sortMode", "name")

    city = "montreal"

    if city = "ottawa"
        LoadOttawa()
    else if city = "montreal"
        LoadMontreal()
    else if city = "toronto"
        LoadToronto()
    else if city = "calgary"
        LoadCalgary()
    end if

end sub

sub LoadCalgary()
    url = "https://data.calgary.ca/resource/k7p9-kppz.json"
    jsonArray = GetJsonArray(url)

    if jsonArray <> invalid
        rows = {}
        for each cameraJson in jsonArray
            camera = {
                city: "calgary",
                name: cameraJson.camera_location,
                nameFr: "",
                lat: cameraJson.point.coordinates[1],
                lon: cameraJson.point.coordinates[0],
                id: CreateObject("roDateTime").AsSeconds().toStr(),
                url: cameraJson.camera_url.url,
                sortableName: GetSortableName(cameraJson.camera_location),
            }

            letter = GetSectionIndex(GetSortableName(camera.name).split("")[0])
            if not rows.doesExist(letter)
                rows[letter] = {
                    title: letter,
                    children: [],
                }
            end if
            rows[letter].children.Push(GetRowItemData(camera))
        end for

        UpdateContent(rows)
    end if
end sub

sub LoadToronto()
    url = "https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/a3309088-5fd4-4d34-8297-77c8301840ac/resource/4a568300-c7f8-496d-b150-dff6f5dc6d4f/download/Traffic%20Camera%20List.geojson"
    jsonArray = GetJsonArray(url).features

    if jsonArray <> invalid
        rows = {}
        for each cameraJson in jsonArray
            camera = {
                city: "toronto",
                name: cameraJson.properties.MAINROAD + " & " + cameraJson.properties.CROSSROAD,
                nameFr: "",
                lat: cameraJson.geometry.coordinates[0][1],
                lon: cameraJson.geometry.coordinates[0][0],
                id: cameraJson.properties._id,
                url: "http://opendata.toronto.ca/transportation/tmc/rescucameraimages/CameraImages/loc" + cameraJson.properties.REC_ID.toStr() + ".jpg",
                sortableName: GetSortableName(cameraJson.properties.MAINROAD + " & " + cameraJson.properties.CROSSROAD),
            }

            letter = GetSectionIndex(GetSortableName(camera.name).split("")[0])
            if not rows.doesExist(letter)
                rows[letter] = {
                    title: letter,
                    children: [],
                }
            end if
            rows[letter].children.Push(GetRowItemData(camera))
        end for

        UpdateContent(rows)
    end if
end sub

sub LoadMontreal()
    url = "https://ville.montreal.qc.ca/circulation/sites/ville.montreal.qc.ca.circulation/files/cameras-de-circulation.json"
    jsonArray = GetJsonArray(url).features

    if jsonArray <> invalid
        rows = {}
        for each cameraJson in jsonArray
            camera = {
                city: "montreal",
                name: "",
                nameFr: cameraJson.properties.titre,
                lat: cameraJson.geometry.coordinates[1],
                lon: cameraJson.geometry.coordinates[0],
                id: cameraJson.properties["id-camera"],
                url: cameraJson.properties["url-image-en-direct"],
                sortableName: GetSortableNameMontreal(cameraJson.properties.titre),
            }

            letter = GetSectionIndex(GetSortableNameMontreal(camera.nameFr).split("")[0])
            if not rows.doesExist(letter)
                rows[letter] = {
                    title: letter,
                    children: [],
                }
            end if
            rows[letter].children.Push(GetRowItemData(camera))
        end for

        UpdateContent(rows)
    end if
end sub

sub LoadOttawa()
    ' set the cookies
    urlTransfer = CreateObject("roURLTransfer")
    urlTransfer.SetURL("https://traffic.ottawa.ca/map/")
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    urlTransfer.EnableCookies()
    urlTransfer.GetToString()
    m.global.addFields({
        "cookies": urlTransfer.GetCookies("traffic.ottawa.ca", "/map")[0],
    })

    url = "https://traffic.ottawa.ca/map/camera_list"
    jsonArray = GetJsonArray(url)

    if jsonArray <> invalid
        rows = {}
        for each cameraJson in jsonArray
            camera = {
                city: "ottawa",
                name: cameraJson.description,
                nameFr: cameraJson.descriptionFr,
                lat: cameraJson.latitude,
                lon: cameraJson.longitude,
                id: cameraJson.number.toStr(),
                url: "https://traffic.ottawa.ca/map/camera?id=" + cameraJson.number.toStr(),
                sortableName: GetSortableName(cameraJson.description),
            }

            letter = GetSectionIndex(GetSortableName(camera.name).split("")[0])
            if not rows.doesExist(letter)
                rows[letter] = {
                    title: letter,
                    children: [],
                }
            end if
            rows[letter].children.Push(GetRowItemData(camera))
        end for

        UpdateContent(rows)
    end if
end sub

sub UpdateContent(rows)
    rootChildren = []
    for each row in rows.items()
        row.value.children.SortBy("sortableName")
        rootChildren.Push(row.value)
    end for

    ' set up a root ContentNode to represent rowList on the GridScreen
    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        children: rootChildren
    }, true)
    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
    m.top.content = contentNode
end sub

function GetJsonArray(url) as object

    jsonArrayRequest = CreateObject("roURLTransfer")
    jsonArrayRequest.SetURL(url)
    jsonArrayRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")

    ' parse the feed and build a tree of ContentNodes to populate the GridView
    return ParseJson(jsonArrayRequest.GetToString())
end function

function GetRowItemData(camera as object) as object
    viewMode = "gallery"
    if camera.name <> "" name = camera.name else name = camera.nameFr
    if (viewMode = "list")
        return {
            id: camera.id,
            title: name,
            url: camera.url,
            city: camera.city,
            sortableName: camera.sortableName,
        }
    end if

    file = "tmp:/" + CreateObject("roDateTime").AsSeconds().toStr() + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL(camera.url)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    if camera.city = "ottawa"
        utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    end if
    utrans.GetToFile(file)

    return {
        id: camera.id,
        title: name,
        url: camera.url,
        city: camera.city,
        sortableName: camera.sortableName,
        hdPosterUrl: file,
    }
end function

function GetSectionIndex(character) as string
    letters = CreateObject("roRegex", "[A-ZÀ-Ö]", "i")
    numbers = CreateObject("roRegex", "[0-9]", "i")
    special = CreateObject("roRegex", "[^0-9A-ZÀ-Ö]", "i")

    if special.IsMatch(character) then return "*"
    if numbers.IsMatch(character) then return "#"
    return character

end function

function GetSortableNameMontreal(name) as string

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

    sortableName = Mid(name, startIndex + 1)
    regex = CreateObject("roRegex", "[^0-9A-ZÀ-Ö]", "i")

    return regex.ReplaceAll(sortableName, "")
end function

function GetSortableName(name) as string
    regex = CreateObject("roRegex", "[\W_]", "i")
    return regex.ReplaceAll(name, "")
end function