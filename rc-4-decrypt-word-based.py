
def swap(list, i, j):
    a = list[i]
    b = list[j]

    list[i] = b
    list[j] = a


def s_box(key):
    state = list(range(256))
    j = 0
    for i in range(256):
        s = state[i]
        j += s

        k = key[i % len(key)]
        j += k

        j &= 0xff

        # swap elements at index i and j
        swap(state, i, j)

    return state


def prga_next(self):
    # first mutate s-box
    self.i += 1
    self.i &= 0xff
    self.j += self.state[self.i]
    self.j &= 255

    swap(self.state, self.i, self.j)

    # calulate index of element to return
    index = self.state[self.i]+self.state[self.j]
    index &= 255
    return self.state[index]


def decrypt(sbox, input):
    i = 0
    j = 0
    sbox = list(bytes_to_words(sbox))
    words = bytes_to_words(input)

    for word in words:
        i += 1
        i &= (0xff >> 2)

        xorPattern = 0

        for i2 in [24, 16, 8, 0]:
            ibox = sbox[i]
            ibox = ibox >> i2
            j += ibox
            j &= 0xff

            j1 = j >> 2
            j2 = j & 0b11
            j2 *= 8

            jbox = sbox[j1]
            jbox = jbox >> j2

            swapBytes(sbox, i, i2, j1, j2)

            acc = jbox + ibox
            acc &= 0xff
            acc = acc << i2

            xorPattern += acc

        yield word ^ xorPattern


def swapBytes(l, i, i2, j, j2):
    a = l[i]
    b = l[j]

    res_a = a >> i2
    res_a &= 0xff
    # clear that byte in a
    mask = 0xff << i2
    mask = ~mask
    a &= mask

    res_b = b >> j2
    res_b &= 0xff

    a |= res_b << j2

    res_a = res_a << j2

    mask = 0xff << j2
    mask = ~mask
    b &= mask

    b |= res_a << i2

    l[i] = a
    l[j] = b


"""
consumes an iterator, converting it to chunks
"""


def chunks(n, iterarable):
    chunk = []
    for elem in iterarable:
        if len(chunk) == n:
            yield chunk
            chunk = []
        chunk.append(elem)

    if len(chunk) > 0:
        yield chunk


def fill(l, n, default):
    if len(l) >= n:
        return l
    l.append(default)
    fill(l, n, default)


def bytes_to_words(input):
    # we expect the input to be an array of bytes.
    # This implementation is supposed to treat an input word addressed.
    # therefore we first rewrite the input a little
    for c in chunks(4, input):
        # make sure chunk has exactly 4 elements
        fill(c, 4, 0)
        [a, b, c1, d] = c

        res = (a << 24) + (b << 16) + (c1 << 8) + d
        yield res


def word_to_bytes(input):
    for n in input:
        yield (n >> 24) & 0xff
        yield (n >> 16) & 0xff
        yield (n >> 8) & 0xff
        yield (n) & 0xff

# this is just used as a test function

def verify(a, b):
    a = list(a)
    b = list(b)
    if a != b:
        print("got     ", a)
        print("expected", b)
    else:
        print("checked!")

def verifySwapByte():
    cases = [
        [ [1, 2, 3, 4], 1, 2 ],
        [ [1, 2, 3, 4], 0, 2 ],
        [ [1, 2, 3, 4], 3, 2 ],
        [ [1, 2, 3, 4, 5, 6, 7, 8], 3, 2 ],
        [ [1, 2, 3, 4, 5, 6, 7, 8], 6, 1 ],
        [ [1, 2, 3, 4, 5, 6, 7, 8], 2, 7 ],
    ]

    for [l, a, b] in cases:
        bytes = list(bytes_to_words(l))
        a1 = a >> 2
        a2 = (a&3)*8
        b1 = b >> 2
        b2 = (b&3)*8
        swapBytes(bytes, a1, a2, b1, b2)
        got = list(word_to_bytes(bytes))
        swap(l, a, b)

        verify(l, got)

def run_tests():

    def to_byte(a, b):
        return int(a+b, 16)

    def to_bytes(s):
        s = list(s)
        return [to_byte(s[i-1], s[i]) for i in range(len(s)) if i & 1 == 1]

    print("     Test utility 1")
    verify(map(list, chunks(2, [0, 0, 0, 0])), [[0, 0], [0, 0]])
    verify(map(list, chunks(4, [0, 0, 0, 0])), [[0, 0, 0, 0]])
    verify(bytes_to_words([0, 0, 0, 0xff]), [0xff])

    verify(bytes_to_words([0, 0, 0x8a, 0xff]), [0x8aff])
    verify(bytes_to_words([0xff, 0, 0xff, 0xff]), [0xff00ffff])

    print("     Test swapByte")
    verifySwapByte()

    print("     Test utility 2")
    cases = ["010203040506070809", "aabbccddeeff0011"]
    for expected in map(to_bytes, cases):
        got = bytes_to_words(expected)
        got = list(word_to_bytes(got))
        s = len(expected)
        got = got[:s]

        verify(got, expected)

    def test(key, input, expected):
        key = to_bytes(key)
        input = to_bytes(input)
        expected = to_bytes(expected)

        got = list(word_to_bytes(decrypt(s_box(key), input)))

        if (got != expected):
            print("\n[test failed] expected output didnt match actual output!")
            print('got', got)
            print('expected', expected)
            return

        print("[test passed]")

    test(
        key="0102030405",
        input="00000000000000000000000000000000",
        expected="b2396305f03dc027ccc3524a0a1118a8"
    )
    test(
        key="01020304050607",
        input="00000000000000000000000000000000",
        expected="293f02d47f37c9b633f2af5285feb46b"
    )
    test(
        key="0102030405060708",
        input="00000000000000000000000000000000",
        expected="97ab8a1bf0afb96132f2f67258da15a8"
    )


run_tests()