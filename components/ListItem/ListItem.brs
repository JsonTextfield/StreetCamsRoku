sub Init()
    m.distanceLabel = CreateObject("roSGNode", "Label")
    m.distanceLabel.width = 100
    m.distanceLabel.height = 100
    m.distanceLabel.horizAlign = "center"
    m.distanceLabel.vertAlign = "center"
    m.distanceLabel.maxLines = 2
    m.distanceLabel.wrap = true
    m.distanceLabel.font = "font:SmallestSystemFont"
    m.distanceLabel.color = "#444444"
end sub

sub OnContentSet() ' invoked when item metadata retrieved
    content = m.top.itemContent
    ' set poster uri if content is valid
    if content <> invalid
        m.top.FindNode("title").text = content.title
        m.top.FindNode("neighbourhood").text = content.neighbourhood

        m.prefs = CreateObject("roRegistrySection", "prefs")
        m.sortMode = m.prefs.Read("sortMode")
        if m.sortMode = m.global.sortMode.distance
            distance = content.distance
            distanceStr = ""
            if distance > 9000000
                distanceStr = "> 9000 km"
            else if distance > 10000
                distanceStr = (Int(distance / 1000)).ToStr() + " km"
            else if distance > 1000
                distanceStr = (distance / 1000).ToStr() + " km"
            else
                distanceStr = (distance).ToStr() + " m"
            end if
            m.distanceLabel.text = distanceStr
            m.top.FindNode("group").InsertChild(m.distanceLabel, 0)
        else
            m.top.FindNode("group").RemoveChild(m.distanceLabel)
        end if
    end if
end sub

sub FocusChanged()
    print "FocusChanged"
    if m.top.FindNode("group").hasFocus()
        m.top.FindNode("title").color = "#000000"
        m.top.FindNode("neighbourhood").color = "#000000"
    else
        m.top.FindNode("title").color = "#FFFFFF"
        m.top.FindNode("neighbourhood").color = "#FFFFFF"
    end if
end sub
