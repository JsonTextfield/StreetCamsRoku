sub OnContentSet() ' invoked when item metadata retrieved
    content = m.top.itemContent
    ' set poster uri if content is valid
    if content <> invalid
        m.top.FindNode("title").text = content.title
        m.top.FindNode("neighbourhood").text = content.neighbourhood
    end if
end sub

sub FocusChanged()
    if m.top.isFocused
        m.top.FindNode("title").color = "#000000"
        m.top.FindNode("neighbourhood").color = "#000000"
    else
        m.top.FindNode("title").color = "#000000"
        m.top.FindNode("neighbourhood").text = "#000000"
    end if
end sub
