; adress of the SBOX
const SBOX_ADDR = 0

; adress and length of the key
const KEY_ADDR = 80 ;80dec <- 50hex
const KEY_LEN = 4

; adress and length of the input
const INPUT_ADDR = 96 ;96dec <- 60hex 
const INPUT_LENGTH =  13265

; length of one word
const WORD_LEN = 4

; useful byte masks for the read-functions
const byte_4=255 ;00000000 00000000 00000000 11111111
const byte_3=65280 ;00000000 00000000 11111111 00000000
const byte_2=16711680 ;00000000 11111111 00000000 00000000
const byte_1=-16777216 ;11111111 00000000 00000000 00000000

; useful byte masks for the write-functions
const delete_byte_4=-256 ;11111111 11111111 11111111 00000000
const delete_byte_3=-65281 ;11111111 11111111 00000000 11111111
const delete_byte_2=-16711681 ;11111111 00000000 11111111 11111111
const delete_byte_1=16777215 ;00000000 11111111 11111111 11111111

; visualization of the program sequence
main:
    sbox_algorithm
    decrypt

; algorithm for shuffling the sbox
sbox_algorithm:
    counter <- 256
    shuffle_sbox

; prga + xor algorithm for decryption
decrypt:
    decrypt_setup
    decrypt_loop_outer
    
//////////////////////////////////////
get_key:
    ; find correct memory cell containing the key
    MAR <- 80
    ; load in data for later use
    MDR <- [MAR]

    ; i % keylength, depending on that call the right read function
    ACCU <- i MOD 4

    if ACCU <- 0: jump read_key_4

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_key_3

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_key_2

    ; k <- load key[i % keylength]
    read_key_1

; delete specific bytes and shift to get the desired byte to the rightmost space of the memory cell
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
    ; get correct memory cell and save the adress for later use
    MAR <- i / 4
    tmp_adr <- i / 4
    
    ; load in data for the read function to use
    MDR <- [MAR]

    ; call the correct read function with the help of modulo
    ACCU <- i MOD 4

    if ACCU <- 0: jump read_Si_4

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_Si_3

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_Si_2

    read_Si_1

; delete specific bytes and shift to get the desired byte to the rightmost space of the memory cell
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
    ; get correct memory cell
    MAR <- j / 4
    ; load in data for the read function to use
    MDR <- [MAR]

    ; call the correct read function with the help of modulo
    ACCU <- j MOD 4

    if ACCU <- 0: jump read_Sj_4

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_Sj_3

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump read_Sj_2

    read_Sj_1

; delete specific bytes and shift to get the desired byte to the rightmost space of the memory cell
; shift tmp_Si to the position where Sj was
read_Sj_4:
    MDR <- 255 & MDR
    tmp_Sj <- MDR ; needed later for the write functions, no need to shift Si, position 4 is already correct

read_Sj_3:
    MDR <- 65280 & MDR
    MDR <- 0^8@MDR[31..8]
    tmp_Sj <- MDR                   ; needed later for the write functions
    tmp_Si <- tmp_Si[31-8..0]@0^8   ; shift Si to position 3

read_Sj_2:
    MDR <- 16711680 & MDR
    MDR <- 0^16@MDR[31..16]
    tmp_Sj <- MDR                   ; needed later for the write functions
    tmp_Si <- tmp_Si[31--16..0]@0^16 ;shift Si to position 2

read_Sj_1:
    MDR <- -16777216 & MDR
    MDR <- 0^24@MDR[31..24]
    tmp_Sj <- MDR                   ; needed later for the write functions
    tmp_Si <- tmp_Si[31-24..0]@0^24 ;shift Si to position 1

///////////////////////

; function to shift tmp_Sj to the position where Si was at the beginning
S.L._tmp_Sj:
    ACCU <- i mod 4

    if ACCU <- 0: break

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump S.L._tmp_Sj_8

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump S.L._tmp_Sj_16

    S.L._tmp_Sj_24

S.L._tmp_Sj_8:
    tmp_Sj <- tmp_Sj[31-8..0]@0^8

S.L._tmp_Sj_16:
    tmp_Sj <- tmp_Sj[31-16..0]@0^16

S.L._tmp_Sj_24:
    tmp_Sj <- tmp_Sj[31-24..0]@0^24

