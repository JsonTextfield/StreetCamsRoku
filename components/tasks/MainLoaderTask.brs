' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
    m.prefs = CreateObject("roRegistrySection", "prefs")
    m.city = m.prefs.Read("city")
    m.sortMode = m.prefs.Read("sortMode")
    m.viewMode = m.prefs.Read("viewMode")

end sub

sub GetContent()
    GetLocation()
    LoadCameras()
    CreateContentNode()
end sub

sub GetLocation()
    ipAddress = CreateObject("roDeviceInfo").GetExternalIp()

    url = "http://ip-api.com/json/" + ipAddress
    print url

    urlTransfer = CreateObject("roURLTransfer")
    urlTransfer.setUrl(url)
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")

    m.currentLocation = ParseJson(urlTransfer.GetToString())

end sub

sub LoadCameras()
    url = "https://solid-muse-172501.firebaseio.com/cameras.json?orderBy=%22city%22&equalTo=%22" + LCase(m.city) + "%22"
    print url
    if m.city = m.global.city.ottawa
        ' set the cookies
        urlTransfer = CreateObject("roURLTransfer")
        urlTransfer.SetURL("https://traffic.ottawa.ca/map/")
        urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        urlTransfer.EnableCookies()
        urlTransfer.GetToString()
        m.global.addFields({
            "cookies": urlTransfer.GetCookies("traffic.ottawa.ca", "/map")[0],
        })
    end if
    jsonArray = GetJsonArray(url)
    if jsonArray <> invalid
        m.cameras = []
        for each index in jsonArray
            camera = jsonArray[index]
            camera.distance = haversine(camera.location.lat, camera.location.lon, m.currentLocation.lat, m.currentLocation.lon)
            m.cameras.Push(camera)
        end for
        m.global.Update({ cameras: m.cameras }, true)
    end if
end sub

sub CreateContentNode()
    rows = {}
    if m.viewMode = m.global.viewMode.list then rows.children = []
    for each camera in m.cameras
        if m.viewMode = m.global.viewMode.list
            rows.children.Push(GetRowItemData(camera))
        else
            section = ""
            if m.sortMode = m.global.sortMode.name
                name = camera.nameEn
                if name = "" then name = camera.nameFr
                section = GetSectionIndex(GetSortableName(name, m.city).split("")[0])
            else
                section = camera.neighbourhood
            end if

            if not rows.doesExist(section)
                rows[section] = {
                    title: section,
                    children: [],
                }
            end if
            rows[section].children.Push(GetRowItemData(camera))
        end if
    end for
    UpdateContent(rows)
end sub

sub UpdateContent(rows)
    rootChildren = []
    if m.viewMode = m.global.viewMode.list
        if m.sortMode = m.global.sortMode.neighbourhood
            rows.children.SortBy("neighbourhood")
        else if m.sortMode = m.global.sortMode.name
            rows.children.SortBy("sortableName")
        else if m.sortMode = m.global.sortMode.distance
            rows.children.SortBy("distance")
        end if
        rootChildren = rows.children
    else
        for each row in rows.items()
            if m.sortMode = m.global.sortMode.neighbourhood
                row.value.children.SortBy("neighbourhood")
            else
                row.value.children.SortBy("sortableName")
            end if
            rootChildren.Push(row.value)
        end for
    end if

    ' set up a root ContentNode to represent rowList on the GridScreen
    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({ children: rootChildren }, true)
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

    name = camera.nameEn

    if name = "" then name = camera.nameFr

    camera.title = name
    camera.sortableName = GetSortableName(name, m.city)
    camera.city = m.city

    if m.viewMode = m.global.viewMode.list then return camera

    if camera.city = m.global.city.vancouver
        cameraUrls = GetVancouverImages(camera.url)
        camera.hdPosterUrl = cameraUrls[0]
    else
        camera.hdPosterUrl = GetCameraImage(camera)
    end if

    return camera
end function

function degreesToRadians(degrees as float) as float
    return degrees * 3.14159265358979323846 / 180
end function

function haversine(lat1 as float, lon1 as float, lat2 as float, lon2 as float) as float
    ' Radius of the Earth in meters
    earthRadius = 6371000 ' approximately 6371 km
    ' Convert latitude and longitude from degrees to radians
    lat1Rad = degreesToRadians(lat1)
    lon1Rad = degreesToRadians(lon1)
    lat2Rad = degreesToRadians(lat2)
    lon2Rad = degreesToRadians(lon2)

    ' Haversine formula
    dlat = lat2Rad - lat1Rad
    dlon = lon2Rad - lon1Rad

    a = Sin(dlat / 2) ^ 2 + Cos(lat1Rad) * Cos(lat2Rad) * Sin(dlon / 2) ^ 2
    c = 2 * Atn2(Sqr(a), Sqr(1 - a))

    ' Calculate the distance
    distance = earthRadius * c

    return distance
end function

function Atn2(y, x)
    if x < 0 then
        if y >= 0 then
            return Atn(y / x) + 3.141592653589793
        else
            return Atn(y / x) - 3.141592653589793
        end if
    else if y >= 0 then
        return Atn(y / x)
    else
        return Atn(y / x) + 6.283185307179586
    end if
end function