#!/usr/bin/env python3

# script to migrate from Chisel 1 -> Chisel 3
# usage ./chisel_migrate <src.scala> [<other_src.scala> ...]

import re
import sys

def usage():
    print(f'{sys.argv[0]} <src.scala> [<other_src.scala> ...]')
    exit(1)

if len(sys.argv) < 2:
    usage()

# helper function to match parentheses
def get_match_paren_idx(string, ref_idx):
    ref_paren = string[ref_idx]
    mtc_paren = { '(':')', ')':'(', '[':']', ']':'[', '{':'}', '}':'{' }[ref_paren]

    if ref_paren in '([{':
        next = +1
    else:
        next = -1

    i = ref_idx + next
    count = 1
    while i >= 0 and i < len(string):
        if string[i] == ref_paren:
            count = count + 1
        elif string[i] == mtc_paren:
            count = count - 1

        if count == 0:
            return i
        else:
            i = i + next

# helper function to get comma-delimited argument string range
def get_arg_slice(string, start_idx, end_idx, arg_idx):
    string = string[start_idx:end_idx]
    for i in range(len(string)):
        if string[i] in '([{':
            j = get_match_paren_idx(string, i)
            if j:
                j = j + 1
                string = string[:i] + ('.' * (j - i)) + string[j:]
    str_list = string.split(',')
    if arg_idx < len(str_list):
        arg_start_idx = sum(map(lambda x: len(x), str_list[:arg_idx])) + arg_idx
        arg_end_idx = arg_start_idx + len(str_list[arg_idx])
        return slice(arg_start_idx + start_idx, arg_end_idx + start_idx)

# helper function get beginning of function call given index of closing parenthesis
def get_func_start_idx(string, ref_idx):
    string = string[:ref_idx+1]
    for i in range(len(string)):
        if string[i] in '([{':
            j = get_match_paren_idx(string, i)
            if j:
                j = j + 1
                string = string[:i] + ('.' * (j - i)) + string[j:]
    match = re.search('[\w.]+\s*\.+$', string[:ref_idx+1])
    if match:
        return match.start()

