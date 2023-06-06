
import pandas as pd

file_name = './key_expansion.xlsx'
df = pd.read_excel(file_name, usecols=[1, 2, 3, 4, 5])
data = df.values
i_cache = []
op = {
    'lw':   '100011',
    'sw':   '101011',
    'beq':  '000100',
    'bne':  '000101',
    'j':    '000010',
    'jal':  '000011',
    'addi': '001000',
    'addiu':'001001',
    'andi': '001100',
    'ori':  '001101',
    'xori': '001110',
    'lui':  '001111'
}
function = {
    'jr':   '001000',
    'add':  '100000',
    'sub':  '100010',
    'and':  '100100',
    'xor':  '100110',
    'or':   '100101',
    'slt':  '101010',
    'sll':  '000000',
    'srl':  '000010'
}

for i in range(1, len(data)):
    data_inst = data[i]
    inst = ''
    if data_inst[0] in ['lw', 'sw']:
        inst = op[data_inst[0]] + \
               '{:0>5b}{:0>5b}{:0>16b}'.format(int(data_inst[1]),
                                               int(data_inst[2]),
                                               int(data_inst[3]))
    elif data_inst[0] in ['add', 'sub', 'and', 'or', 'xor', 'slt', 'sll',
                          'srl', 'jr']:
        inst = '000000{:0>5b}{:0>5b}{:0>5b}'.format(int(data_inst[1]),
                                                    int(data_inst[2]),
                                                    int(data_inst[3]))
        if data_inst[0] in ['sll', 'srl']:
            inst += '{:0>5b}'.format(int(data_inst[4]))
        else:
            inst += '00000'
        inst += function[data_inst[0]]
    elif data_inst[0] in ['beq', 'bne', 'j', 'jal', 'addi', 'addiu', 'andi',
                          'ori', 'xori', 'lui']:
        inst = op[data_inst[0]]
        if data_inst[0] in ['j', 'jal']:
            inst += '{:0>26b}'.format(int(data_inst[1]))
        else:
            inst += '{:0>5b}{:0>5b}{:0>16b}'.format(int(data_inst[1]),
                                                    int(data_inst[2]),
                                                    int(data_inst[3]))
    elif data_inst[0] == 'nop':
        inst = '{:0>32b}'.format(0)
    else:
        raise ValueError(' wrong instruction')
    i_cache.append(inst)

with open('./icache.v', 'w') as f:
    f.writelines(['// i cache\n', 'module icache\n',
                  '#(parameter addr_width = 9)\n',
                  '(\n', '\tinput\t\t\t\t\t\tnrst,\n',
                  '\tinput\t[addr_width-1:0]\tinstruction_addr,\n',
                  '\toutput\t[31:0]\t\t\t\tinstruction_data\n', ');\n',
                  '\treg [31:0] IRAM[2**addr_width-1:0];\n',
                  '\tassign instruction_data = IRAM[instruction_addr];\n',
                  '\talways @(negedge nrst) begin\n'])
    for i in range(len(i_cache)):
        assert len(i_cache[i]) == 32
        f.write('\t\tIRAM[{:d}\t] = 32\'h{:0>8x};\n'.format(i, int(i_cache[i],
                                                                   2)))
    f.writelines(['\tend\n', 'endmodule\n'])