///////
; put the value of Si into the position of Sj aka Swap 1 of 2
put_Si_into_Sj:
    ; load in data for later use
    MDR <- [MAR]

    ; find correct memory cell , depending on that call the right write function
    ACCU <- j MOD 4

    if ACCU <- 0: jump write_Sj_4

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump write_Sj_3

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump write_Sj_2

    write_Sj_1

; delete specific bytes of the input and overwrite the correct value of the memory cell
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
//////////
; put the value of Sj into the position of Si aka Swap 2 of 2
put_Sj_into_Si:
    ; load in data for later use
    MAR <- tmp_adr
    MDR <- [MAR]

    ; find correct memory cell , depending on that call the right write function
    ACCU <- i MOD 4

    if ACCU <- 0: jump write_Si_4

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump write_Si_3

    ACCU <- ACCU - 1
    if ACCU <- 0 : jump write_Si_2

    write_Si_1

; delete specific bytes of the input and overwrite the correct value of the memory cell
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

shuffle_sbox:

    ; load k
    get_key
    ; j += k
    j <- j + MDR

    ; load S[i]
    get_Si
    ; j += S[i]
    j <- j + MDR

    ; j <- j % 256
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

    ; if repeated 256 times, the sbox should be correctly shuffled
    if counter <- 0: break
    
    ; else loop again 
    shuffle_sbox

///////////////

decrypt_setup:
    ; here we decrypt the final result
    ; this is to be done after setup of the s-box

    ; for every byte in the input the s-box gets shuffled slightly again.

    ; decryption starts with setting i and j to zero
    i <- 0
    j <- 0

    ; NOTE: if we could, we can replace wordIndex.
    ; i don't care all that much

    ; set wordIndex to be the length of the input
    ; when wordIndex is 0, we stop iterating
    wordIndex <- INPUT_LENGTH
    ; divide wordIndex by 4 (same as >> 2), because input is byte addressed
    wordIndex <- wordIndex >> 2

///////////////

decrypt_loop_outer:
    ; we want to xor 4 bytes at once.
    ; we save the pattern for that in here
    pattern <- 0

    ; loopindex starts at 0 and will be incremented in steps of 8
    ; e.g. {0, 8, 16, 24}
    ; this is useful to later use it as proper byte shift-position in `pattern`
    loopIndex <- 0

    decrypt_loop_inner

///////////////

decrypt_loop_inner:
    ; count i clockwise. mod 256, because 256 is the length of the sbox
    i <- i + 1
    i <- i & 0xff ; 0xff === 255.

    # i1 is the word-address part of the i-th sbox byte
    # while i2 is the byte position of i-th sbox byte

    i1 <- i >> 2
    i2 <- i & 0b11 ; 0b11 === 3
    i2 <- i2 * 8

    ; ibox <- sbox[i]
    MAR <- SBOX_ADDR + i1
    ACCU <- MDR[MAR]
    ; move accu, so that the correct byte lies at 0..8 position.
    ; more significant bytes are irrelevant,
    ; as they get canceled out by later operations.
    ibox <- ACCU >> i2

    ; increment j by the ith byte in the sbox mod 256
    j <- j + ibox
    j <- j & 0xff; 0xff === 255

    ; the way we've split i up into an address
    ; and a byte positon part,
    ; we'll do now with j

    ; j1 is the word address
    j1 <- j >> 2
    ; j2 is the byte position in that word
    j2 <- j & 0b11
    j2 <- j2 * 8

    ; index <- sbox[j]
    ACCU <- SBOX_ADDR + j1
    MAR <- ACCU
    ACCU <- MDR[MAR]

    ; bring relevant byte at position 0..8
    index <- ACCU >> j2
    index <- index + ibox
    index <- index & 0xff

    ; ibox is no longer needed

    ; BREAKPOINT A
    
    ; now mutate the sbox, by swapping the ith and the jth byte
    swap_byte_start

///////////////

swap_byte_start:
    ; first, check if we're operating on the same word
    ACCU <- i - j
   
    if ACCU === 0: jump swap_same_word
    jump swap_differing_word

    jump swap_byte_end

///////////////

