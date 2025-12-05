#include "tonar.h"

int el_tonar_reset(el_tonar* gen)
{
if(!gen) return 0;
elz_tonar_cleanup(gen);
gen->data=NULL;
gen->phase=0;
gen->cursor=0;
gen->length=0;
gen->size=0;
gen->waveform=el_tonar_waveform_sine;
gen->volume=0;
gen->pan=0;
gen->fade_start=el_tonar_default_fade_start;
gen->fade_end=el_tonar_default_fade_end;
gen->note_transpose=0;
gen->freq_transpose=0;
gen->tempo=120;
gen->sample_rate=44100;
gen->channels=2;
gen->peak=0;
gen->output_silence=0;
gen->begin=elz_tonar_begin;
gen->end=elz_tonar_end;
return 1;
}
int el_tonar_set_waveform(el_tonar* gen, int type)
{
if(!elz_tonar_is_init(gen)) return 0;
if(type<0) return 0;
if(type>=el_tonar_waveform_max) return 0;
gen->waveform=type;
return 1;
}
int el_tonar_get_waveform(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return -1;
return gen->waveform;
}
int el_tonar_set_volume(el_tonar* gen, double db)
{
if(!elz_tonar_is_init(gen)) return 0;
if((db<el_tonar_min_db)||(db>el_tonar_max_db)) return 0;
gen->volume=db;
return 1;
}
double el_tonar_get_volume(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->volume;
}
int el_tonar_set_allow_silence(el_tonar* gen, int silence)
{
if(!elz_tonar_is_init(gen)) return 0;
gen->output_silence=(silence? 1: 0);
return 1;
}
int el_tonar_get_allow_silence(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->output_silence;
return 1;
}
int el_tonar_set_pan(el_tonar* gen, double pan)
{
if(!elz_tonar_is_init(gen)) return 0;
if(pan<-100) return 0;
if(pan>100) return 0;
gen->pan=pan;
return 1;
}
double el_tonar_get_pan(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->pan;
}
int el_tonar_set_edge_fades(el_tonar* gen, int start, int end)
{
if(!elz_tonar_is_init(gen)) return 0;
if(start<0) return 0;
if(end<0) return 0;
gen->fade_start=start;
gen->fade_end=end;
return 1;
}
int el_tonar_set_tempo(el_tonar* gen, double tempo)
{
if(!elz_tonar_is_init(gen)) return 0;
if(tempo<1) return 0;
if(tempo>999) return 0;
gen->tempo=tempo;
return 1;
}
double el_tonar_get_tempo(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->tempo;
}
int el_tonar_set_note_transpose(el_tonar* gen, double note_transpose)
{
if(!elz_tonar_is_init(gen)) return 0;
gen->note_transpose=note_transpose;
return 1;
}
double el_tonar_get_note_transpose(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->note_transpose;
}
int el_tonar_set_freq_transpose(el_tonar* gen, double freq_transpose)
{
if(!elz_tonar_is_init(gen)) return 0;
gen->freq_transpose=freq_transpose;
return 1;
}
double el_tonar_get_freq_transpose(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return gen->freq_transpose;
}
int el_tonar_note(el_tonar* gen, char* note, double length)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, elz_tonar_music_note_to_freq(elz_tonar_music_name_to_note(note, gen->note_transpose)), 0, elz_tonar_music_beat_to_ms(gen->tempo, length), 0, 0);
}
int el_tonar_note_ms(el_tonar* gen, char* note, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, elz_tonar_music_note_to_freq(elz_tonar_music_name_to_note(note, gen->note_transpose)), 0, ms, 0, 0);
}
int el_tonar_freq(el_tonar* gen, double freq, double length)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, freq+gen->freq_transpose, 0, elz_tonar_music_beat_to_ms(gen->tempo, length), 0, 0);
}
int el_tonar_freq_ms(el_tonar* gen, double freq, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, freq+gen->freq_transpose, 0, ms, 0, 0);
}
int el_tonar_note_bend(el_tonar* gen, char* note, int bend_amount, double length, double bend_start, double bend_length)
{
if(!elz_tonar_is_init(gen)) return 0;
return el_tonar_note_bend_ms(gen, note, bend_amount, elz_tonar_music_beat_to_ms(gen->tempo, length), elz_tonar_music_beat_to_ms(gen->tempo, bend_start), elz_tonar_music_beat_to_ms(gen->tempo, bend_length));
}
int el_tonar_note_bend_ms(el_tonar* gen, char* note, int bend_amount, int length, int bend_start, int bend_length)
{
if(!elz_tonar_is_init(gen)) return 0;
int start_note=elz_tonar_music_name_to_note(note, gen->note_transpose);
double start_freq=elz_tonar_music_note_to_freq(start_note);
double target_freq=elz_tonar_music_note_to_freq(start_note+bend_amount);
double amount=target_freq-start_freq;
return elz_tonar_sequence(gen, start_freq, amount, length, bend_start, bend_length);
}
int el_tonar_freq_bend(el_tonar* gen, double freq, double bend_amount, double length, double bend_start, double bend_length)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, freq+gen->freq_transpose, bend_amount, elz_tonar_music_beat_to_ms(gen->tempo, length), elz_tonar_music_beat_to_ms(gen->tempo, bend_start), elz_tonar_music_beat_to_ms(gen->tempo, bend_length));
}
int el_tonar_freq_bend_ms(el_tonar* gen, double freq, int bend_amount, int length, int bend_start, int bend_length)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_sequence(gen, freq+gen->freq_transpose, bend_amount, length, bend_start, bend_length);
}
int el_tonar_rest(el_tonar* gen, double length)
{
if(!elz_tonar_is_init(gen)) return 0;
return el_tonar_rest_ms(gen, elz_tonar_music_beat_to_ms(gen->tempo, length));
}
int el_tonar_rest_ms(el_tonar* gen, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
if(ms<=0) return 0;
int frames=elz_tonar_ms_to_frames(gen, ms);
if(frames<=0) return 0;
int samples=frames*gen->channels;
if(!elz_tonar_manage_buffer(gen, samples)) return 0;
gen->cursor+=samples;
if(gen->cursor>gen->length) gen->length=gen->cursor;
return 1;
}
double el_tonar_get_length(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_music_ms_to_beat(gen->tempo, el_tonar_get_length_ms(gen));
}
int el_tonar_get_length_ms(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
double t=((double) gen->length)/(gen->sample_rate*gen->channels)*1000;
return t;
}
double el_tonar_get_position(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
return elz_tonar_music_ms_to_beat(gen->tempo, el_tonar_get_position_ms(gen));
}
int el_tonar_get_position_ms(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 0;
double t=((double) gen->cursor)/(gen->sample_rate*gen->channels)*1000;
return t;
}
int el_tonar_seek(el_tonar* gen, double position)
{
if(!elz_tonar_is_init(gen)) return 0;
return el_tonar_seek_ms(gen, elz_tonar_music_beat_to_ms(gen->tempo, position));
}
int el_tonar_seek_ms(el_tonar* gen, int position)
{
if(position<0) return 0;
int l=el_tonar_get_length(gen);
if(position>=l) return 0;
int frame=elz_tonar_ms_to_frames(gen, position);
int sample=frame*gen->channels;
gen->cursor=sample;
return 1;
}
int el_tonar_rewind(el_tonar* gen, double amount)
{
if(!elz_tonar_is_init(gen)) return 0;
return el_tonar_rewind_ms(gen, elz_tonar_music_beat_to_ms(gen->tempo, amount));
}
int el_tonar_rewind_ms(el_tonar* gen, int amount)
{
return el_tonar_seek(gen, el_tonar_get_position(gen)-amount);
}
int el_tonar_get_sample_rate(el_tonar* gen)
{
return gen->sample_rate;
}
int el_tonar_get_channels(el_tonar* gen)
{
return gen->channels;
}
int el_tonar_output_buffer_size(el_tonar* gen)
{
if(!elz_tonar_can_output(gen)) return 0;
int samples=gen->length;
int bytes_per_sample=2;
return samples*bytes_per_sample;
}
int el_tonar_output_buffer(el_tonar* gen, char* buffer, int size)
{
int needed=el_tonar_output_buffer_size(gen);
if(needed<=0) return 0;
if(size<needed) return 0;
for(int x=0; x<gen->length; x++)
{
double new_sample=elz_tonar_normalise_sample(gen, x);
short output_sample=elz_tonar_float_to_sample(new_sample);
memcpy(buffer, &output_sample, sizeof(output_sample));
buffer+=sizeof(output_sample);
}
return 1;
}
int el_tonar_output_sample_count(el_tonar* gen)
{
if(!elz_tonar_can_output(gen)) return 0;
return gen->length;
}
int el_tonar_output_samples(el_tonar* gen, short* samples, int size)
{
int needed=el_tonar_output_sample_count(gen);
if(needed<=0) return 0;
if(size<needed) return 0;
for(int x=0; x<gen->length; x++)
{
double new_sample=elz_tonar_normalise_sample(gen, x);
short output_sample=elz_tonar_float_to_sample(new_sample);
samples[x]=output_sample;
}
return 1;
}
int el_tonar_output_file(el_tonar* gen, char* fn)
{
int outsize=el_tonar_output_buffer_size(gen);
if(outsize<=0) return 0;
char* output=malloc(outsize+44);
if(!output) return 0;
if(!elz_tonar_output_wave_header(gen, output, 44, outsize))
{
free(output);
return 0;
}
char* data=output+44;
if(!el_tonar_output_buffer(gen, data, outsize))
{
free(output);
return 0;
}
FILE* f=fopen(fn, "wb");
if(!f)
{
free(output);
return 0;
}
fwrite(output, sizeof(char), outsize+44, f);
fclose(f);
free(output);
return 1;
}
int elz_tonar_cleanup(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 1;
if(gen->data) free(gen->data);
return 1;
}
int elz_tonar_is_init(el_tonar* gen)
{
if(!gen) return 0;
if(gen->begin!=elz_tonar_begin) return 0;
if(gen->end!=elz_tonar_end) return 0;
return 1;
}
int elz_tonar_is_empty(el_tonar* gen)
{
if(!elz_tonar_is_init(gen)) return 1;
if(!gen->data) return 1;
if(gen->size<=0) return 1;
return 0;
}
int elz_tonar_is_silent(el_tonar* gen)
{
if(elz_tonar_is_empty(gen)) return 1;
if(gen->peak<=0) return 1;
return 0;
}
int elz_tonar_can_output(el_tonar* gen)
{
if(elz_tonar_is_empty(gen)) return 0;
if(!elz_tonar_is_silent(gen)) return 1;
return gen->output_silence;
}
int elz_tonar_sequence(el_tonar* gen, double freq, double bend_amount, int length, int bend_start, int bend_length)
{
if(!elz_tonar_is_init(gen)) return 0;
gen->phase=0;
double start_freq=freq;
double target_freq=start_freq+bend_amount;
if(start_freq<20) return 0;
if(start_freq>20000) return 0;
if(target_freq<20) return 0;
if(target_freq>20000) return 0;
if(length<=0) return 0;
int bend_end=bend_start+bend_length;
if(bend_end>length) bend_end=length;
int frames=elz_tonar_ms_to_frames(gen, length);
if(frames<=0) return 0;
int samples=frames*gen->channels;
if(!elz_tonar_manage_buffer(gen, samples)) return 0;
double amplitude=elz_tonar_db_to_amp(gen->volume);
int sample_rate=gen->sample_rate;
int fade_start=elz_tonar_calculate_fade_start(gen, length);
int fade_end=elz_tonar_calculate_fade_end(gen, length);
int fade_in_frames=elz_tonar_ms_to_frames(gen, fade_start);
int fade_out_frames=elz_tonar_ms_to_frames(gen, fade_end);
int bend_start_frames=elz_tonar_ms_to_frames(gen, bend_start);
int bend_end_frames=elz_tonar_ms_to_frames(gen, bend_end);
for(int x=0; x<frames; x++)
{
double current_freq=elz_tonar_calculate_frequency_at_frame(start_freq, target_freq, x, bend_start_frames, bend_end_frames, elz_tonar_bend_exponential);
double sample=elz_tonar_generate_waveform(gen, current_freq, amplitude);
sample=elz_tonar_apply_fade_in(x, fade_in_frames, sample);
sample=elz_tonar_apply_fade_out(x, frames, fade_out_frames, sample);
int offset=elz_tonar_get_offset(gen, x);
elz_tonar_add_sample(gen, offset, sample);
}
return elz_tonar_adjust_length(gen, samples);
}
int elz_tonar_ms_to_frames(el_tonar* gen, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
double rate_ms=(double) gen->sample_rate/1000;
rate_ms*=ms;
return rate_ms;
}
int elz_tonar_manage_buffer(el_tonar* gen, int samples)
{
if(!elz_tonar_is_init(gen)) return 0;
samples+=gen->cursor;
if(samples<gen->size) return 1;
samples*=2;
double* data=realloc(gen->data, samples*sizeof(double));
if(!data) return 0;
memset(data+gen->size, 0, (samples-gen->size)*sizeof(double));
gen->data=data;
gen->size=samples;
return 1;
}
double elz_tonar_generate_waveform(el_tonar* gen, double freq, double amplitude)
{
if(!elz_tonar_is_init(gen)) return 0;
if(gen->waveform==el_tonar_waveform_sine) return elz_tonar_generate_sine(gen, freq, amplitude);
if(gen->waveform==el_tonar_waveform_triangle) return elz_tonar_generate_triangle(gen, freq, amplitude);
if(gen->waveform==el_tonar_waveform_square) return elz_tonar_generate_square(gen, freq, amplitude);
if(gen->waveform==el_tonar_waveform_saw) return elz_tonar_generate_saw(gen, freq, amplitude);
return 0;
}
double elz_tonar_generate_sine(el_tonar* gen, double freq, double amplitude)
{
if(!elz_tonar_is_init(gen)) return 0;
double value=amplitude*sin(gen->phase*2.0*M_PI);
elz_tonar_next_phase(gen, freq);
return value;
}
double elz_tonar_generate_triangle(el_tonar* gen, double freq, double amplitude)
{
if(!elz_tonar_is_init(gen)) return 0;
double value=amplitude*(1.0-4.0*fabs(gen->phase-0.5));
elz_tonar_next_phase(gen, freq);
return value;
}
double elz_tonar_generate_square(el_tonar* gen, double freq, double amplitude)
{
if(!elz_tonar_is_init(gen)) return 0;
double dt=freq/gen->sample_rate;
double value=amplitude*(gen->phase>=0.5? -1.0: 1.0);
value+=amplitude*elz_tonar_poly_blep(gen->phase, dt);
value-=amplitude*elz_tonar_poly_blep(fmod(gen->phase+0.5, 1.0), dt);
elz_tonar_next_phase(gen, freq);
return value;
}
double elz_tonar_generate_saw(el_tonar* gen, double freq, double amplitude)
{
if(!elz_tonar_is_init(gen)) return 0;
double dt=freq/gen->sample_rate;
double value=amplitude*(2.0*gen->phase-1.0);
value-=amplitude*elz_tonar_poly_blep(gen->phase, dt);
elz_tonar_next_phase(gen, freq);
return value;
}
double elz_tonar_phase_step(double freq, int sample_rate)
{
return freq/sample_rate;
}
void elz_tonar_next_phase(el_tonar* gen, double freq)
{
if(!elz_tonar_is_init(gen)) return;
gen->phase+=elz_tonar_phase_step(freq, gen->sample_rate);
if(gen->phase>=1.0) gen->phase-=1.0;
}
double elz_tonar_normalise_sample(el_tonar* gen, int sample)
{
if(elz_tonar_is_silent(gen)) return 0;
double peak=gen->peak;
double value=gen->data[sample];
if(peak<1.0) return value;
double factor=1.0/peak;
value*=factor;
return value;
}
short elz_tonar_float_to_sample(double sample)
{
int min=-32768;
int max=32767;
int value=(int) (sample*max);
if(value<min) value=min;
if(value>max) value=max;
return value;
}
int elz_tonar_output_wave_header(el_tonar* gen, char* buffer, int buffer_size, int data_size)
{
if(!elz_tonar_is_init(gen)) return 0;
if(buffer_size<44) return 0;
int fsize=data_size+36;
int csize=16;
short format=1;
short channels=gen->channels;
int sample_rate=gen->sample_rate;
short bits_per_sample=16;
short bytes_per_block=channels*bits_per_sample/8;
int bytes_per_sec=sample_rate*bytes_per_block;
memcpy(buffer, "RIFF", 4);
buffer+=4;
memcpy(buffer, &fsize, sizeof(fsize));
buffer+=sizeof(fsize);
memcpy(buffer, "WAVEfmt ", 8);
buffer+=8;
memcpy(buffer, &csize, sizeof(csize));
buffer+=sizeof(csize);
memcpy(buffer, &format, sizeof(format));
buffer+=sizeof(format);
memcpy(buffer, &channels, sizeof(channels));
buffer+=sizeof(channels);
memcpy(buffer, &sample_rate, sizeof(sample_rate));
buffer+=sizeof(sample_rate);
memcpy(buffer, &bytes_per_sec, sizeof(bytes_per_sec));
buffer+=sizeof(bytes_per_sec);
memcpy(buffer, &bytes_per_block, sizeof(bytes_per_block));
buffer+=sizeof(bytes_per_block);
memcpy(buffer, &bits_per_sample, sizeof(bits_per_sample));
buffer+=sizeof(bits_per_sample);
memcpy(buffer, "data", 4);
buffer+=4;
memcpy(buffer, &data_size, sizeof(data_size));
return 1;
}
int elz_tonar_get_offset(el_tonar* gen, int frame)
{
if(!elz_tonar_is_init(gen)) return -1;
int offset=gen->cursor;
offset+=frame*gen->channels;;
if(offset>=gen->size) return -1;
return offset;
}
void elz_tonar_add_sample(el_tonar* gen, int frame, double value)
{
if(!elz_tonar_is_init(gen)) return;
if(gen->channels<1) return;
if(gen->channels>2) return;
if(gen->channels==1)
{
gen->data[frame]+=value;
return;
}
double angle=(gen->pan+100)*M_PI_4/100;
double left=value*cos(angle);
double right=value*sin(angle);
for(int x=0; x<gen->channels; x++)
{
int real_offset=frame+x;
if(real_offset>=gen->size) return;
if(x%2==0) gen->data[real_offset]+=left;
if(x%2!=0) gen->data[real_offset]+=right;
double peak=fabs(gen->data[real_offset]);
if(peak>gen->peak) gen->peak=peak;
}
}
double elz_tonar_db_to_amp(double db)
{
double amp=pow(10.0, db/20.0);
return amp;
}
int elz_tonar_calculate_fade_start(el_tonar* gen, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
int start=gen->fade_start;
int end=gen->fade_end;
if(start<=0) return 0;
int total=start+end;
if(ms>total) return start;
double ratio=(double) start/total;
double result=ratio*ms;
return result;
}
int elz_tonar_calculate_fade_end(el_tonar* gen, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
int start=gen->fade_start;
int end=gen->fade_end;
if(end<=0) return 0;
int total=start+end;
if(ms>total) return end;
double ratio=(double) end/total;
double result=ratio*ms;
return result;
}
double elz_tonar_apply_fade_in(int frame, int fade_in_frames, double sample)
{
if(frame>=fade_in_frames) return sample;
double fade_factor=(double) frame/fade_in_frames;
return sample*fade_factor;
}
double elz_tonar_apply_fade_out(int frame, int total_frames, int fade_out_frames, double sample)
{
int fade_out_start_frame=total_frames-fade_out_frames;
if(frame<fade_out_start_frame) return sample;
double fade_factor=(double) (total_frames-frame)/fade_out_frames;
return sample*fade_factor;
}
int elz_tonar_adjust_length(el_tonar* gen, int samples)
{
if(!elz_tonar_is_init(gen)) return 0;
int length=gen->cursor+samples;
if(length>gen->length) gen->length=length;
return 1;
}
double elz_tonar_calculate_frequency_at_frame(double start_freq, double target_freq, int current_frame, int bend_start_frame, int bend_end_frame, elz_tonar_bend_curve curve)
{
if(current_frame<bend_start_frame) return start_freq;
if(current_frame>bend_end_frame) return target_freq;
double t=(double) (current_frame-bend_start_frame)/(bend_end_frame-bend_start_frame);
if(curve==elz_tonar_bend_linear) return start_freq+(target_freq-start_freq)*t;
if(curve==elz_tonar_bend_exponential) return start_freq*pow(target_freq/start_freq, t);
return start_freq;
}
double elz_tonar_poly_blep(double t, double dt)
{
if(t<dt)
{
t/=dt;
return t+t-t*t-1.0;
}
if(t>1.0-dt)
{
t=(t-1.0)/dt;
return t*t+t+t+1.0;
}
return 0.0;
}
double elz_tonar_music_note_to_freq(int note)
{
if(note<0) return 0;
return 440.0*pow(2, (note-69)/12.0);
}
int elz_tonar_music_name_to_note(char* name, int transpose)
{
if((!name)||(!*name)) return -1;
if(!isalpha(name[0])) return -1;
int base=-1;
char letter=name[0];
char mod=name[1];
if(!mod) return -1;
char octave=name[2];
if(!octave) octave=mod;
if(!isdigit(octave)) return -1;
if(letter=='C') base=0;
if(letter=='D') base=2;
if(letter=='E') base=4;
if(letter=='F') base=5;
if(letter=='G') base=7;
if(letter=='A') base=9;
if(letter=='B') base=11;
if(mod=='#') base++;
if(mod=='b') base--;
int o=octave-48;
int note=(((o+1)*12)+base)+transpose;
if((note<0)||(note>127)) return -1;
return note;
}
int elz_tonar_music_beat_to_ms(double tempo, double beat)
{
double ms=(double) (beat*60000)/tempo;
return ms;
}
double elz_tonar_music_ms_to_beat(double tempo, int ms)
{
double beat=ms/(60000/tempo);
return beat;
}
