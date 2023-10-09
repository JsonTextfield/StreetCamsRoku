' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.rowList.setFocus(true)
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = false
end sub