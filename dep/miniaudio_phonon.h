#pragma once

#include <phonon.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "miniaudio.h"

typedef struct
{
    ma_node_config nodeConfig;
    ma_uint32 channelsIn;
    IPLAudioSettings iplAudioSettings;
    IPLContext iplContext;
    IPLHRTF iplHRTF;   /* There is one HRTF object to many binaural effect objects. */
} ma_phonon_binaural_node_config;

MA_API ma_phonon_binaural_node_config ma_phonon_binaural_node_config_init(ma_uint32 channelsIn, IPLAudioSettings iplAudioSettings, IPLContext iplContext, IPLHRTF iplHRTF);


typedef struct
{
    ma_node_base baseNode;
    IPLAudioSettings iplAudioSettings;
    IPLContext iplContext;
    IPLBinauralEffect iplEffect;
    IPLBinauralEffectParams iplEffectParams;
    float spatial_blend_max_distance;
    
    float* ppBuffersIn[2];      /* Each buffer is an offset of _pHeap. */
    float* ppBuffersOut[2];     /* Each buffer is an offset of _pHeap. */
    void* _pHeap;
} ma_phonon_binaural_node;

MA_API ma_result ma_phonon_binaural_node_init(ma_node_graph* pNodeGraph, const ma_phonon_binaural_node_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_phonon_binaural_node* pBinauralNode);
MA_API void ma_phonon_binaural_node_uninit(ma_phonon_binaural_node* pBinauralNode, const ma_allocation_callbacks* pAllocationCallbacks);
MA_API ma_result ma_phonon_binaural_node_set_direction(ma_phonon_binaural_node* pBinauralNode, float x, float y, float z, float distance);
MA_API ma_result ma_phonon_binaural_node_set_spatial_blend_max_distance(ma_phonon_binaural_node* pBinauralNode, float max_distance);

#ifdef __cplusplus
}
#endif
