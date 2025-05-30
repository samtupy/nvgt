#ifndef el_tonar_h
#define el_tonar_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define elz_tonar_begin 0xACC737A3
#define elz_tonar_end 0xDC76AAED

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#ifndef M_PI_4
#define M_PI_4 0.78539816339744830962
#endif

typedef enum
{
waveform_sine=0,
waveform_triangle,
waveform_square,
waveform_saw,
waveform_max,
}
el_tonar_waveform;

typedef struct elz_tonar el_tonar;

int el_tonar_reset(el_tonar* gen);
int el_tonar_set_waveform(el_tonar* gen, int type);
int el_tonar_set_volume(el_tonar* gen, double db);
int el_tonar_set_pan(el_tonar* gen, double pan);
int el_tonar_set_edge_fades(el_tonar* gen, int start, int end);
int el_tonar_freq(el_tonar* gen, double freq, int ms);
int el_tonar_rest(el_tonar* gen, int ms);
int el_tonar_output_buffer_size(el_tonar* gen);
int el_tonar_output_buffer(el_tonar* gen, char* buffer, int size);
int el_tonar_output_file(el_tonar* gen, char* fn);

struct elz_tonar
{
int begin;
double* data;
int cursor;
int length;
int size;
int sample_rate;
int channels;
double peak;
double pan;
double volume;
int fade_start;
int fade_end;
int waveform;
int end;
};

int elz_tonar_cleanup(el_tonar* gen);
int elz_tonar_is_init(el_tonar* gen);
int elz_tonar_is_empty(el_tonar* gen);
int elz_tonar_is_silent(el_tonar* gen);
int elz_tonar_ms_to_frames(el_tonar* gen, int ms);
int elz_tonar_manage_buffer(el_tonar* gen, int samples);
double elz_tonar_generate_waveform(int type, int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_sine(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_triangle(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_triangle_v2(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_square(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_square_v2(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_saw(int frame, double freq, int sample_rate, double amplitude);
double elz_tonar_generate_saw_v2(int frame, double freq, int sample_rate, double amplitude);
void elz_tonar_mix_sample(el_tonar* gen, int index, double value);
double elz_tonar_normalise_sample(el_tonar* gen, int index);
short elz_tonar_float_to_sample(double sample);
int elz_tonar_output_wave_header(el_tonar* gen, char* buffer, int buffer_size, int data_size);
int elz_tonar_get_offset(el_tonar* gen, int frame);
void elz_tonar_add_sample(el_tonar* gen, int frame, double value);
double elz_tonar_db_to_amp(double db);
int elz_tonar_calculate_fade_start(el_tonar* gen, int ms);
int elz_tonar_calculate_fade_end(el_tonar* gen, int ms);
double elz_tonar_apply_fade_in(int frame, int fade_in_frames, double sample);
double elz_tonar_apply_fade_out(int frame, int total_frames, int fade_out_frames, double sample);
int elz_tonar_adjust_length(el_tonar* gen, int samples);
double elz_tonar_poly_blep(double t, double dt);

#endif
