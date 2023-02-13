#!python3
## weed_volume_list_human_many_vals.py
## bash 'echo -e "volume.list\nexit\n" | weed shell 2>&1 | python3 weed_volume_list_human_many_vals.py ;'
## By: Ctrl-S, 2021-06-18 - 2021-09-29.
##
import humanize
import re
import fileinput
import datetime



# Have to be defined before conversions
def convtime(epochsecs):
    """Turn epoch style to human friendly"""
    t = datetime.datetime.fromtimestamp(int(epochsecs))
    s = t.strftime('%Y-%m-%d %H:%M:%S')
    return s


CONVERSIONS = [
    {
        'pfx': 'size:',
        'cfunc': humanize.naturalsize, # Number passed as first arg
        'extaargs': {'binary': True} # Passed after number
    },
    {
        'pfx': 'deleted_bytes:',
        'cfunc': humanize.naturalsize, # Number passed as first arg
        'extaargs':{'binary': True} # Passed after number
    },
    {
        'pfx': 'deleted_byte_count:',
        'cfunc': humanize.naturalsize, # Number passed as first arg
        'extaargs': {'binary': True} # Passed after number
    },
    {
        'pfx': 'file_count:',
        'cfunc': humanize.scientific, # Number passed as first arg
        'extaargs': {} # Passed after number
    },
    {
        'pfx': 'deleted_file:',
        'cfunc': humanize.scientific, # Number passed as first arg
        'extaargs': {} # Passed after number
    },
    {
        'pfx': 'modified_at_second:',
        'npfx': 'mod_at:',
        'cfunc': convtime, # Number passed as first arg
        'extaargs': {} # Passed after number
    },
]


with fileinput.input() as f:
    for line in f:
        # print(f'input: line={line!r}')
        if line[0] == '>':
            line = line[1:]
        line = line.rstrip()
        # print(f'stripped: line={line!r}')
        if len(line) == 0:
            # print(f'Skipping empty line')
            continue
        for conv in CONVERSIONS: # For each type of value
            pfx = conv['pfx']
            cfunc = conv['cfunc']
            extaargs = conv['extaargs']
            try: npfx = conv['npfx']
            except KeyError: npfx = None
            # print(f'conv={conv!r}')
            # Identify values of this type
            pre_repl_pat = f'{pfx}(\d+)'
            occurances = re.findall(pre_repl_pat, line)
            # print(f'occurances={occurances!r}')
            for val in occurances: # For each occurance
                # Convert to human-friendly
                hval = cfunc(val, **extaargs)
                # print(f'val={val!r}, hval={hval!r}')
                # Swap human-friendly value where the previous one was.
                repl_pat = f'{pfx}{val}' # The whole match.
                if npfx:
                    repl_val = f'{npfx}{hval}'
                else:
                    repl_val = f'{pfx}{hval}'
                line = re.sub(repl_pat, repl_val, line)
        # print(f'output: line={line!r}')
        print(line,)








# BYTE_VALUE_PREFIXES = [
#     'size:',
#     'deleted_bytes:',
#     'deleted_byte_count:'
# ]

# with fileinput.input() as f:
#     for line in f:
#         # print(f'input: line={line!r}')
#         if line[0] == '>':
#             line = line[1:]
#         line = line.rstrip()
#         # print(f'stripped: line={line!r}')
#         if len(line) == 0:
#             # print(f'Skipping empty line')
#             continue
#         for pfx in BYTE_VALUE_PREFIXES: # For each type of value
#             # print(f'pfx={pfx!r}')
#             # Identify values of this type
#             pre_repl_pat = f'{pfx}(\d+)'
#             occurances = re.findall(pre_repl_pat, line)
#             # print(f'occurances={occurances!r}')
#             for bval in occurances: # For each occurance
#                 # Convert to human-friendly
#                 hval = humanize.naturalsize(bval, binary=True)
#                 # Swap human-friendly value where the previous one was.
#                 repl_pat = f'{pfx}{bval}' # The whole match.
#                 repl_val = f'{pfx}{hval}'
#                 line = re.sub(repl_pat, repl_val, line)
#         # print(f'output: line={line!r}')
#         print(line,)
