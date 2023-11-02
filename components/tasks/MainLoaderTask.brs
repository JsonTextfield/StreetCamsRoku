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
    LoadCameras()
    CreateContentNode()
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
            m.cameras.Push(jsonArray[index])
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
        else
            rows.children.SortBy("sortableName")
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

    camera.hdPosterUrl = GetCameraImage(camera)

    return camera
end function
