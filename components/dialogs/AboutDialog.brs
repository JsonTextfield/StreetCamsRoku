function Init()
    m.top.width  = "900"
    m.top.ObserveFieldScoped("buttonSelected", "CloseDialog")
end function

sub CloseDialog()
    m.top.close = true
end sub