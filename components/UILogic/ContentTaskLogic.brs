' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

sub RunContentTask()
    m.loadingIndicator.visible = true ' show loading indicator while content is loading
    m.rowList.visible = false
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run" ' GetContent(see MainLoaderTask.brs) method is executed
end sub

sub OnMainContentLoaded() ' invoked when content is ready to be used
    m.rowList.content = m.contentTask.content ' populate GridScreen with content
    m.loadingIndicator.visible = false ' hide loading indicator because content was retrieved
    m.rowList.visible = true
    'm.rowList.SetFocus(true)
    'm.top.FindNode("labelList").SetFocus(true)
end sub