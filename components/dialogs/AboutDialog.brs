function init()
    m.top.width  = "1380"

    m.buttonArea = m.top.findNode("buttonArea")
    m.top.observeFieldScoped("buttonFocused", "printFocusButton")
    m.top.observeFieldScoped("buttonSelected", "printSelectedButtonAndClose")
    m.top.observeFieldScoped("wasClosed", "wasClosedChanged")
end function

sub printFocusButton()
    print "m.buttonArea button ";m.buttonArea.getChild(m.top.buttonFocused).text;" focused"
end sub

sub printSelectedButtonAndClose()
    print "m.buttonArea button ";m.buttonArea.getChild(m.top.buttonSelected).text;" selected"
    m.top.close = true
end sub

sub wasClosedChanged()
    print "SideCardRightDialog Closed"
end sub