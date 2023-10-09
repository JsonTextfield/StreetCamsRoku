' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()
    m.testtimer = m.top.FindNode("testTimer")
    m.testtimer.repeat = true
    m.testtimer.duration = 4
    m.testtimer.ObserveField("fire", "RunCameraContentTask")
    m.testtimer.control = "start"
end sub

sub RunCameraContentTask()
    m.top.FindNode("backgroundImage").uri = m.top.FindNode("image").uri
    m.contentTask = CreateObject("roSGNode", "CameraLoaderTask") ' create task for feed retrieving
    m.contentTask.content = m.top.camera
    ' observe content so we can know when feed content will be parsed
    m.contentTask.ObserveField("content", "OnCameraContentLoaded")
    m.contentTask.control = "run" ' GetContent(see MainLoaderTask.brs) method is executed
end sub

sub OnCameraContentLoaded() ' invoked when content is ready to be used
    m.top.camera = m.contentTask.content ' populate GridScreen with content
    OnContentSet()
end sub

sub OnContentSet() ' invoked when item metadata retrieved
    camera = m.top.camera
    ' set poster uri if content is valid
    if camera <> invalid
        m.top.FindNode("image").uri = camera.hdPosterUrl
        m.top.FindNode("title").text = camera.title
    end if
end sub

function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    if press
        ' handle "back" key press
        if key = "back"
            m.testtimer.control = "stop"
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function
