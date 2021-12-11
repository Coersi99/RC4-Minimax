
def swap(list, i, j):
    a = list[i]
    b = list[j]

    list[i] = b
    list[j] = a


class Rc4:
    i = 0
    j = 0
    state = list(range(256))

    def init_state(self, key):
        j = 0
        for i in range(256):
            s = self.state[i]
            k = key[i % len(key)]

            j += s+k 
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