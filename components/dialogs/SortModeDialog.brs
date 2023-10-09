function init()
    print "Creating RadioButtonActionCards"

    setUpPalette()

    m.buttonArea = m.top.findNode("buttonArea")
    m.top.observeFieldScoped("buttonFocused", "printFocusButton")
    m.top.observeFieldScoped("buttonSelected", "printSelectedButtonAndClose")
    m.top.observeFieldScoped("wasClosed", "wasClosedChanged")

    m.radioButtons = m.top.findNode("radioButtons")
    m.radioButtons.observeField("selectedIndex", "radioButtonSelected")
end function

sub setUpPalette()
    ' set a default palette to access the DialogTextColor to use
    ' for the color of text of the SimpleLabel node's that are
    ' children of the StdDlgActionItem's

    m.top.palette = createObject("roSGNode", "RSGPalette")

    m.top.palette.colors = { DialogBackgroundColor: "0x002040FF",
        DialogItemColor: "0x007FEFFF",
        '                                DialogTextColor: "0x007FEFFF",
        DialogTextColor: "0xC0C0C0FF",
        '                                DialogFocusColor: "0x007FEFFF",
        DialogFocusColor: "0xC0C0C0FF",
        DialogFocusItemColor: "0x003E7EFF",
        DialogSecondaryTextColor: "0x007FEF66",
        DialogSecondaryItemColor: "0x807FFF4D",
        DialogInputFieldColor: "0x807FFF80",
        DialogKeyboardColor: "0x807FFF4D",
    DialogFootprintColor: "0x807FFF4D" }

    dialogTextColor = m.top.palette.colors["DialogTextColor"]

    ' set all SimpleLabel colors to use the palette's dialogTextColor
    m.top.findNode("radioLabel1").color = dialogTextColor
    m.top.findNode("radioLabel2").color = dialogTextColor
    m.top.findNode("radioLabel3").color = dialogTextColor
end sub

sub printFocusButton()
    print "m.buttonArea button ";m.buttonArea.getChild(m.top.buttonFocused).text;" focused"
end sub

sub printSelectedButtonAndClose()
    print "m.buttonArea button ";m.buttonArea.getChild(m.top.buttonSelected).text;" selected"
    m.top.close = true
end sub

sub wasClosedChanged()
    print "ActionCards Closed"
end sub

sub radioButtonSelected()
end sub