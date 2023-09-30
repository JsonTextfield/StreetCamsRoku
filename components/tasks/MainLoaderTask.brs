' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    cameraListRequest = CreateObject("roURLTransfer")
    cameraListRequest.SetURL("https://traffic.ottawa.ca/map/camera_list")
    cameraListRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")
    response = cameraListRequest.GetToString()
    cameras = ParseJson(response)

    urlTransfer = CreateObject("roURLTransfer")
    urlTransfer.SetURL("https://traffic.ottawa.ca/map/")
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    urlTransfer.EnableCookies()
    urlTransfer.GetToString()
    m.global.addFields({ "cookies": urlTransfer.GetCookies("traffic.ottawa.ca", "/map")[0] })
    print m.global.cookies
    ' parse the feed and build a tree of ContentNodes to populate the GridView

    if cameras <> invalid
        rows = {}
        for each camera in cameras
            camera.url = "https://traffic.ottawa.ca/map/camera?id=" + camera.number.toStr()
            letter = camera.description.split("")[0]
            if letter = "("
                letter = camera.description.split("")[1]
            end if
            if not rows.doesExist(letter)
                rows[letter] = {
                    title: letter,
                    children: [],
                }
            end if
            rows[letter].children.Push(GetRowItemData(camera))
        end for

        rootChildren = []
        for each row in rows.items()
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
    end if
end sub

function GetRowItemData(camera as object) as object
    cameraNumber = camera.number.toStr()
    file = "tmp:/camera" + cameraNumber + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL("https://traffic.ottawa.ca/map/camera?id=" + cameraNumber)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    utrans.GetToFile(file)

    return {
        id: camera.number,
        title: camera.description,
        hdPosterUrl: file,
    }
end function
