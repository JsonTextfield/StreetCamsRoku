' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    camera = m.top.content

    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        city: camera.city,
        url: camera.url,
        hdPosterUrl: GetCameraImage(camera),
        title: m.top.content.title,
        id: m.top.content.id
    }, true)
    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment

    ? contentNode
    m.top.content = contentNode
end sub


function GetCameraImage(camera) as string
    uuid = CreateObject("roDeviceInfo").GetRandomUUID()

    if camera.city <> m.global.city.ottawa then return camera.url + "?uuid=" + uuid

    file = "tmp:/" + uuid + ".jpg"

    utrans = CreateObject("roURLTransfer")
    utrans.SetURL(camera.url)
    utrans.SetCertificatesFile("common:/certs/ca-bundle.crt")
    if camera.city = m.global.city.ottawa
        utrans.AddHeader("Cookie", "JSESSIONID=" + m.global.cookies.value.toStr())
    end if
    utrans.GetToFile(file)

    return file
end function
