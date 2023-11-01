' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.top.list = m.rowList
    m.top.width = 1100
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
end sub