
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
        state[i], state[j] = state[j], state[i]

    return state


# record('A', index, i1, i2, j1, j2, loopIndex)
tableA = [['index', 'i1', 'i2', 'j1', 'j2', 'loopIndex']]


def recordA(index, i1, i2, j1, j2, loopIndex):
    tableA.append([index, i1, i2, j1, j2, loopIndex])


tableB = [['pattern']]


def recordB(pattern):
    tableB.append([pattern])


def writeCSVFile(table, filename):
    f = open(filename, "w")
    for line in table:
        f.write(';'.join(map(str, line)))

        f.write("\n")

    f.close()


# tmp_adr
# tmp_Si
# tmp_Sj
# i
# j

def decrypt(sbox, input):
    sbox = list(bytes_to_words(sbox))
    words = bytes_to_words(input)

    i = 0
    j = 0
    for word in words:
        xorPattern = 0
        # -1 here, so we include the 0
        for loopIndex in [0, 8, 16, 24]:
            # increment i, counting it clockwise with respect to sbox length
            i += 1
            i &= 0xff

            # i1 is the address part of i
            # while i2 is the byte address of i
            i1 = i >> 2
            i2 = i & 0b11
            i2 *= 8
            # i2 = 24 - i2

            ibox = sbox[i1]
            ibox = ibox >> i2

            # add sbox[i][i2] to j
            j += ibox
            j &= 0xff
            # j is verified to be correct

            # split j into the address j1 and the byte address j2
            j1 = j >> 2
            j2 = j & 0b11
            j2 *= 8

            index = sbox[j1]
            index = index >> j2

            index = index + ibox
            index &= 0xff

            # breakpoint A
            recordA(index, i1, i2, j1, j2, loopIndex)

            swapBytes(sbox, i1, i2, j1, j2)

            indexAddr = index >> 2
            ibox = sbox[indexAddr]

            index = index & 0b11
            index *= 8

            ibox >>= index
            ibox &= 0xff

            ibox <<= loopIndex
            xorPattern |= ibox

        recordB(xorPattern)

        yield word ^ xorPattern


def swapBytes(l, i1, i2, j1, j2):
    if i1 == j1:
        if i2 == j2:
            return
        bytes = l[i1]
        a = bytes >> i2
        a &= 0xff
        a = a << j2

        b = bytes >> j2
        b &= 0xff
        b = b << i2

        a = a | b

        tmp = 0xff << j2
        mask = 0xff << i2
        mask = mask | tmp
        mask = ~mask

        # clear bytes a and b in buffer
        bytes = bytes & mask

        # set bytes a and b
        bytes = bytes | a

        # write buffer
        l[i1] = bytes
        return

    a = l[i1]

    # save addressed bytes from i and j into variables
    a = a >> i2
    a &= 0xff
    a = a << j2

    b = l[j1]
    b = b >> j2
    b &= 0xff
    b = b << i2

    mask = 0xff << i2
    mask = ~mask
    word = l[i1]
    # clear byte and set it
    word = word & mask
    word = word | b
    l[i1] = word

    mask = 0xff << j2
    mask = ~mask
    word = l[j1]
    # clear byte and set it
    word = word & mask
    word = word | a
    l[j1] = word

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
    for ch in chunks(4, input):
        # make sure chunk has exactly 4 elements
        fill(ch, 4, 0)
        [a, b, c, d] = ch

        res = (d << 24) + (c << 16) + (b << 8) + a
        yield res


def word_to_bytes(input):
    for n in input:
        yield (n) & 0xff
        yield (n >> 8) & 0xff
        yield (n >> 16) & 0xff
        yield (n >> 24) & 0xff

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
        swapBytes(lnew, i1, i2, j1, j2)
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
        [0x03020104, 0x01020304], True
    )


def readBinaryWords(filename):
    # content byte cased
    content = list(open(filename, "rb").read())
    # transform to be word based
    return list(bytes_to_words(content))


def presetSBox():
    key = bytearray(open("./key", "rb").read())
    return s_box(key)

# run decryption on actual data


def runActualData():
    input = readBinaryWords("./data_encrypted")
    # call list on this to drain the iterator
    bytes = bytearray(word_to_bytes(decrypt(presetSBox(), input)))
    bytes = bytes[:-3]
    open("output.jpeg", "wb").write(bytes)
    writeCSVFile(tableA, "breakpoints-a.csv")
    writeCSVFile(tableB, "breakpoints-b.csv")

# runActualData()

def run_tests():
    print("     Test sbox")
    expected = bytearray(open("./sBox_shuffled.txt", "rb").read())
    verify(expected, presetSBox(), True)

    def to_byte(a, b):
        return int(a+b, 16)

    def to_bytes(s):
        s = list(s)
        return [to_byte(s[i-1], s[i]) for i in range(len(s)) if i & 1 == 1]

    print("     Test chunks")
    verify(map(list, chunks(2, [0, 0, 0, 0])), [[0, 0], [0, 0]])
    verify(map(list, chunks(4, [0, 0, 0, 0])), [[0, 0, 0, 0]])
    print("     Test bytes_to_words")
    verify(bytes_to_words([0, 0, 0, 0xff]), [0xff000000])
    verify(bytes_to_words([0, 1, 2, 3]), [0x03020100])
    verify(bytes_to_words([0, 1, 2, 3, 4, 5, 6, 7]), [0x03020100, 0x07060504])
    verify(bytes_to_words([0, 0, 0x8a, 0xff]), [0xff8a0000])
    verify(bytes_to_words([0xff, 0, 0xff, 0xff]), [0xffff00ff])
    print("     Test words_to_bytes")
    verify(word_to_bytes([0x01020304, 0x05060708, 0x0000090A]), [
           4, 3, 2, 1, 8, 7, 6, 5, 10, 9, 0, 0])
    verify(word_to_bytes([0x04030201, 0x08070605, 0x0c0b0a09]), [
           1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

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
