#ifndef HL_GENERAL_HELPER
#define HL_GENERAL_HELPER

float DistanceTravelToReachPlaneDefinedByNormalFromWorldSpace(float3 planeNormal, float3 planeOrigin, float3 worldPos, float3 viewVector)
{
    return dot(planeNormal, (worldPos - planeOrigin)) / dot(planeNormal, viewVector);
}

#endif