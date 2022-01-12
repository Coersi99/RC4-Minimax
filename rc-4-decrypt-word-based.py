
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
    # words are the input we expect to have on the minimax
    words = bytes_to_words(input)
    for word in words:
        index = 0
        for byteIndex in range(0, 4):
            i += 1
            i &= 0xff
            addrByte = 3-i&0b11
            addrByte8 = addrByte*8
            j += (sbox[i>>2] >> addrByte8 ) & 0xff
            j &= 0xff

            swap(sbox, i, j)

            res = sbox[i>>2]>>addrByte8 + sbox[j>>2]>>addrByte8
            res &= 0xff
            res = res << (3-byteIndex)*8

            index += res

        yield word ^ index




# consumes an iterator, converting it to chunks


def chunks(n, iterarable):
    chunk = []
    for elem in iterarable:
        if len(chunks) == n:
            yield chunks
            chunks = []
        chunks.append(elem)

    if len(chunks) > 0:
        yield chunks


def fill(l, n, default):
    if len(l) >= n:
        return l
    l.append(default)
    return fill(l, n, default)


def bytes_to_words(input):
    # we expect the input to be an array of bytes.
    # This implementation is supposed to treat an input word addressed.
    # therefore we first rewrite the input a little
    for chunk in chunks(4, input):
        # make sure chunk has exactly 4 elements
        fill(chunk, 4, 0)
        [a, b, c, d] = chunk

        yield a << 24 + b << 16 + c << 8 + d


def word_to_bytes(input):
    for n in input:
        yield (n >> 24) & 0xff
        yield (n >> 16) & 0xff
        yield (n >> 8) & 0xff
        yield (n) & 0xff

# this is just used as a test function


def run_tests():
    def to_byte(a, b):
        return int(a+b, 16)

    def to_bytes(s):
        s = list(s)
        return [to_byte(s[i-1], s[i]) for i in range(len(s)) if i & 1 == 1]

    def test(key, input, expected):
        key = to_bytes(key)
        input = to_bytes(input)
        expected = to_bytes(expected)

        got = word_to_bytes(decrypt(s_box(key), input))

        if (got != expected):
            print("[test failed] expected output didnt match actual output!")
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
