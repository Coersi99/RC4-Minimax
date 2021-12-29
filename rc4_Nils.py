
def swap(list, i, j):
    a = list[i]
    b = list[j]

    list[i] = b
    list[j] = a


class Rc4:
    def __init__(self, key):
        self.i = 0
        self.j = 0
        self.state = list(range(256))

        self.init_state(key)



    def init_state(self, key):
        j = 0
        for i in range(256):
            s = self.state[i]
            j += s

            k = key[i % len(key)]
            j += k

            j &= 0xff

            # swap elements at index i and j
            swap(self.state, i, j)

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

    def decrypt(self, input):
        return [i ^ self.prga_next() for i in input]


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

        got = Rc4(key).decrypt(input)

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
