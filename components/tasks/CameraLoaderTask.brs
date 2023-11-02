sub Init()
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    contentNode = m.top.content

    if m.top.shuffle
        camera = m.global.cameras[Rnd(m.global.cameras.count()) - 1]

        contentNode.Update(camera, true)

        name = camera.nameEn

        if name = "" then name = camera.nameFr

        contentNode.title = name
    end if

    contentNode.hdPosterUrl = GetCameraImage(contentNode)

    m.top.content = contentNode
end sub