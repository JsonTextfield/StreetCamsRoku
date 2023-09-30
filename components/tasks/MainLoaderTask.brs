' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    ' request the content feed from the API
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://traffic.ottawa.ca/map/camera_list")
    rsp = xfer.GetToString()

    urlTransfer = CreateObject("roURLTransfer")
    urlTransfer.SetURL("https://traffic.ottawa.ca/map/")
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    urlTransfer.EnableCookies()
    urlTransfer.GetToString()
    m.global.addFields({ "cookies": urlTransfer.GetCookies("traffic.ottawa.ca", "/map")[0] })
    print m.global.cookies
    rootChildren = []
    rows = {}
    ' parse the feed and build a tree of ContentNodes to populate the GridView
    cameras = ParseJson(rsp)
    if cameras <> invalid
        for each camera in cameras
            letter = camera.description.split("")[0]
            if letter = "("
                letter = camera.description.split("")[1]
            end if
            if not rows.doesExist(letter)
                row = {}
                row.title = letter
                row.children = []
                rows[letter] = row
            end if
            rows[letter].children.Push(GetItemData(camera))
        end for
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

sub GetImage(camera as object)
    url = "https://traffic.ottawa.ca/map/camera?id=" + camera.number.toStr()
    result = ""
    timeout = 10000
    file = "tmp:/camera" + camera.number.toStr() + RND(55).toStr() + ".jpg"
    xfer = CreateObject("roUrlTransfer")
    m.port = CreateObject("roMessagePort")
    print type(xfer)
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    xfer.SetURL(url)
    xfer.SetMessagePort(m.port)
    if xfer.AsyncGetToFile(file)
        event = wait(timeout, m.port)
        if type(event) = "roUrlEvent"
            result = event.GetString()
            m.top.camera.hdPosterUrl = file
        else if event = invalid
            xfer.AsyncCancel()
        else
            print "roUrlTransfer::AsyncGetToString(): unknown event"
        end if
    end if
end sub

function GetItemData(camera as object) as object
    item = {}
    cameraNumber = camera.number.toStr()
    file = "tmp:/camera" + cameraNumber + ".jpg"
    utrans = CreateObject("roURLTransfer")
    utrans.SetURL("https://traffic.ottawa.ca/map/camera?id=" + cameraNumber)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    utrans.GetToFile(file)
    item.hdPosterUrl = file
    item.id = camera.number
    item.title = camera.description
    return item
end function
