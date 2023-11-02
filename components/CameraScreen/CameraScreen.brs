sub Init()
    m.timer = m.top.FindNode("timer")
    m.timer.ObserveField("fire", "RunCameraContentTask")
    m.timer.control = "start"
end sub

sub RunCameraContentTask()
    print "RunCameraContentTask"

    m.top.FindNode("backgroundImage").uri = m.top.FindNode("image").uri

    m.contentTask = CreateObject("roSGNode", "CameraLoaderTask")
    m.contentTask.shuffle = m.top.shuffle
    m.contentTask.ObserveField("content", "OnCameraContentLoaded")
    m.contentTask.control = "run"
    m.contentTask.content = m.top.camera
end sub

sub OnCameraContentLoaded()
    m.top.camera = m.contentTask.content
end sub

sub OnContentSet()
    if m.top.camera <> invalid
        m.top.FindNode("image").uri = m.top.camera.hdPosterUrl
        m.top.FindNode("title").text = m.top.camera.title
    end if
end sub

function OnkeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "back"
            m.timer.control = "stop"
        end if
    end if
    return false
end function
