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

    if contentNode.city = m.global.city.vancouver
        cameraUrls = GetVancouverImages(contentNode.url)
        contentNode.hdPosterUrl = cameraUrls[Rnd(cameraUrls.count()) - 1]
    else
        contentNode.hdPosterUrl = GetCameraImage(contentNode)
    end if

    m.top.content = contentNode
end sub