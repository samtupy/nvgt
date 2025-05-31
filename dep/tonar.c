#include "tonar.h"

int el_tonar_reset(el_tonar* gen)
{
if(!gen) return 0;
elz_tonar_cleanup(gen);
gen->data=NULL;
gen->cursor=0;
gen->length=0;
gen->size=0;
gen->waveform=waveform_sine;
gen->volume=0;
gen->pan=0;
gen->fade_start=8;
gen->fade_end=12;
gen->sample_rate=44100;
gen->channels=2;
gen->peak=0;
gen->begin=elz_tonar_begin;
gen->end=elz_tonar_end;
return 1;
}
int el_tonar_set_waveform(el_tonar* gen, int type)
{
if(!elz_tonar_is_init(gen)) return 0;
if(type<0) return 0;
if(type>=waveform_max) return 0;
gen->waveform=type;
return 1;
}
int el_tonar_set_volume(el_tonar* gen, double db)
{
if(!elz_tonar_is_init(gen)) return 0;
if(db>0) return 0;
if(db<-100) return 0;
gen->volume=db;
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
int el_tonar_set_edge_fades(el_tonar* gen, int start, int end)
{
if(!elz_tonar_is_init(gen)) return 0;
if(start<0) return 0;
if(end<0) return 0;
gen->fade_start=start;
gen->fade_end=end;
return 1;
}
int el_tonar_freq(el_tonar* gen, double freq, int ms)
{
if(!elz_tonar_is_init(gen)) return 0;
if(freq<20) return 0;
if(freq>20000) return 0;
if(ms<=0) return 0;
int frames=elz_tonar_ms_to_frames(gen, ms);
if(frames<=0) return 0;
int samples=frames*gen->channels;
if(!elz_tonar_manage_buffer(gen, samples)) return 0;
double amplitude=elz_tonar_db_to_amp(gen->volume);
int sample_rate=gen->sample_rate;
int fade_start=elz_tonar_calculate_fade_start(gen, ms);
int fade_end=elz_tonar_calculate_fade_end(gen, ms);
int fade_in_frames=elz_tonar_ms_to_frames(gen, fade_start);
int fade_out_frames=elz_tonar_ms_to_frames(gen, fade_end);
for(int x=0; x<frames; x++)
{
double sample=elz_tonar_generate_waveform(gen->waveform, x, freq, sample_rate, amplitude);
sample=elz_tonar_apply_fade_in(x, fade_in_frames, sample);
sample=elz_tonar_apply_fade_out(x, frames, fade_out_frames, sample);
int offset=elz_tonar_get_offset(gen, x);
elz_tonar_add_sample(gen, offset, sample);
}
return elz_tonar_adjust_length(gen, samples);
}
int el_tonar_rest(el_tonar* gen, int ms)
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
int el_tonar_output_buffer_size(el_tonar* gen)
{
if(elz_tonar_is_silent(gen)) return 0;
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
int el_tonar_output_file(el_tonar* gen, char* fn)
{
if(!elz_tonar_is_init(gen)) return 0;
if(elz_tonar_is_silent(gen)) return 1;
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
memset(data+gen->size, 0, samples-gen->size);
gen->data=data;
gen->size=samples;
return 1;
}
double elz_tonar_generate_waveform(int type, int frame, double freq, int sample_rate, double amplitude)
{
if(type==waveform_sine) return elz_tonar_generate_sine(frame, freq, sample_rate, amplitude);
if(type==waveform_triangle) return elz_tonar_generate_triangle_v2(frame, freq, sample_rate, amplitude);
if(type==waveform_square) return elz_tonar_generate_square_v2(frame, freq, sample_rate, amplitude);
if(type==waveform_saw) return elz_tonar_generate_saw_v2(frame, freq, sample_rate, amplitude);
return 0;
}
double elz_tonar_generate_sine(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double value=amplitude*sin(2.0*M_PI*freq*t);
return value;
}
double elz_tonar_generate_triangle(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double value=(2.0*amplitude/M_PI)*asin(sin(2.0*M_PI*freq*t));
return value;
}
double elz_tonar_generate_triangle_v2(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double theta=2.0*M_PI*freq*t;
double value=amplitude-(2.0*amplitude/M_PI)*fabs(fmod(theta+M_PI/2.0, 2.0*M_PI)-M_PI);
return value;
}
double elz_tonar_generate_square(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double value=amplitude*(sin(2.0*M_PI*freq*t)>=0? 1.0: -1.0);
return value;
}
double elz_tonar_generate_square_v2(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double dt=freq/sample_rate;
double phase=fmod(freq*t, 1.0);
double value=amplitude*(phase<0.5? 1.0: -1.0);
value+=amplitude*elz_tonar_poly_blep(phase, dt);
value-=amplitude*elz_tonar_poly_blep(fmod(phase+0.5, 1.0), dt);
return value;
}
double elz_tonar_generate_saw(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double value=amplitude*(2.0*(t*freq-floor(0.5+t*freq)));
return value;
}
double elz_tonar_generate_saw_v2(int frame, double freq, int sample_rate, double amplitude)
{
double t=(double) frame/sample_rate;
double dt=freq/sample_rate;
double phase=fmod(freq*t, 1.0);
double value=amplitude*(2.0*phase-1.0);
value-=amplitude*elz_tonar_poly_blep(phase, dt);
return value;
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
int length=gen->cursor;
if(length>gen->length) gen->length=length;
return 1;
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
