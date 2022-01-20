const SBOX_ADDR=0
const KEY_ADDR=80 ;80dec = 50hex
const KEY_LEN=4
const byte_4=255 ;00000000 00000000 00000000 11111111
const byte_3=65280 ;00000000 00000000 11111111 00000000
const byte_2=16711680 ;00000000 11111111 00000000 00000000
const byte_1=-16777216 ;11111111 00000000 00000000 00000000

const delete_byte_4=-256 ;11111111 11111111 11111111 00000000
const delete_byte_3=-65281 ;11111111 11111111 00000000 11111111
const delete_byte_2=-16711681 ;11111111 00000000 11111111 11111111
const delete_byte_1=16777215 ;00000000 11111111 11111111 11111111

; TODO write the ACTUAL NUMBER IN HERE
; THIS NUMBER IS MADE UP
const INPUT_LENGTH =  13268
; Whatever floats your goat! Allocate manually and load file at this position
; THIS NUMBER IS MADE UP
const INPUT_ADDR = 0xdeadbeef

; number of bytes in one word 
const WORD_LEN=4

main:
    counter = 256
    for_i_in_0_to_256_wortadressiert

get_key:
    ; richtige Speicheradresse finden
    MAR <- 80
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; i % keylength, je nachdem read-Funktion aufrufen
    ACCU <- i MOD 4

    if ACCU = 0: read_key_4

    ACCU = ACCU - 1
    if ACCU = 0 : read_key_3

    ACCU = ACCU - 1
    if ACCU = 0 : read_key_2

    ; k <- load key[i % keylength]
    read_key_1

read_key_4:
    MDR <- 255 & MDR

read_key_3:
    MDR <- 65280 & MDR
    MDR <- 0^8@MDR[31..8]

read_key_2: 
    MDR <- 16711680 & MDR
    MDR <- 0^16@MDR[31..16]

read_key_1: 
    MDR <- -16777216 & MDR
    MDR <- 0^24@MDR[31..24]

////////////////////////////
get_Si:
    ; richtige Speicheradresse finden und schon einmal zwischenspeichern
    MAR = i / 4
    tmp_adr <- i / 4
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem read-Funktion aufrufen
    ACCU = i MOD 4

    if ACCU = 0: read_Si_4

    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_3

    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_2

    read_Si_1

read_Si_4:
    MDR <- 255 & MDR
    tmp_Si <- MDR

read_Si_3:
    MDR <- 65280 & MDR
    MDR <- 0^8@MDR[31..8]
    tmp_Si <- MDR

read_Si_2: 
    MDR <- 16711680 & MDR
    MDR <- 0^16@MDR[31..16]
    tmp_Si <- MDR

read_Si_1: 
    MDR <- -16777216 & MDR
    MDR <- 0^24@MDR[31..24]
    tmp_Si <- MDR

///////////////////////
get_Sj:
    ; richtige Speicheradresse finden
    MAR = j / 4
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem read-Funktion aufrufen
    ACCU = j MOD 4

    if ACCU = 0: read_Sj_4

    ACCU = ACCU - 1
    if ACCU = 0 : read_Sj_3

    ACCU = ACCU - 1
    if ACCU = 0 : read_Sj_2

    read_Sj_1

read_Sj_4:
    MDR <- 255 & MDR
    tmp_Sj <- MDR

read_Sj_3:
    MDR <- 65280 & MDR
    MDR <- 0^8@MDR[31..8]
    tmp_Sj <- MDR
    tmp_Si <- tmp_Si[31-8..0]@0^8;auf Stelle 3 verschieben

read_Sj_2: 
    MDR <- 16711680 & MDR
    MDR <- 0^16@MDR[31..16]
    tmp_Sj <- MDR
    tmp_Si <- tmp_Si[31--16..0]@0^16;auf Stelle 2 verschieben

read_Sj_1: 
    MDR <- -16777216 & MDR
    MDR <- 0^24@MDR[31..24]
    tmp_Sj <- MDR
    tmp_Si <- tmp_Si[31-24..0]@0^24;auf Stelle 1 verschieben

///////////////////////

S.L._tmp_Sj:
    ACCU <- i mod 4

    if ACCU = 0: break

    ACCU = ACCU - 1
    if ACCU = 0 : S.L._tmp_Sj_8

    ACCU = ACCU - 1
    if ACCU = 0 : S.L._tmp_Sj_16

    S.L._tmp_Sj_24

