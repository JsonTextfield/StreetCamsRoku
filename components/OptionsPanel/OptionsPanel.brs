sub Init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = false

    m.labelList = m.top.findNode("labelList")
    m.top.list = m.labelList
end sub