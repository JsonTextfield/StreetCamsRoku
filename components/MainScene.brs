' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()

    m.global.addFields({
        city: {
            OTTAWA: "Ottawa",
            MONTREAL: "Montreal",
            TORONTO: "Toronto",
            CALGARY: "Calgary",
            VANCOUVER: "Vancouver",
            SURREY: "Surrey",
            ONTARIO: "Ontario",
            ALBERTA: "Alberta"
        },
        viewMode: {
            LIST: "List",
            'MAP: "Map",
            GALLERY: "Gallery"
        },
        sortMode: {
            NAME: "Name",
            DISTANCE: "Distance",
            NEIGHBOURHOOD: "Neighbourhood"
        }
    })

    m.prefs = CreateObject("roRegistrySection", "prefs")

    m.city = m.prefs.Read("city")
    m.viewMode = m.prefs.Read("viewMode")
    m.sortMode = m.prefs.Read("sortMode")

    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "#000000"
    m.top.backgroundUri = ""

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

    InitScreenStack()


    m.optionsPanel = m.top.panelSet.createChild("OptionsPanel")
    'm.optionsPanel.setFocus(true)

    if m.viewMode = m.global.viewMode.GALLERY
        m.GridScreen = m.top.panelSet.createChild("GridScreen")
    else
        m.GridScreen = m.top.panelSet.createChild("GridScreen")
    end if
    'ShowScreen(m.GridScreen)

    m.rowList = m.top.FindNode("rowList")
    m.rowList.ObserveField("rowItemSelected", "OnItemClicked")

    'm.GridScreen.observeField("focusedChild", "focusChanged")

    m.labelList = m.top.FindNode("labelList")
    m.labelList.ObserveField("itemSelected", "OnItemSelected")

    m.top.overhang.title = m.city
    m.top.overhang.logoUri = "pkg:/images/logo_small.png"

    RunContentTask() ' retrieving content

end sub


sub OnItemSelected()
    if m.labelList.itemSelected = 0
        m.viewModeDialog = CreateObject("roSGNode", "RadioDialog")
        m.viewModeDialog.selectedValue = m.viewMode
        m.viewModeDialog.values = m.global.viewMode
        m.viewModeDialog.title = "View"
        m.viewModeDialog.ObserveField("selectedValue", "ViewModeChanged")
        m.top.dialog = m.viewModeDialog
    else if m.labelList.itemSelected = 1
        m.cityDialog = CreateObject("roSGNode", "RadioDialog")
        m.cityDialog.selectedValue = m.city
        m.cityDialog.values = m.global.city
        m.cityDialog.title = "City"
        m.cityDialog.ObserveField("selectedValue", "CityChanged")
        m.top.dialog = m.cityDialog
    else if m.labelList.itemSelected = 2
        m.sortModeDialog = CreateObject("roSGNode", "RadioDialog")
        m.sortModeDialog.selectedValue = m.sortMode
        m.sortModeDialog.values = m.global.sortMode
        m.sortModeDialog.title = "Sort"
        m.sortModeDialog.ObserveField("selectedValue", "SortModeChanged")
        m.top.dialog = m.sortModeDialog
    else if m.labelList.itemSelected = 3
    else if m.labelList.itemSelected = 4
    else if m.labelList.itemSelected = 5
        m.top.dialog = CreateObject("roSGNode", "AboutDialog")
    end if
end sub

sub CityChanged()
    m.city = m.cityDialog.selectedValue
    m.prefs.Write("city", m.city)
    m.top.overhang.title = m.city
    RunContentTask()
end sub

sub ViewModeChanged()
    m.viewMode = m.viewModeDialog.selectedValue
    m.prefs.Write("viewMode", m.viewMode)
    RunContentTask()
end sub

sub SortModeChanged()
    m.sortMode = m.sortModeDialog.selectedValue
    m.prefs.Write("sortMode", m.sortMode)
    RunContentTask()
end sub

sub focusChanged()
    if m.GridScreen.isInFocusChain()
        if not m.rowList.hasFocus()
            m.rowList.setFocus(true)
        end if
    else if m.optionsPanel.isInFocusChain()
        m.labelList.setFocus(true)
    end if
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
            if numberOfScreens > 0
                CloseScreen(invalid)
                result = true
            end if
        end if

        if key = "options"
            'Show options dialog
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function
