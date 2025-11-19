#ifndef HL_GENERAL_HELPER
#define HL_GENERAL_HELPER

float DistanceTravelToReachPlaneDefinedByRayFromWorldSpace(float3 planeNormal, float3 planeOrigin, float3 worldPos, float3 viewVector)
{
    // the Quad can be defined as: dot(planeNormalWS, P - planeOriginWS) = 0
    // also P = posWS - viewDirWS * t, solve t
    return dot(planeNormal, (worldPos - planeOrigin)) * rcp(dot(planeNormal, viewVector));
}

float WorldSpaceQuadMask(float3 posWS, float3 viewDirWS, float3 camPosWS, float3 quadOriginWS, float3 quadBoundaryXEndWS, float3 quadBoundaryYEndWS)
{
    float3 originToXWS = quadBoundaryXEndWS - quadOriginWS;
    float3 originToYWS = quadBoundaryYEndWS - quadOriginWS;
    float3 quadNormal = normalize(cross(originToXWS, originToYWS));

    float t = DistanceTravelToReachPlaneDefinedByRayFromWorldSpace(quadNormal, quadOriginWS, posWS, viewDirWS);
    float3 plane = posWS - viewDirWS * t;
    // clip the plane to bounding box
    float2 quadSpanLocalSpace = float2(dot(normalize(originToXWS), plane - quadOriginWS), dot(normalize(originToYWS), plane - quadOriginWS));
    
    bool inSide =
            quadSpanLocalSpace.x >= 0
        && quadSpanLocalSpace.x <= length(originToXWS)
        && quadSpanLocalSpace.y >= 0
        && quadSpanLocalSpace.y <= length(originToYWS);
    
    return !inSide ? 1 : distance(camPosWS, posWS) > distance(camPosWS, plane) ? 0 : 1;
}
#endif