swap_same_word:
    ; if we're operating on the same byte, abort
    ACCU <- i2 - j2
    if ACCU === 0: jump: swap_byte_end
    ; we're operating on the same word, but on different bytes

    ; we're reusing ibox now

    MAR <- SBOX_ADDR + i1
    ibox <- MDR[MAR]

    ; get i2 byte, move at j2 position
    a <- ibox >> i2
    a <- a & 0xff
    a <- a << j2

    ; get j2 byte, move at i2 position
    ; we will use register j1, it is no longer needed.
    j1 <- ibox >> j2
    j1 <- j1 & 0xff
    j1 <- j1 << i2

    ; merge both bytes.
    ; They are guaranteed to be at separate locations.
    a <- a | b

    ; j1 is no longer needed

    ; j1 will have 1s on the byte addressed by j2
    j1 <- 0xff
    j1 <- j1 << j2
    ; ACCU will have 1s on the byte addressed by i1
    ACCU <- 0xff << i2
    ; merge 1s of j1 and ACCU
    ACCU <- ACCU | j1
    ACCU <- INV ACCU
    ; ACCU now has a 1 every where, except where the 2 byte lie,
    ; that should be switched around

    ; let's clear these bytes, that should be switched
    ibox <- ibox & ACCU

    ; and now set them
    ibox <- ibox | a

    ; write back to the sbox
    MAR <- SBOX_ADDR + i1
    MDR[MAR] <- ibox
    ; and return
    jump: swap_byte_end

///////////////

swap_differing_word:
    ; i1 != j1

    ; fetch words from buffer
    ; and mask out proper byte
    MAR <- SBOX_ADDR + i1
    a <- MDR[MAR]
    a <- a >> i2
    a <- a & 0xff
    ; move a at position it's needed
    a <- a << j2

    MAR <- SBOX_ADDR + j1
    b <- MDR[MAR]
    b <- b >> j2
    b <- b & 0xff
    ; move b at position it's needed
    b <- b << i2

    MAR <- SBOX_ADDR + i1
    ibox <- MDR[MAR]
    ACCU <- 0xff << i2
    ACCU <- INV ACCU
    ; clear byte at pos of a in ibox
    ibox <- ibox & ACCU
    ; set byte b
    ibox <- ibox | b
    ; write back to memory
    MDR[MAR] <- ibox

    ; now write byte a into word at sbox[j1]
    MAR <- SBOX_ADDR + j1
    ibox <- MDR[MAR]
    ; clear the position byte b will occupy in ibox
    ACCU <- 0xff << j2
    ACCU <- INV ACCU
    ibox <- ibox & ACCU
    ; set byte a
    ibox <- ibox | a
    ; write back to memory
    MDR[MAR] <- ibox

    ; return
    jump: swap_byte_end

///////////////

swap_byte_end:
    ; ibox, i1, i2, j1, j2 are no longer needed

    ; we fetch the word at `index` and extract the byte
    ; it's going to become part of the bytepattern we use to xor
    MAR <- index >> 2
    ibox <- MDR[MAR]

    ; extract the byte position from index
    index <- index & 0b11; 0b11 === 3
    index <- index * 8

    ; single out the byte we want from the word
    ibox <- ibox >> index
    ibox <- ibox & 0xff

    ; apply the byte to the 4 byte xor pattern
    ibox <- ibox << loopIndex
    pattern <- pattern | ibox

    ;   -----------------------------
    ;   --- check inner loop conditions ---
    ACCU = 24 - loopIndex
    if ACCU === 0: jump perform_xor

    loopIndex <- loopIndex + 8

    jump: decrypt_loop_inner:

///////////////

perform_xor:
    ; BREAKPOINT B
    ; analyze pattern here

    ; xor 4 bytes at once, by leveraging word based instructions
    ACCU <- i >> 2
    MAR <- INPUT_ADDR + i
    ACCU <- MDR[MAR]
    ACCU <- ACCU xor pattern
    MDR[MAR] <- ACCU

    ;   -----------------------------
    ;   --- check outer loop conditions ---

    ; decrement wordIndex
    wordIndex <- wordIndex - 1

    ; (wordIndex == 0) <=> decryption done, goto end
    if wordIndex == 0: jump end
    ; else, another iteration
    jump: decrypt_loop_outer

///////////////

end:

; TODO if last byte does not get transformed,
; incremet wordIndex by 1
; TODO replace all | with +, to drive down `cost`
