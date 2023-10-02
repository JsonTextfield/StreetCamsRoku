' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    m.prefs = CreateObject("roRegistrySection", "prefs")

    if not m.prefs.Exists("city") then m.prefs.Write("city", "toronto")
    if not m.prefs.Exists("viewMode") then m.prefs.Write("viewMode", "list")
    if not m.prefs.Exists("sortMode") then m.prefs.Write("sortMode", "name")

    m.city = m.prefs.Read("city")

    SetUpGUI()
    InitScreenStack()

    m.GridScreen = CreateObject("roSGNode", "GridScreen")
    ShowScreen(m.GridScreen) ' show GridScreen

    m.top.FindNode("rowList").ObserveField("rowItemSelected", "OnItemClicked")

    RunContentTask() ' retrieving content
end sub

sub SetUpGUI()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "#000000"
    m.top.backgroundUri = ""

    m.overhang = m.top.FindNode("main_overhang")
    m.overhang.title = m.city

    deviceInfo = CreateObject("roDeviceInfo")
    ? deviceInfo.GetDisplaySize()

    m.loadingIndicator = m.top.FindNode("loadingIndicator")
    m.loadingIndicator.poster.loadDisplayMode = "scaleToFit"
    m.loadingIndicator.poster.width = 50
    m.loadingIndicator.poster.height = 50
    m.loadingIndicator.poster.uri = "pkg:/images/loader.png"
    m.loadingIndicator.translation = [deviceInfo.GetDisplaySize().w / 2 - 25, deviceInfo.GetDisplaySize().h / 2 - 25]

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

        if key = "options"
            if m.city = "toronto"
                m.prefs.Write("city", "montreal")
            else if m.city = "montreal"
                m.prefs.Write("city", "calgary")
            else if m.city = "calgary"
                m.prefs.Write("city", "ottawa")
            else
                m.prefs.Write("city", "toronto")
            end if
            m.city = m.prefs.Read("city")
            SetUpGUI()
            RunContentTask()
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function
