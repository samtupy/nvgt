/* resampler.cpp - Miniaudio binding for WDL resampler.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */
#include <resample.h>
#include <miniaudio.h>
struct wdl_resampler_state
{
    WDL_Resampler resampler;
    ma_uint32 rate_in;
    ma_uint32 rate_out;
    ma_uint8 channels;
    ma_uint64 last_prepare;
};
// Miniaudio allocates heap space for our resampler and expects us to fill it in. So we must report how much we need.
static ma_result resampler_get_heap_size(void *pUserData, const ma_resampler_config *pConfig, size_t *pHeapSizeInBytes)
{
    *pHeapSizeInBytes = sizeof(wdl_resampler_state);
    return MA_SUCCESS;
}
static ma_result resampler_init(void *pUserData, const ma_resampler_config *pConfig, void *pHeap, ma_resampling_backend **ppBackend)
{
    memset(pHeap, 0, sizeof(wdl_resampler_state));
    wdl_resampler_state *state = (wdl_resampler_state *)pHeap;
    state->channels = pConfig->channels;
    state->rate_in = pConfig->sampleRateIn;
    state->rate_out = pConfig->sampleRateOut;
    state->last_prepare = 0;
    state->resampler = WDL_Resampler();
    state->resampler.SetMode(false, 0, true, 64, 32);
    state->resampler.SetRates(pConfig->sampleRateIn, pConfig->sampleRateOut);
    state->resampler.SetFeedMode(false);
    *ppBackend = state;

    return MA_SUCCESS;
}
static void resampler_uninit(void *pUserData, ma_resampling_backend *pBackend, const ma_allocation_callbacks *pAllocationCallbacks)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    // Need to make an explicit destructor call because MA is about to just free the buffer it gave me.
    state->resampler.~WDL_Resampler();
}
static ma_result resampler_process(void *pUserData, ma_resampling_backend *pBackend, const void *pFramesIn, ma_uint64 *pFrameCountIn, void *pFramesOut, ma_uint64 *pFrameCountOut)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    state->resampler.SetFeedMode(false);
    float *dest; // The resampler will point this to internal memory where we'll need to write some audio data.
    int prepare = state->resampler.ResamplePrepare(*pFrameCountOut, state->channels, &dest);

    if (prepare > *pFrameCountIn)
    {
        // We don't have enough to produce the requested amount of output, so prepare again to produce as much as possible.
        state->resampler.SetFeedMode(true);
        prepare = state->resampler.ResamplePrepare(*pFrameCountIn, state->channels, &dest);
    }
    memcpy(dest, pFramesIn, prepare * sizeof(float) * state->channels);
    *pFrameCountIn = prepare;
    *pFrameCountOut = state->resampler.ResampleOut((float *)pFramesOut, prepare, *pFrameCountOut, state->channels);

    return MA_SUCCESS;
}
static ma_result resampler_set_rate(void *pUserData, ma_resampling_backend *pBackend, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    state->resampler.SetRates(sampleRateIn, sampleRateOut);
    state->rate_in = sampleRateIn;
    state->rate_out = sampleRateOut;
    return MA_SUCCESS;
}
static ma_uint64 resampler_get_input_latency(void *pUserData, const ma_resampling_backend *pBackend)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    return (ma_uint64)(state->resampler.GetCurrentLatency() * state->rate_in);
}
static ma_uint64 resampler_get_output_latency(void *pUserData, const ma_resampling_backend *pBackend)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    return (ma_uint64)(state->resampler.GetCurrentLatency() * state->rate_in);
}
static ma_result resampler_get_required_input_frame_count(void *pUserData, const ma_resampling_backend *pBackend, ma_uint64 outputFrameCount, ma_uint64 *pInputFrameCount)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    state->resampler.SetFeedMode(false);
    *pInputFrameCount = state->resampler.ResamplePrepare(outputFrameCount, state->channels, (float **)&state);
    return MA_NOT_IMPLEMENTED;
}
static ma_result resampler_get_expected_output_frame_count(void *pUserData, const ma_resampling_backend *pBackend, ma_uint64 inputFrameCount, ma_uint64 *pOutputFrameCount)
{
    *pOutputFrameCount = 0;
    return MA_NOT_IMPLEMENTED;
}
static ma_result resampler_reset(void *pUserData, ma_resampling_backend *pBackend)
{
    wdl_resampler_state *state = (wdl_resampler_state *)pBackend;
    state->resampler.Reset();
    return MA_SUCCESS;
}
ma_resampling_backend_vtable wdl_resampler_backend_vtable = {
    resampler_get_heap_size,
    resampler_init,
    resampler_uninit,
    resampler_process,
    resampler_set_rate,
    resampler_get_input_latency,
    resampler_get_output_latency,
    resampler_get_required_input_frame_count,
    resampler_get_expected_output_frame_count,
    resampler_reset,
};
