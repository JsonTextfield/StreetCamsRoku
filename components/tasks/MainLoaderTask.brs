' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub


sub GetContent()

    m.prefs = CreateObject("roRegistrySection", "prefs")

    LoadCity(m.prefs.Read("city"))

end sub

function CreateCamera(cameraJson, city) as object
    if city = m.global.city.calgary
        return {
            city: city,
            name: cameraJson.camera_location,
            nameFr: "",
            lat: cameraJson.point.coordinates[1],
            lon: cameraJson.point.coordinates[0],
            id: CreateObject("roDateTime").AsSeconds().toStr(),
            url: cameraJson.camera_url.url,
        }
    else if city = m.global.city.toronto
        return {
            city: city,
            name: ToTitleCase(cameraJson.properties.MAINROAD + " & " + cameraJson.properties.CROSSROAD),
            nameFr: "",
            lat: cameraJson.geometry.coordinates[0][1],
            lon: cameraJson.geometry.coordinates[0][0],
            id: cameraJson.properties._id,
            url: cameraJson.properties.IMAGEURL,
        }
    else if city = m.global.city.montreal
        return {
            city: city,
            name: "",
            nameFr: cameraJson.properties.titre,
            lat: cameraJson.geometry.coordinates[1],
            lon: cameraJson.geometry.coordinates[0],
            id: cameraJson.properties["id-camera"],
            url: cameraJson.properties["url-image-en-direct"],
        }
    else if city = m.global.city.ottawa
        return {
            city: city,
            name: cameraJson.description,
            nameFr: cameraJson.descriptionFr,
            lat: cameraJson.latitude,
            lon: cameraJson.longitude,
            id: cameraJson.number.toStr(),
            url: "https://traffic.ottawa.ca/map/camera?id=" + cameraJson.number.toStr(),
        }
    end if
end function

sub LoadCity(city)
    jsonArray = []
    if city = m.global.city.ottawa
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

    else if city = m.global.city.montreal
        url = "https://ville.montreal.qc.ca/circulation/sites/ville.montreal.qc.ca.circulation/files/cameras-de-circulation.json"
        jsonArray = GetJsonArray(url).features

    else if city = m.global.city.toronto
        url = "https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/a3309088-5fd4-4d34-8297-77c8301840ac/resource/4a568300-c7f8-496d-b150-dff6f5dc6d4f/download/Traffic%20Camera%20List.geojson"
        jsonArray = GetJsonArray(url).features

    else if city = m.global.city.calgary
        url = "https://data.calgary.ca/resource/k7p9-kppz.json"
        jsonArray = GetJsonArray(url)
    end if

    if jsonArray <> invalid
        rows = {}
        for each cameraJson in jsonArray
            camera = CreateCamera(cameraJson, city)

            name = camera.name
            if name = "" then name = camera.nameFr

            letter = GetSectionIndex(GetSortableName(name, city).split("")[0])

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
        'row.value.children.SortBy("sortableName")
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

    if camera.name <> "" name = camera.name else name = camera.nameFr

    result = {
        id: camera.id,
        title: name,
        url: camera.url,
        city: camera.city,
        sortableName: GetSortableName(name, camera.city),
    }

    viewMode = m.global.viewMode.gallery
    if (viewMode = m.global.viewMode.list)
        return result
    end if

    result.AddReplace("hdPosterUrl", GetCameraImage(camera))
    return result
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
