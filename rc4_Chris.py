import codecs

MOD = 256

def KSA(key):
    key_length = len(key)
    # create the array "S"
    S = list(range(MOD))  # [0,1,2, ... , 255]
    j = 0
    for i in range(MOD):
        j = (j + S[i] + key[i % key_length]) % MOD
        S[i], S[j] = S[j], S[i]  # swap values

    return S


def PRGA(S):
    i = 0
    j = 0
    while True:
        i = (i + 1) % MOD
        j = (j + S[i]) % MOD

        S[i], S[j] = S[j], S[i]  # swap values
        K = S[(S[i] + S[j]) % MOD]
        yield K         


def get_keystream(key):
    S = KSA(key)
    return PRGA(S)


def encrypt_logic(key, text):
    key = [c for c in key]
    keystream = get_keystream(key)

    res = []
    for c in text:
        val = ("%02X" % (c ^ next(keystream)))  # XOR and taking hex
        res.append(val)
    return ''.join(res)


def encrypt(key, plaintext):
    plaintext = [ord(c) for c in plaintext]
    return encrypt_logic(key, plaintext)


def decrypt(key, ciphertext):
    res = encrypt_logic(key, ciphertext)
    return codecs.decode(res, 'hex_codec')   # String -> Bytes


def main():  
    
    file1 = open("sBox_swap_test_key", "rb")
    test_key = file1.read()
    test_key = [c for c in test_key]      # b'\x01\x0e\x05\xa6' -> [1, 14, 5, 166]
    print("Test-Key: ", test_key, "\n")
    print("Permutierte S-Box mit Test-Key: ", KSA(test_key), "\n")
    file1.close()

    print("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ \n" )

    file2 = open("sBox_swap_test", "rb")
    testBox = file2.read()
    testBox = [c for c in testBox]
    print("Vergleichsbox: ", testBox, "\n")
    file2.close()

    print("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ \n" )

    cipherfile = open("data_encrypted", "rb")
    ciphertext = cipherfile.read()
    print(ciphertext)
    ciphertext = [c for c in ciphertext]
    print(ciphertext)

    #keyfile = open("key", "rb")
    #key = keyfile.read()
    #print(key)

    #decrypted = decrypt(key, ciphertext)
    #print('Plaintext:', decrypted)
    
    #Enable this to write bytes into file named "result.txt"
    #result = open("result.txt", "wb")
    #result.write(decrypted)
    #result.close()
    cipherfile.close()
    #keyfile.close()


if __name__ == '__main__':
    main()








