# transpile Chisel
for src_file in sys.argv[1:]:
    with open(src_file, 'r') as src:
        code = src.readlines()

    # package Tutorial -> import chisel3._\nimport chisel3.util._
    for i in reversed(range(len(code))):
        line = code[i]
        matches = re.findall('package\s+Tutorial', line)
        if matches:
            del code[i]
            code.insert(i,   'import chisel3._\n')
            code.insert(i+1, 'import chisel3.util._\n')

    # delete import Node._ / import Literal._
    for i in reversed(range(len(code))):
        line = code[i]
        matches = re.findall('import\s+Chisel', line)
        if matches:
            del code[i]
            continue
        matches = re.findall('import\s+Node', line)
        if matches:
            del code[i]
            continue
        matches = re.findall('import\s+Literal', line)
        if matches:
            del code[i]
            continue

    # Component -> Module
    for i in range(len(code)):
        line = code[i]
        while True:
            match = re.search(r'\bComponent\b', line)
            if not match:
                break
            repl = 'Module'
            line = line[:match.start()] + repl + line[match.end():]
        code[i] = line

    # _type(INPUT[, [width=]_width]) -> Input(_type()) / Input(_type(_width.W))
    for i in range(len(code)):
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('(\w+)\s*(\()\s*INPUT.*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(2) + 1
            args_end_idx = get_match_paren_idx(line, match.start(2))
            # get individual arg string range
            arg0_slice = get_arg_slice(line, args_start_idx, args_end_idx, 0)
            arg1_slice = get_arg_slice(line, args_start_idx, args_end_idx, 1)
            # construct new expression
            if not arg1_slice:
                repl = f'Input({match[1]}())'
            else:
                match_inner = re.search('\s*width\s*=\s*(.*)', line[arg1_slice])
                if not match_inner:
                    repl = f'Input({match[1]}(({line[arg1_slice].strip()}).W))'
                else:
                    repl = f'Input({match[1]}(({match_inner[1]}).W))'
            #print('0')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # _type(_args...).asInput -> Input(_type(args...))
    # _type[_args...].asInput -> Input(_type[args...])
    # _type{_args...}.asInput -> Input(_type{args...})
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('.*([)\]}])\s*.\s*asInput', line)
            if not match:
                break
            # get expression range
            expr_end_idx = match.start(1) + 1
            expr_start_idx = get_func_start_idx(line, match.start(1))
            # construct new expression
            repl = f'Input({line[expr_start_idx:expr_end_idx].strip()})'
            #print('1')
            #print(line, end='')
            line = line[:expr_start_idx] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # _expr.asInput -> Input(_expr)
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('(\w+)\s*.\s*asInput', line)
            if not match:
                break
            # construct new expression
            repl = f'Input({match.group(1)})'
            #print('2')
            #print(line, end='')
            line = line[:match.start()] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # _type(OUTPUT[, [width=]_width]) -> Output(_type()) / Output(_type(_width.W))
    for i in range(len(code)):
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('(\w+)\s*(\()\s*OUTPUT.*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(2) + 1
            args_end_idx = get_match_paren_idx(line, match.start(2))
            # get individual arg string range
            arg0_slice = get_arg_slice(line, args_start_idx, args_end_idx, 0)
            arg1_slice = get_arg_slice(line, args_start_idx, args_end_idx, 1)
            # construct new expression
            if not arg1_slice:
                repl = f'Output({match[1]}())'
            else:
                match_inner = re.search('\s*width\s*=\s*(.*)', line[arg1_slice])
                if not match_inner:
                    repl = f'Output({match[1]}(({line[arg1_slice].strip()}).W))'
                else:
                    repl = f'Output({match[1]}(({match_inner[1]}).W))'
            #print('3')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # _type(_args...).asOutput -> Output(_type(args...))
    # _type[_args...].asOutput -> Output(_type[args...])
    # _type{_args...}.asOutput -> Output(_type{args...})
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('.*([)\]}])\s*.\s*asOutput', line)
            if not match:
                break
            # get expression range
            expr_end_idx = match.start(1) + 1
            expr_start_idx = get_func_start_idx(line, match.start(1))
            # construct new expression
            repl = f'Output({line[expr_start_idx:expr_end_idx].strip()})'
            #print('4')
            #print(line, end='')
            line = line[:expr_start_idx] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # _expr.asOutput -> Output(_expr)
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('(\w+)\s*.\s*asOutput', line)
            if not match:
                break
            # construct new expression
            repl = f'Output({match.group(1)})'
            #print('5')
            #print(line, end='')
            line = line[:match.start()] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # _type(_args...).flip -> Flipped(_type(args...))
    # _type[_args...].flip -> Flipped(_type[args...])
    # _type{_args...}.flip -> Flipped(_type{args...})
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('.*([)\]}])\s*.\s*flip', line)
            if not match:
                break
            # get expression range
            expr_end_idx = match.start(1) + 1
            expr_start_idx = get_func_start_idx(line, match.start(1))
            # construct new expression
            repl = f'Flipped({line[expr_start_idx:expr_end_idx].strip()})'
            #print('6')
            #print(line, end='')
            line = line[:expr_start_idx] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # _expr.flip -> Flipped(_expr)
    for i in range(len(code)):
        line = code[i]
        while True:
            # get beginning of line until expression
            match = re.search('(\w+)\s*.\s*flip', line)
            if not match:
                break
            # construct new expression
            repl = f'Flipped({match.group(1)})'
            #print('7')
            #print(line, end='')
            line = line[:match.start()] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # Bits -> UFix
    # NOTE: convert to UFix which will be converted to UInt later
    for i in range(len(code)):
        line = code[i]
        while True:
            match = re.search(r'\bBits\b', line)
            if not match:
                break
            repl = 'UFix'
            #print('8')
            #print(line, end='')
            line = line[:match.start()] + repl + line[match.end():]
            #print(line)
        code[i] = line

    # UFix([_value[, [width=]_width]]) -> UInt() / _value.U / _value.U(_width.W)
    # UFix(width=_width) -> UInt(_width.W)
    # UFix(_width.W) -> UInt(_width.W)
    for i in range(len(code)):
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('UFix\s*(\().*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(1) + 1
            args_end_idx = get_match_paren_idx(line, match.start(1))
            # get individual arg string range
            arg0_slice = get_arg_slice(line, args_start_idx, args_end_idx, 0)
            arg1_slice = get_arg_slice(line, args_start_idx, args_end_idx, 1)
            # construct new expression
            if not arg0_slice and not arg1_slice:
                # 0 args
                repl = 'UInt()'
            elif not arg1_slice:
                # 1 arg
                match_inner1 = re.search('width\s*=\s*(.+)', line[arg0_slice])
                match_inner2 = re.search('.+\.W\s*', line[arg0_slice])
                if not match_inner1 and not match_inner2:
                    repl = f'({line[arg0_slice].strip()}).U'
                elif not match_inner1:
                    repl = f'UInt({line[arg0_slice].strip()})'
                else:
                    repl = f'UInt(({match_inner1[1].strip()}).W)'
            else:
                # 2 args
                match_inner1 = re.search('width\s*=\s*(.+)', line[arg1_slice])
                match_inner2 = re.search('.+\.W\s*', line[arg1_slice])
                if not match_inner1 and not match_inner2:
                    repl = f'({line[arg0_slice].strip()}).U(({line[arg1_slice].strip()}).W)'
                elif match_inner2:
                    repl = f'({line[arg0_slice].strip()}).U({line[arg1_slice].strip()})'
                else:
                    repl = f'({line[arg0_slice].strip()}).U(({match_inner1[1].strip()}).W)'
            #print('9')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # Fix([_value[, [width=]_width]]) -> SInt() / _value.S / _value.S(_width.W)
    # Fix(width=_width) -> SInt(_width.W)
    # Fix(_width.W) -> SInt(_width.W)
    for i in range(len(code)):
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('Fix\s*(\().*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(1) + 1
            args_end_idx = get_match_paren_idx(line, match.start(1))
            # get individual arg string range
            arg0_slice = get_arg_slice(line, args_start_idx, args_end_idx, 0)
            arg1_slice = get_arg_slice(line, args_start_idx, args_end_idx, 1)
            # construct new expression
            if not arg0_slice and not arg1_slice:
                # 0 args
                repl = 'SInt()'
            elif not arg1_slice:
                # 1 arg
                match_inner1 = re.search('width\s*=\s*(.+)', line[arg0_slice])
                match_inner2 = re.search('.+\.W\s*', line[arg0_slice])
                if not match_inner1 and not match_inner2:
                    repl = f'({line[arg0_slice].strip()}).S'
                elif not match_inner1:
                    repl = f'SInt({line[arg0_slice].strip()})'
                else:
                    repl = f'SInt(({match_inner1[1].strip()}).W)'
            else:
                # 2 args
                match_inner1 = re.search('width\s*=\s*(.+)', line[arg1_slice])
                match_inner2 = re.search('.+\.W\s*', line[arg1_slice])
                if not match_inner1 and not match_inner2:
                    repl = f'({line[arg0_slice].strip()}).S(({line[arg1_slice].strip()}).W)'
                elif match_inner2:
                    repl = f'({line[arg0_slice].strip()}).S({line[arg1_slice].strip()})'
                else:
                    repl = f'({line[arg0_slice].strip()}).S(({match_inner1[1].strip()}).W)'
            #print('10')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # Bool(_value) -> _value.B
    for i in range(len(code)):
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('Bool\s*(\()\s*[^)].*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(1) + 1
            args_end_idx = get_match_paren_idx(line, match.start(1))
            # construct new expression
            repl = f'{line[args_start_idx:args_end_idx].strip()}.B'
            #print('11')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # Fix -> SInt
    # UFix -> UInt
    for i in range(len(code)):
        line = code[i]
        while True:
            match1 = re.search(r'\bFix\b', line)
            match2 = re.search(r'\bUFix\b', line)
            if not match1 and not match2:
                break
            elif match1:
                repl = 'SInt'
                #print('12')
                #print(line, end='')
                line = line[:match1.start()] + repl + line[match1.end():]
                #print(line)
            elif match2:
                repl = 'UInt'
                #print('13')
                #print(line, end='')
                line = line[:match2.start()] + repl + line[match2.end():]
                #print(line)
        code[i] = line

    # Vec(_count) {_type} -> Vec(_count, _type)
    # Vec(_count) {Reg(_type)} -> Reg(Vec(_count, _type))
    # Vec(_count) {Reg(resetVal=_value)} -> RegInit(VecInit(Seq.fill(_count)(_value)))
    # Vec(_count) {Reg(_type, resetVal=_value)} -> RegInit(VecInit(Seq.fill(_count)(_value)))
    for i in range(len(code)):
        # NOTE: this pattern will match itself again after transformation, so it needs to be offset
        line = code[i]
        offset = 0
        while True:
            # get expression until end of line
            pattern = re.compile('Vec\s*(\().*')
            match1 = pattern.search(line, offset)
            if not match1:
                break
            # get count string range
            count_start_idx = match1.start(1) + 1
            count_end_idx = get_match_paren_idx(line, match1.start(1))
            # get type expression until end of line
            match2 = re.search('\s*({).*', line[count_end_idx+1:])
            if not match2:
                offset = offset + (count_end_idx + 1)
                continue
            # get type string range
            type_start_idx = match2.start(1) + (count_end_idx + 1) + 1
            type_end_idx = get_match_paren_idx(line, match2.start(1) + (count_end_idx + 1))
            # check for Reg type
            match_inner = re.search('Reg\s*\(\s*(.+)\s*\)', line[type_start_idx:type_end_idx])
            if not match_inner:
                repl = f'Vec({line[count_start_idx:count_end_idx].strip()}, {line[type_start_idx:type_end_idx].strip()})'
            else:
                arg0_slice = get_arg_slice(line, match_inner.start(1) + type_start_idx, match_inner.end(1) + type_start_idx, 0)
                arg1_slice = get_arg_slice(line, match_inner.start(1) + type_start_idx, match_inner.end(1) + type_start_idx, 1)
                if not arg1_slice:
                    match_inner_inner = re.search('\s*resetVal\s*=\s*(.*)', line[arg0_slice])
                    if not match_inner_inner:
                        repl = f'Reg(Vec({line[count_start_idx:count_end_idx].strip()}, {match_inner[1].strip()}))'
                    else:
                        repl = f'RegInit(VecInit(Seq.fill({line[count_start_idx:count_end_idx].strip()})({match_inner_inner[1].strip()})))'
                else:
                    match_inner_inner = re.search('\s*resetVal\s*=\s*(.*)', line[arg1_slice])
                    repl = f'RegInit(VecInit(Seq.fill({line[count_start_idx:count_end_idx].strip()})({match_inner_inner[1].strip()})))'
            #print('14')
            #print(line, end='')
            line = line[:match1.start()] + repl + line[type_end_idx+1:]
            offset = offset + (len(line[:match1.start()]) + len(repl))
            #print(line)
        code[i] = line

    # Reg(resetVal=_value) -> RegInit(_value)
    # Reg(_type, resetVal=_value) -> RegInit(_type, _value)
    for i in range(len(code)):
        # NOTE: this pattern will match too much and needs to be offset
        line = code[i]
        offset = 0
        while True:
            # get expression until end of line
            pattern = re.compile('Reg\s*(\().*')
            match = pattern.search(line, offset)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(1) + 1
            args_end_idx = get_match_paren_idx(line, match.start(1))
            # check for non-matches
            # skip Reg(Vec(...))
            false_match = re.search('Vec\s\(', line[args_start_idx:args_end_idx])
            true_match = re.search(r'\bresetVal\b', line[args_start_idx:args_end_idx])
            if false_match or not true_match:
                offset = offset + (args_end_idx + 1)
                continue
            # get individual arg string range
            arg0_slice = get_arg_slice(line, args_start_idx, args_end_idx, 0)
            arg1_slice = get_arg_slice(line, args_start_idx, args_end_idx, 1)
            # construct new expression
            if not arg1_slice:
                match_inner = re.search('\s*resetVal\s*=\s*(.*)', line[arg0_slice])
                repl = f'RegInit({match_inner[1].strip()})'
            else:
                match_inner = re.search('\s*resetVal\s*=\s*(.*)', line[arg1_slice])
                repl = f'RegInit({line[arg0_slice].strip()}, {match_inner[1].strip()})'
            #print('15')
            #print(line, end='')
            line = line[:match.start()] + repl + line[args_end_idx+1:]
            #print(line)
        code[i] = line

    # ... Enum(_count)
    for i in range(len(code)):
        # NOTE: assume nothing else after Enum
        line = code[i]
        while True:
            # get expression until end of line
            match = re.search('Enum\s*(\().*', line)
            if not match:
                break
            # get arg list string range
            args_start_idx = match.start(1) + 1
            args_end_idx = get_match_paren_idx(line, match.start(1))
            # construct new expression
            print('16')
            print(line, end='')
            line = line[:args_end_idx+1] + '\n'
            print(line)
            break
        code[i] = line

    with open(f'{src_file}', 'w') as src:
        src.writelines(code)
