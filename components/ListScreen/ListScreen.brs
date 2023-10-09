' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of ListScreen
' Note that we need to import this file in ListScreen.xml using relative path.
sub Init()
    m.list = m.top.FindNode("list")
    'm.rowList.SetFocus(true)
    'm.top.observeField("focusedChild", "focusChanged")
end sub