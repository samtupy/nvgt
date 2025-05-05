// Initially, much of this code was taken and then modified from the already existing engine_phonon.c file provided with miniaudio.

#include <string.h>
#include <stdint.h>
#include "miniaudio_phonon.h"

static ma_result ma_result_from_IPLerror(IPLerror error)
{
	switch (error)
	{
		case IPL_STATUS_SUCCESS:	 return MA_SUCCESS;
		case IPL_STATUS_OUTOFMEMORY: return MA_OUT_OF_MEMORY;
		case IPL_STATUS_INITIALIZATION:
		case IPL_STATUS_FAILURE:
		default: return MA_ERROR;
	}
}

MA_API ma_phonon_binaural_node_config ma_phonon_binaural_node_config_init(ma_uint32 channelsIn, IPLAudioSettings iplAudioSettings, IPLContext iplContext, IPLHRTF iplHRTF)
{
	ma_phonon_binaural_node_config config;

	memset(&config, 0, sizeof(ma_phonon_binaural_node_config));
	config.nodeConfig	   = ma_node_config_init();
	config.channelsIn	   = channelsIn;
	config.iplAudioSettings = iplAudioSettings;
	config.iplContext	   = iplContext;
	config.iplHRTF		  = iplHRTF;

	return config;
}


static void ma_phonon_binaural_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut)
{
	ma_phonon_binaural_node* pBinauralNode = (ma_phonon_binaural_node*)pNode;
	IPLAudioBuffer inputBufferDesc;
	IPLAudioBuffer outputBufferDesc;
	ma_uint32 totalFramesToProcess = *pFrameCountOut;
	ma_uint32 totalFramesProcessed = 0;

	inputBufferDesc.numChannels = (IPLint32)ma_node_get_input_channels(pNode, 0);

	/* We'll run this in a loop just in case our deinterleaved buffers are too small. */
	outputBufferDesc.numSamples  = pBinauralNode->iplAudioSettings.frameSize;
	outputBufferDesc.numChannels = 2;
	outputBufferDesc.data		= pBinauralNode->ppBuffersOut;

	while (totalFramesProcessed < totalFramesToProcess) {
		ma_uint32 framesToProcessThisIteration = totalFramesToProcess - totalFramesProcessed;
		if (framesToProcessThisIteration > (ma_uint32)pBinauralNode->iplAudioSettings.frameSize) {
			framesToProcessThisIteration = (ma_uint32)pBinauralNode->iplAudioSettings.frameSize;
		}

		if (inputBufferDesc.numChannels == 1) {
			/* Fast path. No need for deinterleaving since it's a mono stream. */
			pBinauralNode->ppBuffersIn[0] = (float*)ma_offset_pcm_frames_const_ptr_f32(ppFramesIn[0], totalFramesProcessed, 1);
		} else {
			/* Slow path. Need to deinterleave the input data. */
			ma_deinterleave_pcm_frames(ma_format_f32, inputBufferDesc.numChannels, framesToProcessThisIteration, ma_offset_pcm_frames_const_ptr_f32(ppFramesIn[0], totalFramesProcessed, inputBufferDesc.numChannels), (void**)&pBinauralNode->ppBuffersIn[0]);
		}

		inputBufferDesc.data	   = pBinauralNode->ppBuffersIn;
		inputBufferDesc.numSamples = (IPLint32)framesToProcessThisIteration;

		/* Apply the effect. */
		iplBinauralEffectApply(pBinauralNode->iplEffect, &pBinauralNode->iplEffectParams, &inputBufferDesc, &outputBufferDesc);

		/* Interleave straight into the output buffer. */
		ma_interleave_pcm_frames(ma_format_f32, 2, framesToProcessThisIteration, (const void**)&pBinauralNode->ppBuffersOut[0], ma_offset_pcm_frames_ptr_f32(ppFramesOut[0], totalFramesProcessed, 2));

		/* Advance. */
		totalFramesProcessed += framesToProcessThisIteration;
	}

	(void)pFrameCountIn;	/* Unused. */
}

static ma_node_vtable g_ma_phonon_binaural_node_vtable =
{
	ma_phonon_binaural_node_process_pcm_frames,
	NULL,
	1,  /* 1 input channel. */
	1,  /* 1 output channel. */
	0
};

#define ma_offset_ptr64(p, offset) ((void*)((ma_uint8*)(p) + (uintptr_t)(offset))) // ma_offset_ptr is giving warning c4312 conversion from int to float* of greater size even though it's used in miniaudio itself which is a header we literally include, finding whatever tiny piece of magic the ma dev used to make that work is not worth it.

