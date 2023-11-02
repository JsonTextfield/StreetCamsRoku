' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()

    deviceInfo = CreateObject("roDeviceInfo")

    m.loadingIndicator = m.top.FindNode("loadingIndicator")
    m.loadingIndicator.poster.loadDisplayMode = "scaleToFit"
    m.loadingIndicator.poster.width = 50
    m.loadingIndicator.poster.height = 50
    m.loadingIndicator.poster.uri = "pkg:/images/loader.png"
    m.loadingIndicator.translation = [
        deviceInfo.GetDisplaySize().w / 2 - 25,
        deviceInfo.GetDisplaySize().h / 2 - 25
    ]

    m.timer = m.top.FindNode("timer")
    m.timer.ObserveField("fire", "RunCameraContentTask")
    m.timer.control = "start"
end sub

sub RunCameraContentTask()
    ? "Run Content Task"
    m.top.FindNode("backgroundImage").uri = m.top.FindNode("image").uri
    m.contentTask = CreateObject("roSGNode", "CameraLoaderTask") ' create task for feed retrieving
    if m.top.shuffle
        camera = m.global.cameras[Rnd(m.global.cameras.count()) - 1]
        name = camera.nameEn
        if name = "" then name = camera.nameFr
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            id: camera.id,
            title: name,
            url: camera.url,
            city: camera.city,
            neighbourhood: camera.neighbourhood,
            sortableName: camera.sortableName,
            hdPosterUrl: GetCameraImage(camera)
        }, true)
        m.contentTask.content = contentNode
    else
        m.contentTask.content = m.top.camera
    end if
    ' observe content so we can know when feed content will be parsed
    m.contentTask.ObserveField("content", "OnCameraContentLoaded")
    m.contentTask.control = "run" ' GetContent(see MainLoaderTask.brs) method is executed
end sub

sub OnCameraContentLoaded() ' invoked when content is ready to be used
    m.top.camera = m.contentTask.content ' populate GridScreen with content
    OnContentSet()
end sub

sub OnContentSet() ' invoked when item metadata retrieved
    if m.top.camera <> invalid
        m.top.FindNode("image").uri = m.top.camera.hdPosterUrl
        m.top.FindNode("title").text = m.top.camera.title
    end if
end sub

function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    if press
        ' handle "back" key press
        if key = "back"
            m.timer.control = "stop"
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function
