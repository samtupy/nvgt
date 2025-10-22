#!/usr/bin/env python3
# Generates C++ timezone map from tzdata binary files

import os
import sys
import struct
from datetime import datetime
from textwrap import dedent

try:
    import tzdata
    print(f"tzdata version {tzdata.__version__} detected")
except ImportError:
    print("ERROR: tzdata not installed on your system.")
    print("To use this script, install using: pip install tzdata")
    sys.exit(1)

TZDATA_DIR = os.path.join(os.path.dirname(tzdata.__file__), 'zoneinfo')

if not os.path.exists(TZDATA_DIR):
    print(f"ERROR: zoneinfo directory not found at {TZDATA_DIR}")
    print("Try reinstalling: pip install --force-reinstall tzdata")
    sys.exit(1)


def read_tzfile_header(data):
    # Parse tzfile header (IANA format)

    if len(data) < 44:
        return None
    
    magic = data[0:4]
    if magic != b'TZif':
        return None
    
    version = data[4:5]
    counts = struct.unpack('>6i', data[20:44])
    
    return {
        'version': version,
        'tzh_timecnt': counts[3],
        'tzh_typecnt': counts[4],
        'tzh_charcnt': counts[5],
    }

def read_tzfile_transitions(data, header):
    # Extract timezone transitions from tzfile

    if not header:
        return None
    
    version = header['version']
    
    if version in [b'2', b'3']:
        timecnt = header['tzh_timecnt']
        typecnt = header['tzh_typecnt']
        charcnt = header['tzh_charcnt']
        
        try:
            tzif2_pos = -1
            if version == b'2':
                first = data.find(b'TZif2')
                if first != -1:
                    tzif2_pos = data.find(b'TZif2', first + len(b'TZif2'))
            elif version == b'3':
                first = data.find(b'TZif3')
                if first != -1:
                    tzif2_pos = data.find(b'TZif3', first + len(b'TZif3'))
            
            if tzif2_pos == -1:
                tzif2_pos = data.find(b'TZif2', 5)
            if tzif2_pos == -1:
                tzif2_pos = data.find(b'TZif3', 5)
            
            if tzif2_pos != -1:
                v2_header_data = data[tzif2_pos:tzif2_pos+44]
                if len(v2_header_data) == 44:
                    v2_counts = struct.unpack('>6i', v2_header_data[20:44])
                    timecnt = v2_counts[3]
                    typecnt = v2_counts[4]
                    charcnt = v2_counts[5]
                    
                    offset = tzif2_pos + 44
                    
                    times = []
                    for i in range(timecnt):
                        if offset + 8 <= len(data):
                            time_val = struct.unpack('>q', data[offset:offset+8])[0]
                            times.append(time_val)
                            offset += 8
                    
                    type_indices = []
                    for i in range(timecnt):
                        if offset + 1 <= len(data):
                            type_indices.append(data[offset])
                            offset += 1
                    
                    ttinfos = []
                    for i in range(typecnt):
                        if offset + 6 <= len(data):
                            gmtoff = struct.unpack('>i', data[offset:offset+4])[0]
                            isdst = data[offset+4]
                            abbrind = data[offset+5]
                            ttinfos.append({
                                'gmtoff': gmtoff,
                                'isdst': isdst,
                                'abbrind': abbrind
                            })
                            offset += 6
                    
                    return {
                        'times': times,
                        'type_indices': type_indices,
                        'ttinfos': ttinfos
                    }
        except Exception as e:
            pass
    
    return None

def get_standard_offset_from_tzfile(filepath):
    try:
        with open(filepath, 'rb') as f:
            data = f.read()

        header = read_tzfile_header(data)
        if not header:
            return None
        
        transitions = read_tzfile_transitions(data, header)
        if not transitions or not transitions['ttinfos']:
            return None
        
        ttinfos = transitions['ttinfos']
        type_indices = transitions.get('type_indices', [])
        times = transitions.get('times', [])

        latest_standard = None

        if times and type_indices:
            for _, type_index in sorted(zip(times, type_indices)):
                if 0 <= type_index < len(ttinfos):
                    info = ttinfos[type_index]
                    if info['isdst'] == 0:
                        latest_standard = info['gmtoff']
        else:
            for type_index in type_indices:
                if 0 <= type_index < len(ttinfos):
                    info = ttinfos[type_index]
                    if info['isdst'] == 0:
                        latest_standard = info['gmtoff']

        if latest_standard is not None:
            return latest_standard

        for info in reversed(ttinfos):
            if info['isdst'] == 0:
                return info['gmtoff']
        
        return None
        
    except Exception as e:
        return None

