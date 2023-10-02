' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    camera = m.top.content

    timems = CreateObject("roDateTime").AsSeconds().toStr()
    file = "tmp:/camera" + timems + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL(camera.url)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    if camera.city = "ottawa"
        utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    end if
    utrans.GetToFile(file)

    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        city: camera.city,
        url: camera.url,
        hdPosterUrl: file,
        title: m.top.content.title,
        id: m.top.content.id
    }, true)
    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment

    ? contentNode
    m.top.content = contentNode
end sub