S.L._tmp_Sj_8:
    tmp_Sj <- tmp_Sj[31-8..0]@0^8

S.L._tmp_Sj_16:
    tmp_Sj <- tmp_Sj[31-16..0]@0^16

S.L._tmp_Sj_24:
    tmp_Sj <- tmp_Sj[31-24..0]@0^24

///////
put_Si_into_Sj:
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem write-Funktion aufrufen
    ACCU = j MOD 4

    if ACCU = 0: write_Sj_4

    ACCU = ACCU - 1
    if ACCU = 0 : write_Sj_3

    ACCU = ACCU - 1
    if ACCU = 0 : write_Sj_2

    write_Sj_1

write_Sj_4:

    MDR <- -256 & MDR ;delete_byte_4
    MDR <- tmp_Si | MDR;write tmp_Si in S[j] 
    M[MAR] <- MDR 

write_Sj_3:

    MDR <- -65281 & MDR  ;delete_byte_3
    MDR <- tmp_Si | MDR  ;write tmp_Si in S[j] 
    M[MAR] <- MDR 

write_Sj_2:

    MDR <- -16711681 & MDR;delete_byte_2
    MDR <- tmp_Si | MDR;write tmp_Si in S[j] 
    M[MAR] <- MDR 

write_Sj_1:

    MDR <- 16777215 & MDR;delete_byte_1
    MDR <- tmp_Si | MDR;write tmp_Si in S[j] 
    M[MAR] <- MDR 
//////
put_Sj_into_Si:
    ; Daten schonmal reinladen
    MAR <- tmp_adr
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem write-Funktion aufrufen
    ACCU = i MOD 4

    if ACCU = 0: write_Si_4

    ACCU = ACCU - 1
    if ACCU = 0 : write_Si_3

    ACCU = ACCU - 1
    if ACCU = 0 : write_Si_2

    write_Si_1

write_Si_4:

    MDR <- -256 & MDR;delete_byte_4
    MDR <- tmp_Sj | MDR;write tmp_Sj in S[i] 
    M[MAR] <- MDR 

write_Si_3:

    MDR <- -65281 & MDR;delete_byte_3
    MDR <- tmp_Sj | MDR;write tmp_Sj in S[i] 
    M[MAR] <- MDR 

write_Si_2:

    MDR <- -16711681 & MDR;delete_byte_2
    MDR <- tmp_Sj | MDR;write tmp_Sj in S[i] 
    M[MAR] <- MDR 

write_Si_1:

    MDR <- 16777215 & MDR;delete_byte_4
    MDR <- tmp_Sj | R MDR;write tmp_Sj in S[j] 
    M[MAR] <- MDR 

////////////////

for_i_in_0_to_256:

    ; load k
    get_key
    ; j += k
    j <- j + MDR

    ; load S[i]
    get_Si
    ; j += S[i]
    j <- j + MDR

    ; j = j % 256
    j <- j MOD 256

    ; load sBox(j)
    get_Sj

    ;# swap sBox[i with j]
    S.L._tmp_Sj
    put_Si_into_Sj
    put_Sj_into_Si

    ; repeat 256 times
    i <- i + 1
    counter - 1

    if counter = 0: decrypt_setup
    for_i_in_0_to_256

decrypt_setup:
    ; here we decrypt the final result
    ; this is to be done after setup of the s-box

    ; for every byte in the input the s-box gets shuffled slightly again.

    ; decryption starts with setting i and j to zero
    i <- 0
    j <- 0

    ; set wordIndex to be the length of the input
    ; when wordIndex is 0, we stop iterating
    wordIndex = INPUT_LENGTH
    ; divide wordIndex by 4 (same as >> 2), because input is byte addressed
    wordIndex = wordIndex >> 2

decrypt_loop_outer:
    ; we want to xor 4 bytes at ones.
    ; we save the pattern for that in here
    pattern <- 0

    ; loopindex starts at 24 and will de decremented in steps of 8
    ; e.g. {24, 16, 8, 0}
    ; this is useful to later use it as proper byte shift-position in `pattern`
    loopIndex <- 24