def scan_tzdata_directory(tzdata_path):
    
    timezones = []
    failed = []
    
    regions = ['Africa', 'America', 'Antarctica', 'Asia', 'Atlantic', 'Australia', 'Europe', 'Indian', 'Pacific']
    
    total_processed = 0
    
    for region in regions:
        region_path = os.path.join(tzdata_path, region)
        if not os.path.exists(region_path):
            continue
        
        for root, dirs, files in os.walk(region_path):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d != '__pycache__']
            for filename in files:
                if (filename.startswith('.')
                        or filename in {'__pycache__', '__init__.py'}
                        or filename.endswith(('.py', '.pyc'))):
                    continue
                
                filepath = os.path.join(root, filename)
                rel_path = os.path.relpath(filepath, tzdata_path)
                timezone_name = rel_path.replace(os.sep, '/')
                
                offset = get_standard_offset_from_tzfile(filepath)
                
                if offset is not None:
                    timezones.append((timezone_name, offset))
                    total_processed += 1
                else:
                    failed.append(timezone_name)
    
    for filename in ['UTC', 'GMT', 'UCT', 'Universal', 'Zulu']:
        filepath = os.path.join(tzdata_path, filename)
        if os.path.exists(filepath):
            offset = get_standard_offset_from_tzfile(filepath)
            if offset is not None:
                timezones.append((filename, offset))
    
    print(f"Processed: {len(timezones)} timezones")
    if failed:
        print(f"Failed: {len(failed)} timezones")
    
    return timezones

def organize_by_region(timezone_list):
    regions = {
        'Base': [],
        'Africa': [],
        'America': [],
        'Antarctica': [],
        'Asia': [],
        'Atlantic': [],
        'Australia': [],
        'Europe': [],
        'Indian': [],
        'Pacific': []
    }
    
    for tz_name, offset in timezone_list:
        if tz_name in ['UTC', 'GMT', 'UCT', 'Universal', 'Zulu']:
            regions['Base'].append((tz_name, offset))
        elif tz_name.startswith('Africa/'):
            regions['Africa'].append((tz_name, offset))
        elif tz_name.startswith('America/'):
            regions['America'].append((tz_name, offset))
        elif tz_name.startswith('Antarctica/'):
            regions['Antarctica'].append((tz_name, offset))
        elif tz_name.startswith('Asia/'):
            regions['Asia'].append((tz_name, offset))
        elif tz_name.startswith('Atlantic/'):
            regions['Atlantic'].append((tz_name, offset))
        elif tz_name.startswith('Australia/'):
            regions['Australia'].append((tz_name, offset))
        elif tz_name.startswith('Europe/'):
            regions['Europe'].append((tz_name, offset))
        elif tz_name.startswith('Indian/'):
            regions['Indian'].append((tz_name, offset))
        elif tz_name.startswith('Pacific/'):
            regions['Pacific'].append((tz_name, offset))
    
    for region in regions:
        regions[region].sort()
    
    return regions

def generate_cpp_code(timezone_regions):
    header = dedent(f"""\
        // Auto-generated timezone table from IANA tzdata
        // Generated: {datetime.now().isoformat()}
        // Source: tzdata binary files (IANA tzfile format) from Python Path

        // IANA timezone identifiers with standard UTC offsets (seconds)
        static std::unordered_map<std::string, int> timezone_map = {{
    """)

    entries = []
    total_count = 0

    for region_name, timezones in timezone_regions.items():
        if not timezones:
            continue
        entries.append(("comment", region_name))
        for tz_name, offset in timezones:
            entries.append(("entry", tz_name, offset))
            total_count += 1

    last_entry_index = max((idx for idx, item in enumerate(entries) if item[0] == "entry"), default=-1)

    lines = [header.rstrip()]

    for idx, item in enumerate(entries):
        if item[0] == "comment":
            lines.append(f"\t// {item[1]}")
        else:
            tz_name, offset = item[1], item[2]
            comma = "" if idx == last_entry_index else ","
            lines.append(f'\t{{"{tz_name}", {offset}}}{comma}')

    lines.append("};")

    return "\n".join(lines), total_count

def main():
    print("NVGT Timezone Table Generator (IANA tzdata)")
    print()
    
    timezones = scan_tzdata_directory(TZDATA_DIR)
    
    if not timezones:
        print("ERROR: No timezones found")
        sys.exit(1)
    
    timezone_regions = organize_by_region(timezones)
    
    cpp_code, total_count = generate_cpp_code(timezone_regions)
    
    output_file = 'generated_timezone_table_tzdata.cpp'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(cpp_code)
    
    print(f"{total_count} timezones written to {output_file}")
    
if __name__ == "__main__":
    main()