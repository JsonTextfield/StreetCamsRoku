sub Init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = false
    m.top.list = m.top.findNode("labelList")
end sub