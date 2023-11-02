' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of ListScreen
' Note that we need to import this file in ListScreen.xml using relative path.
sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.top.list = m.rowList
    m.top.width = 1000
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
end sub