MA_API ma_result ma_phonon_binaural_node_init(ma_node_graph* pNodeGraph, const ma_phonon_binaural_node_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_phonon_binaural_node* pBinauralNode)
{
	ma_result result;
	ma_node_config baseConfig;
	ma_uint32 channelsIn;
	ma_uint32 channelsOut;
	IPLBinauralEffectSettings iplBinauralEffectSettings;
	IPLBinauralEffectParams binauralParams;
	size_t heapSizeInBytes;

	if (pBinauralNode == NULL) {
		return MA_INVALID_ARGS;
	}

	memset(pBinauralNode, 0, sizeof(ma_phonon_binaural_node));

	if (pConfig == NULL || pConfig->iplAudioSettings.frameSize == 0 || pConfig->iplContext == NULL || pConfig->iplHRTF == NULL) {
		return MA_INVALID_ARGS;
	}

	/* Steam Audio only supports mono and stereo input. */
	if (pConfig->channelsIn < 1 || pConfig->channelsIn > 2) {
		return MA_INVALID_ARGS;
	}

	channelsIn  = pConfig->channelsIn;
	channelsOut = 2;	/* Always stereo output. */

	baseConfig = ma_node_config_init();
	baseConfig.vtable		  = &g_ma_phonon_binaural_node_vtable;
	baseConfig.pInputChannels  = &channelsIn;
	baseConfig.pOutputChannels = &channelsOut;
	result = ma_node_init(pNodeGraph, &baseConfig, pAllocationCallbacks, &pBinauralNode->baseNode);
	if (result != MA_SUCCESS) {
		return result;
	}

	pBinauralNode->iplAudioSettings = pConfig->iplAudioSettings;
	pBinauralNode->iplContext	   = pConfig->iplContext;

	pBinauralNode->spatial_blend_max_distance = 4.0;

	memset(&iplBinauralEffectSettings, 0, sizeof(IPLBinauralEffectSettings));
	iplBinauralEffectSettings.hrtf = pConfig->iplHRTF;
	memset(&binauralParams, 0, sizeof(IPLBinauralEffectParams));
	binauralParams.interpolation = IPL_HRTFINTERPOLATION_NEAREST;
	binauralParams.hrtf		  = pConfig->iplHRTF;
	pBinauralNode->iplEffectParams = binauralParams;

	result = ma_result_from_IPLerror(iplBinauralEffectCreate(pBinauralNode->iplContext, &pBinauralNode->iplAudioSettings, &iplBinauralEffectSettings, &pBinauralNode->iplEffect));
	if (result != MA_SUCCESS) {
		ma_node_uninit(&pBinauralNode->baseNode, pAllocationCallbacks);
		return result;
	}

	heapSizeInBytes = 0;

	/*
	Unfortunately Steam Audio uses deinterleaved buffers for everything so we'll need to use some
	intermediary buffers. We'll allocate one big buffer on the heap and then use offsets. We'll
	use the frame size from the IPLAudioSettings structure as a basis for the size of the buffer.
	*/
	heapSizeInBytes += sizeof(float) * channelsOut * pBinauralNode->iplAudioSettings.frameSize; /* Output buffer. */
	heapSizeInBytes += sizeof(float) * channelsIn  * pBinauralNode->iplAudioSettings.frameSize; /* Input buffer. */

	pBinauralNode->_pHeap = ma_malloc(heapSizeInBytes, pAllocationCallbacks);
	if (pBinauralNode->_pHeap == NULL) {
		iplBinauralEffectRelease(&pBinauralNode->iplEffect);
		ma_node_uninit(&pBinauralNode->baseNode, pAllocationCallbacks);
		return MA_OUT_OF_MEMORY;
	}

	pBinauralNode->ppBuffersOut[0] = (float*)pBinauralNode->_pHeap;
	pBinauralNode->ppBuffersOut[1] = (float*)ma_offset_ptr64(pBinauralNode->_pHeap, sizeof(float) * pBinauralNode->iplAudioSettings.frameSize);

	{
		ma_uint32 iChannelIn;
		for (iChannelIn = 0; iChannelIn < channelsIn; iChannelIn += 1) {
			pBinauralNode->ppBuffersIn[iChannelIn] = (float*)ma_offset_ptr64(pBinauralNode->_pHeap, sizeof(float) * pBinauralNode->iplAudioSettings.frameSize * (channelsOut + iChannelIn));
		}
	}

	return MA_SUCCESS;
}

MA_API void ma_phonon_binaural_node_uninit(ma_phonon_binaural_node* pBinauralNode, const ma_allocation_callbacks* pAllocationCallbacks)
{
	if (pBinauralNode == NULL) {
		return;
	}
	/* The base node is always uninitialized first. */
	ma_node_uninit(&pBinauralNode->baseNode, pAllocationCallbacks);
	/*
	The Steam Audio objects are deleted after the base node. This ensures the base node is removed from the graph
	first to ensure these objects aren't getting used by the audio thread.
	*/
	iplBinauralEffectRelease(&pBinauralNode->iplEffect);
	ma_free(pBinauralNode->_pHeap, pAllocationCallbacks);
}

MA_API ma_result ma_phonon_binaural_node_set_direction(ma_phonon_binaural_node* pBinauralNode, float x, float y, float z, float distance)
{
	if (pBinauralNode == NULL) {
		return MA_INVALID_ARGS;
	}
	pBinauralNode->iplEffectParams.direction.x = x;
	pBinauralNode->iplEffectParams.direction.y = y;
	pBinauralNode->iplEffectParams.direction.z = z;
	pBinauralNode->iplEffectParams.spatialBlend = pBinauralNode->spatial_blend_max_distance > 0? distance / pBinauralNode->spatial_blend_max_distance : 1.0f;
	if (pBinauralNode->iplEffectParams.spatialBlend > 1.0) pBinauralNode->iplEffectParams.spatialBlend = 1.0;
	return MA_SUCCESS;
}

MA_API ma_result ma_phonon_binaural_node_set_spatial_blend_max_distance(ma_phonon_binaural_node* pBinauralNode, float max_distance)
{
	if (pBinauralNode == NULL) {
		return MA_INVALID_ARGS;
	}
	pBinauralNode->spatial_blend_max_distance = max_distance;
	return MA_SUCCESS;
}

