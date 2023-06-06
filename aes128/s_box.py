# with open('./s_box.txt', 'w') as f2:
#     with open('./aes_sbox.txt', 'r') as f1:
#         s_list = f1.readlines()
#         for s in s_list:
#             f2.write('\'' + s[0:2] + '\': ' + '0x' + s[4:6] + ',\n')


rc = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36]
s_box = {
    '00': 0x63,
    '01': 0x7c,
    '02': 0x77,
    '03': 0x7b,
    '04': 0xf2,
    '05': 0x6b,
    '06': 0x6f,
    '07': 0xc5,
    '08': 0x30,
    '09': 0x01,
    '0a': 0x67,
    '0b': 0x2b,
    '0c': 0xfe,
    '0d': 0xd7,
    '0e': 0xab,
    '0f': 0x76,
    '10': 0xca,
    '11': 0x82,
    '12': 0xc9,
    '13': 0x7d,
    '14': 0xfa,
    '15': 0x59,
    '16': 0x47,
    '17': 0xf0,
    '18': 0xad,
    '19': 0xd4,
    '1a': 0xa2,
    '1b': 0xaf,
    '1c': 0x9c,
    '1d': 0xa4,
    '1e': 0x72,
    '1f': 0xc0,
    '20': 0xb7,
    '21': 0xfd,
    '22': 0x93,
    '23': 0x26,
    '24': 0x36,
    '25': 0x3f,
    '26': 0xf7,
    '27': 0xcc,
    '28': 0x34,
    '29': 0xa5,
    '2a': 0xe5,
    '2b': 0xf1,
    '2c': 0x71,
    '2d': 0xd8,
    '2e': 0x31,
    '2f': 0x15,
    '30': 0x04,
    '31': 0xc7,
    '32': 0x23,
    '33': 0xc3,
    '34': 0x18,
    '35': 0x96,
    '36': 0x05,
    '37': 0x9a,
    '38': 0x07,
    '39': 0x12,
    '3a': 0x80,
    '3b': 0xe2,
    '3c': 0xeb,
    '3d': 0x27,
    '3e': 0xb2,
    '3f': 0x75,
    '40': 0x09,
    '41': 0x83,
    '42': 0x2c,
    '43': 0x1a,
    '44': 0x1b,
    '45': 0x6e,
    '46': 0x5a,
    '47': 0xa0,
    '48': 0x52,
    '49': 0x3b,
    '4a': 0xd6,
    '4b': 0xb3,
    '4c': 0x29,
    '4d': 0xe3,
    '4e': 0x2f,
    '4f': 0x84,
    '50': 0x53,
    '51': 0xd1,
    '52': 0x00,
    '53': 0xed,
    '54': 0x20,
    '55': 0xfc,
    '56': 0xb1,
    '57': 0x5b,
    '58': 0x6a,
    '59': 0xcb,
    '5a': 0xbe,
    '5b': 0x39,
    '5c': 0x4a,
    '5d': 0x4c,
    '5e': 0x58,
    '5f': 0xcf,
    '60': 0xd0,
    '61': 0xef,
    '62': 0xaa,
    '63': 0xfb,
    '64': 0x43,
    '65': 0x4d,
    '66': 0x33,
    '67': 0x85,
    '68': 0x45,
    '69': 0xf9,
    '6a': 0x02,
    '6b': 0x7f,
    '6c': 0x50,
    '6d': 0x3c,
    '6e': 0x9f,
    '6f': 0xa8,
    '70': 0x51,
    '71': 0xa3,
    '72': 0x40,
    '73': 0x8f,
    '74': 0x92,
    '75': 0x9d,
    '76': 0x38,
    '77': 0xf5,
    '78': 0xbc,
    '79': 0xb6,
    '7a': 0xda,
    '7b': 0x21,
    '7c': 0x10,
    '7d': 0xff,
    '7e': 0xf3,
    '7f': 0xd2,
    '80': 0xcd,
    '81': 0x0c,
    '82': 0x13,
    '83': 0xec,
    '84': 0x5f,
    '85': 0x97,
    '86': 0x44,
    '87': 0x17,
    '88': 0xc4,
    '89': 0xa7,
    '8a': 0x7e,
    '8b': 0x3d,
    '8c': 0x64,
    '8d': 0x5d,
    '8e': 0x19,
    '8f': 0x73,
    '90': 0x60,
    '91': 0x81,
    '92': 0x4f,
    '93': 0xdc,
    '94': 0x22,
    '95': 0x2a,
    '96': 0x90,
    '97': 0x88,
    '98': 0x46,
    '99': 0xee,
    '9a': 0xb8,
    '9b': 0x14,
    '9c': 0xde,
    '9d': 0x5e,
    '9e': 0x0b,
    '9f': 0xdb,
    'a0': 0xe0,
    'a1': 0x32,
    'a2': 0x3a,
    'a3': 0x0a,
    'a4': 0x49,
    'a5': 0x06,
    'a6': 0x24,
    'a7': 0x5c,
    'a8': 0xc2,
    'a9': 0xd3,
    'aa': 0xac,
    'ab': 0x62,
    'ac': 0x91,
    'ad': 0x95,
    'ae': 0xe4,
    'af': 0x79,
    'b0': 0xe7,
    'b1': 0xc8,
    'b2': 0x37,
    'b3': 0x6d,
    'b4': 0x8d,
    'b5': 0xd5,
    'b6': 0x4e,
    'b7': 0xa9,
    'b8': 0x6c,
    'b9': 0x56,
    'ba': 0xf4,
    'bb': 0xea,
    'bc': 0x65,
    'bd': 0x7a,
    'be': 0xae,
    'bf': 0x08,
    'c0': 0xba,
    'c1': 0x78,
    'c2': 0x25,
    'c3': 0x2e,
    'c4': 0x1c,
    'c5': 0xa6,
    'c6': 0xb4,
    'c7': 0xc6,
    'c8': 0xe8,
    'c9': 0xdd,
    'ca': 0x74,
    'cb': 0x1f,
    'cc': 0x4b,
    'cd': 0xbd,
    'ce': 0x8b,
    'cf': 0x8a,
    'd0': 0x70,
    'd1': 0x3e,
    'd2': 0xb5,
    'd3': 0x66,
    'd4': 0x48,
    'd5': 0x03,
    'd6': 0xf6,
    'd7': 0x0e,
    'd8': 0x61,
    'd9': 0x35,
    'da': 0x57,
    'db': 0xb9,
    'dc': 0x86,
    'dd': 0xc1,
    'de': 0x1d,
    'df': 0x9e,
    'e0': 0xe1,
    'e1': 0xf8,
    'e2': 0x98,
    'e3': 0x11,
    'e4': 0x69,
    'e5': 0xd9,
    'e6': 0x8e,
    'e7': 0x94,
    'e8': 0x9b,
    'e9': 0x1e,
    'ea': 0x87,
    'eb': 0xe9,
    'ec': 0xce,
    'ed': 0x55,
    'ee': 0x28,
    'ef': 0xdf,
    'f0': 0x8c,
    'f1': 0xa1,
    'f2': 0x89,
    'f3': 0x0d,
    'f4': 0xbf,
    'f5': 0xe6,
    'f6': 0x42,
    'f7': 0x68,
    'f8': 0x41,
    'f9': 0x99,
    'fa': 0x2d,
    'fb': 0x0f,
    'fc': 0xb0,
    'fd': 0x54,
    'fe': 0xbb,
    'ff': 0x16
}


def get_rc(j):
    assert(0 < j < 11)
    return rc[j-1]


def get_sub_byte(a):
    assert (0 <= a <= 255)
    return s_box['{:0>2x}'.format(a)]