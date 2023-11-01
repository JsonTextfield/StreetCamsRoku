function init()
    setUpPalette()

    m.title = m.top.findNode("dialogTitle")
    m.title.primaryTitle = m.top.title

    m.buttonArea = m.top.findNode("buttonArea")

    m.top.observeFieldScoped("buttonSelected", "printSelectedButtonAndClose")
    m.top.observeField("values", "updateValues")

    m.radioButtons = m.top.findNode("radioButtons")

end function

sub updateValues()
    index = 0
    m.data = {}
    for each key in m.top.values
        m.data[key] = index
        radioButton = CreateObject("roSGNode", "StdDlgActionCardItem")
        radioButton.iconType = "radioButton"
        title = CreateObject("roSGNode", "SimpleLabel")
        title.text = m.top.values[key]
        radioButton.appendChild(title)
        m.radioButtons.appendChild(radioButton)
        index++
    end for
end sub

sub setUpPalette()
    ' set a default palette to access the DialogTextColor to use
    ' for the color of text of the SimpleLabel node's that are
    ' children of the StdDlgActionItem's

    m.top.palette = createObject("roSGNode", "RSGPalette")

    m.top.palette.colors = {
        DialogBackgroundColor: "0x002040FF",
        DialogItemColor: "0x007FEFFF",
        'DialogTextColor: "0x007FEFFF",
        DialogTextColor: "0xC0C0C0FF",
        'DialogFocusColor: "0x007FEFFF",
        DialogFocusColor: "0xC0C0C0FF",
        DialogFocusItemColor: "0x003E7EFF",
        DialogSecondaryTextColor: "0x007FEF66",
        DialogSecondaryItemColor: "0x807FFF4D",
        DialogInputFieldColor: "0x807FFF80",
        DialogKeyboardColor: "0x807FFF4D",
        DialogFootprintColor: "0x807FFF4D"
    }

    dialogTextColor = m.top.palette.colors["DialogTextColor"]
end sub

sub printSelectedButtonAndClose()
    if m.buttonArea.getChild(m.top.buttonSelected).text = "OK"
        for each key in m.data
            if m.data[key] = m.radioButtons.selectedIndex
                m.top.selectedValue = m.top.values[key]
                exit for
            end if
        end for
    end if
    m.top.close = true
end sub