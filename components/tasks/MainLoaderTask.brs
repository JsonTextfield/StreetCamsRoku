' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
    m.prefs = CreateObject("roRegistrySection", "prefs")
    m.city = m.prefs.Read("city")

end sub


sub GetContent()
    LoadCameras(m.city)
    CreateContentNode(m.city)
end sub

sub LoadCameras(city)
    jsonArray = []
    url = "https://solid-muse-172501.firebaseio.com/cameras.json?orderBy=%22city%22&equalTo=%22" + LCase(city) + "%22"
    ? url
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
    end if
    jsonArray = GetJsonArray(url)
    if jsonArray <> invalid
        rows = {}
        m.cameras = []
        for each index in jsonArray
            m.cameras.Push(jsonArray[index])
        end for
    end if
end sub

sub CreateContentNode(city)
    rows = {}
    for each camera in m.cameras
        name = camera.nameEn
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

    name = camera.nameEn
    if name = "" then name = camera.nameFr
    result = {
        id: camera.id,
        title: name,
        url: camera.url,
        city: camera.city,
        neighbourhood: camera.neighbourhood,
        sortableName: GetSortableName(name, camera.city),
    }

    viewMode = m.prefs.Read("viewMode")
    if viewMode = m.global.viewMode.list
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
