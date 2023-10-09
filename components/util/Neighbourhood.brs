function containsCamera(neighbourhood as Object, camera as Object) as Boolean
    intersectCount = 0
    cameraLocation = {latitude: camera.lat, longitude: camera.lon}

    for each points in neighbourhood.boundaries
        for j = 0 to points.count() - 2
            if onSegment(points[j], cameraLocation, points[j + 1]) then
                return true
            end if
            if rayCastIntersect(cameraLocation, points[j], points[j + 1]) then
                intersectCount = intersectCount + 1
            end if
        end for
    end for

    ' odd = inside, even = outside
    return (intersectCount mod 2) = 1
end function


function onSegment(a as object, location as object, b as object) as boolean
    ' Calculate slopes
    rise1 = b.latitude - a.latitude
    run1 = b.longitude - a.longitude
    slope1 = rise1 / run1

    rise2 = b.latitude - location.latitude
    run2 = b.longitude - location.longitude
    slope2 = rise2 / run2

    ' Check conditions and return result
    return location.longitude <= Max(a.longitude, b.longitude) and location.longitude >= Min(a.longitude, b.longitude) and location.latitude <= Max(a.latitude, b.latitude) and location.latitude >= Min(a.latitude, b.latitude) and slope2.AbsoluteValue() = slope1.AbsoluteValue()
end function

function rayCastIntersect(location as Object, a as Object, b as Object) as Boolean
    ' Extract coordinates
    aX = a.longitude
    aY = a.latitude
    bX = b.longitude
    bY = b.latitude
    locX = location.longitude
    locY = location.latitude

    ' Check if both points are above or below the location's latitude
    ' or if both points are to the left of the location's longitude
    if (aY > locY and bY > locY) or (aY < locY and bY < locY) or (aX < locX and bX < locX) then
        ' a and b can't both be above or below locY, and a or b must be east of locX
        return false
    end if

    ' Check for vertical line
    if aX = bX then
        return aX >= locX
    end if

    ' Calculate slope
    rise1 = aY - bY
    run1 = aX - bX
    slope1 = rise1 / run1

    ' Calculate c = -mx + y
    c = -slope1 * aX + aY

    ' Calculate x = (locY - c) / slope
    x = (locY - c) / slope1

    ' Check if x is greater than or equal to locX
    return x >= locX
end function
