
from re import A


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
    self.j &= 0xff

    swap(self.state, self.i, self.j)

    # calulate index of element to return
    index = self.state[self.i]+self.state[self.j]
    index &= 255

    # algorithm verified until here

    return self.state[index]


def decrypt(sbox, input):
    i = 0
    j = 0
    sbox = list(bytes_to_words(sbox))
    words = bytes_to_words(input)


    wordIndex = 0
    for word in words:
        xorPattern = 0
        # -1 here, so we include the 0
        for loopIndex in range(0, 4):
            i += 1
            i &= 0xff

            # i1 is the address part of i
            # while i2 is the byte address of i
            i1 = i >> 2
            i2 = i & 0b11
            i2 *= 8
            i2 = 24 - i2

            ibox = sbox[i1]
            ibox = ibox >> i2
            # i box is verified to be correct

            # add sbox[i][i2] to j
            # self.j += self.state[self.i]
            # self.j &= 0xff
            j += ibox
            j &= 0xff
            # j is verified to be correct

            # split j into the address j1 and the byte address j2
            j1 = j >> 2
            j2 = j & 0b11
            j2 *= 8
            j2 = 24 - j2

            jbox = sbox[j1]
            jbox = jbox >> j2
            # (jbox & 0xff) is verified to be correct

            # swap(self.state, self.i, self.j)
            swapBytes(sbox, i1, i2, j1, j2)

            # calulate index of element to return
            # index = ibox + jbox
            # index &= 255

            index = jbox + ibox
            index &= 0xff
            # index is verified to be right

            # move the xorbyte to the appropriate position in the index
            # xorbyte = xorbyte << i2

            # xorPattern |= xorbyte

        yield word ^ xorPattern


def swapBytes(l, i, i2, j, j2):
    if i == j:
        if i2 == j2:
            return
        bytes = l[i]
        a = bytes >> i2
        a &= 0xff
        a = a << j2

        b = bytes >> j2
        b &= 0xff
        b = b << i2

        a = a | b

        mask = 0xff << i2
        tmp = 0xff << j2
        mask = mask | tmp
        mask = ~mask

        # clear bytes a and b in buffer
        bytes = bytes & mask

        # set bytes a and b
        bytes = bytes | a

        # write buffer
        l[i] = bytes
        return

    a = l[i]
    b = l[j]

    # save addressed bytes from i and j into variables
    byte_a = a >> i2
    byte_a &= 0xff

    byte_b = b >> j2
    byte_b &= 0xff

    # clear the byte at address i,i2 in a
    mask = 0xff << i2
    mask = ~mask
    a &= mask

    # clear the byte at address j,j2 in b
    mask = 0xff << j2
    mask = ~mask
    b &= mask

    # move the bytes at the appropriate positions
    byte_a <<= j2
    byte_b <<= i2

    # apply the bitpatterns to a and b
    a |= byte_b
    b |= byte_a

    # write back result
    l[i] = a
    l[j] = b


# consumes an iterator, converting it to chunks
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


def verify(a, b, hexPrint=False):
    a = list(a)
    b = list(b)
    if a != b:
        if hexPrint:
            a = list(map(hex, a))
            b = list(map(hex, b))
        print("got     ", a)
        print("expected", b)
    else:
        print("checked!")


def verifySwapByte():
    # swap bytes cloning
    # also make the indexes of i2 and j2 reverse ordered
    def swapBytesC(l, i1, i2, j1, j2):
        # clone list
        lnew = list(l)
        swapBytes(lnew, i1, 24-i2, j1, 24-j2)
        return lnew

    # direct testing

    # same subslice
    verify(
        swapBytesC([0x01020304], 0, 0, 0, 3*8),
        [0x04020301],
        True
    )
    verify(
        swapBytesC([0x01020304, 0x01020304], 0, 0, 0, 3*8),
        [0x04020301, 0x01020304], True
    )
    verify(
        swapBytesC([0x01020304, 0x01020304], 0, 1*8, 0, 3*8),
        [0x01040302, 0x01020304], True
    )
    verify(
        swapBytesC([0xf1020304, 0x01020304], 0, 1*8, 0, 3*8),
        [0xf1040302, 0x01020304], True
    )

    # i != j
    verify(
        swapBytesC([0x01020304, 0x05060708], 0, 0, 1, 0),
        [0x05020304, 0x01060708], True
    )
    verify(
        swapBytesC([0x01020304, 0x05060708], 0, 3*8, 1, 2*8),
        [0x01020307, 0x05060408], True
    )

    # more automatic solution
    cases = [
        [[1, 2, 3, 4], 1, 2],
        [[1, 2, 3, 4], 0, 2],
        [[1, 2, 3, 4], 3, 2],
        [[1, 2, 3, 4, 5, 6, 7, 8], 3, 2],
        [[1, 2, 3, 4, 5, 6, 7, 8], 6, 1],
        [[1, 2, 3, 4, 5, 6, 7, 8], 2, 7],
    ]

    for [l, a, b] in cases:
        bytes = list(bytes_to_words(l))
        a1 = a >> 2
        a2 = 24- (a & 3)*8
        b1 = b >> 2
        b2 = 24- (b & 3)*8
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

    print("     Test chunks")
    verify(map(list, chunks(2, [0, 0, 0, 0])), [[0, 0], [0, 0]])
    verify(map(list, chunks(4, [0, 0, 0, 0])), [[0, 0, 0, 0]])
    print("     Test bytes_to_words")
    verify(bytes_to_words([0, 0, 0, 0xff]), [0xff])
    verify(bytes_to_words([0, 0, 0x8a, 0xff]), [0x8aff])
    verify(bytes_to_words([0xff, 0, 0xff, 0xff]), [0xff00ffff])
    print("     Test words_to_bytes")
    verify(word_to_bytes([0x01020304, 0x05060708, 0x0000090A]), [
           1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 9, 10])

    print("     Test swapByte")
    verifySwapByte()

    print("     Test implementation")
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

    print("     Test 1")
    test(
        key="0102030405",
        input="00000000000000000000000000000000",
        expected="b2396305f03dc027ccc3524a0a1118a8"
    )

    print("     Test 2")
    test(
        key="01020304050607",
        input="00000000000000000000000000000000",
        expected="293f02d47f37c9b633f2af5285feb46b"
    )

    print("     Test 3")
    test(
        key="0102030405060708",
        input="00000000000000000000000000000000",
        expected="97ab8a1bf0afb96132f2f67258da15a8"
    )


run_tests()
