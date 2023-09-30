' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    cameraNumber = m.top.content.id.toStr()
    timems = CreateObject("roDateTime").AsSeconds().toStr()
    url = "https://traffic.ottawa.ca/map/camera?id=" + cameraNumber
    file = "tmp:/camera" + timems + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL(url)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    utrans.GetToFile(file)

    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        hdPosterUrl: file,
        title: m.top.content.title,
        id: m.top.content.id
    }, true)
    print contentNode
    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
    m.top.content = contentNode
end sub
