' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "0x000000"
    m.top.backgroundUri = ""
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m
    InitScreenStack()
    m.GridScreen = CreateObject("roSGNode", "GridScreen")
    ShowScreen(m.GridScreen) ' show GridScreen
    m.top.FindNode("rowList").ObserveField("rowItemSelected", "OnItemClicked")
    RunContentTask() ' retrieving content
end sub

sub OnItemClicked() ' invoked when another item is focused
    focusedIndex = m.top.FindNode("rowList").rowItemFocused ' get position of focused item
    row = m.top.FindNode("rowList").content.GetChild(focusedIndex[0]) ' get all items of row
    item = row.GetChild(focusedIndex[1]) ' get focused item
    m.CameraScreen = CreateObject("roSGNode", "CameraScreen")
    m.CameraScreen.camera = item
    ShowScreen(m.CameraScreen) ' show GridScreen
    ' update title label with title of focused item
end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    if press
        ' handle "back" key press
        if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' close top screen if there are two or more screens in the screen stack
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function