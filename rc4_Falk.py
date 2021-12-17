import codecs
  
def permutate(sbox, key):
    j = 0
    keylength = len(key)

    for i in range(len(sbox)):
        j = (j + sbox[i] + key[i % keylength]) % 256
        sbox[i], sbox[j] = sbox[j], sbox[i]
    return sbox
    
def prga(perm_sbox):
    i, j = 0, 0
    while True:
        i = (i + 1) % 256
        j = (j + perm_sbox[i]) % 256
        perm_sbox[i], perm_sbox[j] = perm_sbox[j], perm_sbox[i]
        z = perm_sbox[(perm_sbox[i] + perm_sbox[j]) % 256]
        yield z 

def xor(keystream, ciphertext):
    plaintext = []
    for c in ciphertext:
        val = ("%02X" % (c ^ next(keystream)))
        plaintext.append(val)
    plaintext = ''.join(plaintext)
    return plaintext

def rc4(sbox, key, ciphertext):
    perm_sbox = permutate(sbox, key)
    keystream = prga(perm_sbox)
    plaintext = xor (keystream, ciphertext)
    return codecs.decode(plaintext, 'hex_codec')

# Checken ob der Permutier-Algorithmus funktioniert:
test_key_file = open("sBox_swap_test_key", "rb")
sBox_swap_test_key = test_key_file.read()
sBox_swap_test_key = [c for c in sBox_swap_test_key]
test_key_file.close()

swap_test_file = open("sBox_swap_test", "rb")
sBox_swap_test = swap_test_file.read()
sBox_swap_test = [c for c in sBox_swap_test]
swap_test_file.close()

sbox = list(range(256))
perm_sbox = permutate(sbox, sBox_swap_test_key)

if(perm_sbox == sBox_swap_test):
    print("Permutier-Algorithmus funktioniert! :)")
else:
    print("Permutier-Algorithmus funktioniert nicht! :(")

# Tatsächlicher RC4-Algorithmus:
ciphertext_file = open("data_encrypted", "rb")
ciphertext = ciphertext_file.read()
ciphertext_file.close()
#print(ciphertext)

key_file = open("key", "rb")
key = key_file.read()
key_file.close()
#print(key)

sbox = list(range(256))

plaintext = rc4(sbox, key, ciphertext)
print (plaintext)

#Enable this to write bytes into file named "result.txt"
#result = open("result.txt", "wb")
#result.write(plaintext)
#result.close()