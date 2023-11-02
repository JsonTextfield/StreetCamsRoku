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
end sub