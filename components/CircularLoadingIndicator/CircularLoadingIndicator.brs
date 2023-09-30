sub Init()
    m.top.setFocus(true)
    m.loadingPoster = m.top.findNode("progressCircle")
    m.loadingPoster.rotation = 0
    m.timer = createObject("roSGNode", "Timer")
    m.timer.repeat = true
    m.timer.duration = 0.1
    m.timer.observeField("fire", "RotateLoadingImage")
    m.timer.control = "start"
end sub

sub RotateLoadingImage()
    theta = (m.loadingPoster.rotation + 1) mod 360
    m.loadingPoster.rotation = theta
end sub