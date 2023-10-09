sub OnContentSet() ' invoked when item metadata retrieved
    content = m.top.itemContent
    ' set poster uri if content is valid
    if content <> invalid
        m.top.FindNode("title").text = content.title
        m.top.FindNode("neighbourhood").text = content.neighbourhood
    end if
end sub
