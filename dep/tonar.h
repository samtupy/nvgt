#ifndef el_tonar_h
#define el_tonar_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

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
el_tonar_waveform_sine=0,
el_tonar_waveform_triangle,
el_tonar_waveform_square,
el_tonar_waveform_saw,
el_tonar_waveform_max,
}
el_tonar_waveform;

typedef enum
{
elz_tonar_bend_linear,
elz_tonar_bend_exponential,
}
elz_tonar_bend_curve;

typedef struct elz_tonar el_tonar;

int el_tonar_reset(el_tonar* gen);
int el_tonar_set_waveform(el_tonar* gen, int type);
int el_tonar_get_waveform(el_tonar* gen);
int el_tonar_set_volume(el_tonar* gen, double db);
double el_tonar_get_volume(el_tonar* gen);
int el_tonar_set_pan(el_tonar* gen, double pan);
double el_tonar_get_pan(el_tonar* gen);
int el_tonar_set_edge_fades(el_tonar* gen, int start, int end);
int el_tonar_set_tempo(el_tonar* gen, double tempo);
double el_tonar_get_tempo(el_tonar* gen);
int el_tonar_set_note_transpose(el_tonar* gen, double note_transpose);
double el_tonar_get_note_transpose(el_tonar* gen);
int el_tonar_set_freq_transpose(el_tonar* gen, double freq_transpose);
double el_tonar_get_freq_transpose(el_tonar* gen);
int el_tonar_note(el_tonar* gen, char* note, double length);
int el_tonar_note_ms(el_tonar* gen, char* note, int ms);
int el_tonar_freq(el_tonar* gen, double freq, double length);
int el_tonar_freq_ms(el_tonar* gen, double freq, int ms);
int el_tonar_note_bend(el_tonar* gen, char* note, int bend_amount, double length, double bend_start, double bend_length);
int el_tonar_note_bend_ms(el_tonar* gen, char* note, int bend_amount, int length, int bend_start, int bend_length);
int el_tonar_freq_bend(el_tonar* gen, double freq, double bend_amount, double length, double bend_start, double bend_length);
int el_tonar_freq_bend_ms(el_tonar* gen, double freq, int bend_amount, int length, int bend_start, int bend_length);
int el_tonar_rest(el_tonar* gen, double length);
int el_tonar_rest_ms(el_tonar* gen, int ms);
double el_tonar_get_length(el_tonar* gen);
int el_tonar_get_length_ms(el_tonar* gen);
double el_tonar_get_position(el_tonar* gen);
int el_tonar_get_position_ms(el_tonar* gen);
int el_tonar_seek(el_tonar* gen, double position);
int el_tonar_seek_ms(el_tonar* gen, int position);
int el_tonar_rewind(el_tonar* gen, double amount);
int el_tonar_rewind_ms(el_tonar* gen, int amount);
int el_tonar_output_buffer_size(el_tonar* gen);
int el_tonar_output_buffer(el_tonar* gen, char* buffer, int size);
int el_tonar_output_file(el_tonar* gen, char* fn);

struct elz_tonar
{
int begin;
double* data;
double phase;
int cursor;
int length;
int size;
double tempo;
double note_transpose;
double freq_transpose;
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
int elz_tonar_sequence(el_tonar* gen, double freq, double bend_amount, int length, int bend_start, int bend_length);
int elz_tonar_ms_to_frames(el_tonar* gen, int ms);
int elz_tonar_manage_buffer(el_tonar* gen, int samples);
double elz_tonar_generate_waveform(el_tonar* gen, double freq, double amplitude);
double elz_tonar_generate_sine(el_tonar* gen, double freq, double amplitude);
double elz_tonar_generate_triangle(el_tonar* gen, double freq, double amplitude);
double elz_tonar_generate_square(el_tonar* gen, double freq, double amplitude);
double elz_tonar_generate_saw(el_tonar* gen, double freq, double amplitude);
double elz_tonar_phase_step(double freq, int sample_rate);
void elz_tonar_next_phase(el_tonar* gen, double freq);
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
double elz_tonar_calculate_frequency_at_frame(double start_freq, double target_freq, int current_frame, int bend_start_frame, int bend_end_frame, elz_tonar_bend_curve curve);
double elz_tonar_poly_blep(double t, double dt);

double elz_tonar_music_note_to_freq(int note);
int elz_tonar_music_name_to_note(char* name, int transpose);
int elz_tonar_music_beat_to_ms(double tempo, double beat);
double elz_tonar_music_ms_to_beat(double tempo, int ms);

#endif