decrypt_loop_inner:
    ; count i clockwise. mod 256, because 256 is the length of the key
    i <- i + 1
    i <- i & 0xff ; 0xff === 255. 

    # i1 is the word-address part of the i-th sbox byte
    # while i2 is the byte position of i-th sbox byte
    i1 <- (i >> 2)
    i2 <- i & 0b11 ; 0b11 === 3
    i2 <- i2 * 8
    ; we need to do this step, because the first byte 
    ; we want to address, is highest up in the word 
    ; (e.g. as position 24)
    i2 <- 24 - i2

    ; ibox = sbox[i]
    ACCU <- SBOX_ADDR + i1
    MAR <- ACCU
    ACCU = MDR[MAR]
    ; move accu, so that the correct byte lies at 0..8 position.
    ; more significant bytes are irrelevant, 
    ; as they get canceled out by later operations.
    ibox = ACCU >> i2

    ; increment j by the ith byte in the sbox mod 256
    j <- j + ibox
    j <- j & 0xff; 0xff === 255
    
    ; the way we've split i up into an address 
    ; and a byte positon part,
    ; we'll do now with j

    ; j1 is the word address
    j1 = j >> 2
    ; j2 is the byte position in that word
    j2 = j2 * 8
    j2 = 24 - j2

    ; index = sbox[j]
    ACCU = SBOX_ADDR + j2
    MAR <- ACCU

    ACCU <- MDR[MAR]
    
    ; bring relevant byte at position 0..8
    index = ACCU >> j2
    index = index + ibox
    index = index & 0xff

    ; ibox is no longer needed

    ; now mutate the sbox, by swapping the ith and the jth byte
swap_byte_start:
    ; first, check if we're operating on the same word
    ACCU = i - j
    if ACCU === 0: jump swap_same_word:
    jump swap_differing_words:
swap_same_word:
    ; if we're operating on the same byte, abort
    ACCU = i2 - j2
    if ACCU === 0: jump: swap_byte_end
    ; we're operating on the same word, but on different bytes

    ; we're reusing ibox now

    MAR = SBOX_ADDR + i1
    ibox = MDR[MAR]

    ; get i2 byte, move at j2 position
    a = ibox >> i2
    a = a & 0xff
    a = a << j2

    ; get j2 byte, move at i2 position
    ; we will use register j1, it is no longer needed.
    j1 = ibox >> j2
    j1 = j1 & 0xff
    j1 = j1 << i2

    ; merge both bytes. 
    ; They are guaranteed to be at separate locations.
    a = a | b

    ; j1 is no longer needed

    j1 = 0xff
    j1 << j2
    ACCU = 0xff << i2
    ACCU = ACCU | j1
    ACCU = INV ACCU
    ; ACCU now has a 1 every where, except where the 2 byte lie,
    ; that should be switched around 

    ; let's clear these bytes, that should be switched
    ibox = ibox & ACCU

    ; and now set them
    ibox = ibox | a

    ; write back to the sbox
    MAR = SBOX_ADDR + i1
    MDR[MAR] = ibox
    ; and return
    jump swap_byte_end:

swap_same_word:
    ; i1 != j1
    
    ; fetch words from buffer
    ; and mask out proper byte
    MAR = SBOX_ADDR + i1
    a = MDR[MAR]
    a = a >> i2
    a = a & 0xff
    ; move a at position it's needed
    a = a << j2

    MAR = SBOX_ADDR + j1
    b = MDR[MAR]
    b = b >> j2
    b = b & 0xff
    ; move b at position it's needed
    b = b << i2

    MAR = SBOX_ADDR + i1
    ibox = MDR[MAR]
    ACCU = 0xff << i2
    ACCU = INV ACCU
    ; clear byte at pos of a in ibox
    ibox = ibox & ACCU
    ; set byte b
    ibox = ibox | b
    ; write back to memory
    MDR[MAR] = ibox

    ; now write byte a into word at sbox[j1]
    MAR = SBOX_ADDR + j1
    ibox = MDR[MAR]
    ; clear the position byte b will occupy in ibox
    ACCU = 0xff << j2
    ACCU = INV ACCU
    ibox = ibox & ACCU
    ; set byte a
    ibox = ibox | a
    ; write back to memory
    MDR[MAR] = ibox

    ; return 
swap_byte_end:
    ; ibox, i1, i2, j1, j2 are no longer needed
    

    ;   -----------------------------
    ;   --- check loop conditions ---

    ; decrement wordIndex
    wordIndex = wordIndex - 1
    
    ; (wordIndex == 0) <=> decryption done, goto end
    if wordIndex == 0: jump end
    ; else, another iteration
    jump decrypt_loop_outer

end: