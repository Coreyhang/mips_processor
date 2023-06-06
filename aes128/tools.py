from s_box import get_sub_byte, get_rc


def sub_byte(a):
    # a should be a word
    b = 0
    for i in range(4):
        b += get_sub_byte(a & 0x000000ff) << (i * 8)
        a = a >> 8
    return b


def rot_word(a):
    # a should be a word
    b = ((a & 0x00ffffff) << 8) + (a >> 24)
    return b


def r_con(j):
    # a should be a word
    b = get_rc(j) << 24
    return b


def key_expansion128(key: list):
    assert len(key) == 16
    w = [0 for i in range(44)]
    for i in range(4):
        w[i] = (key[4*i] << 24) + (key[4*i+1] << 16) + (key[4*i+2] << 8) + key[4*i+3]
    for i in range(4, 44):
        temp = w[i-1]
        if i % 4 == 0:
            temp = sub_byte(rot_word(temp)) ^ r_con(i//4)
        w[i] = w[i-4] ^ temp
    # for i in range(44):
    #     print(i)
    #     print('{:0>8x}'.format(w[i]))


def shift_rows(a):
    pass