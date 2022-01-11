    const SBOX_ADDR=0
    const KEY_ADDR=80 ;80dec = 50hex
    const KEY_LEN=4
    const byte_4=255 ;00000000 00000000 00000000 11111111
    const byte_3=65280 ;00000000 00000000 11111111 00000000
    const byte_2=16711680 ;00000000 11111111 00000000 00000000
    const byte_1=-16777216 ;11111111 00000000 00000000 00000000

read_4:
    MDR <- MDR AND byte_4

read_3: 
    MDR <- MDR AND byte_3

read_2: 
    MDR <- MDR AND byte_2

read_1: 
    MDR <- MDR AND byte_1

; init s box 0..256
    ACCU <- 0
    MAR <- SBOX_ADDR
s_box_fill_0_to_256:
    MDR[MAR] <- ACCU
    ACCU <- ACCU + 1
    MAR <- MAR + 1


    ; if ACCU === 256 {jump s_box_shuffle} else { repeate }
    ACCU - 256
    jump_if zeroResult s_box_shuffle
    jump s_box_fill_0_to_256
s_box_shuffle:
    ; j = 0
    R1 <- 0
    ; i = 0
    R2 <- 0

for_i_in_0_to_256:
    ; load sBox[i]
    MAR <- SBOX_ADDR + R2
    MDR <- [MAR]
    ; j += sBox[i]
    R1 <- MDR + R1

    ; k <- load key[i % keylength]
    ACCU <- KEY_ADDR + R2
    MAR <- ACCU % KEY_LEN
    MDR <- [MAR]
    ; j += k
    R1 <- MDR + R1

    ; j = j % 256
    R1 <- R1 & 0xff

    ;# swap sBox[i with j]

    ; load sBox[j]
    MAR <- R1
    ; tmp = sBox(j)
    R3 <- MDR[MAR]

    ; load sBox(i)
    MAR <- R2
    ; accu = sBox(i)
    ACCU <- MDR[MAR]

    ; sBox(i) = tmp
    MDR[MAR] <- R3

    ; sBox(j) = i (in accu)
    MAR <- R1
    MDR[MAR] <- ACCU

    ; repeate 256 times
    R2 - 256
    jump_if zeroResult decrypt
    jump for_i_in_0_to_256

read_Si_4:
    MDR <- MDR AND 255

read_Si_3: 
    MDR <- MDR AND 65280
    MDR <- MDR[31]^8@MDR[31..8]
read_Si_2: 
    MDR <- MDR AND 16711680
    MDR <- MDR[31]^16@MDR[31..16]
read_Si_1: 
    MDR <- MDR AND -16777216
    MDR <- MDR[31]^24@MDR[31..24]

get_Si:
    ; richtige Speicheradresse finden
    MAR = R2 / 4
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem read-Funktion aufrufen
    ACCU = R2 % 4

    if ACCU = 0: read_Si_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_2
    
    read_Si_1

read_key_4:
    MDR <- MDR AND 255

read_key_3: 
    MDR <- MDR AND 65280
    MDR <- MDR[31]^8@MDR[31..8]
read_key_2: 
    MDR <- MDR AND 16711680
    MDR <- MDR[31]^16@MDR[31..16]
read_key_1: 
    MDR <- MDR AND -16777216
    MDR <- MDR[31]^24@MDR[31..24]

get_key: 
    ; richtige Speicheradresse finden
    MAR <- 80
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; i % keylength, je nachdem read-Funktion aufrufen
    ACCU <- R2 % 4 

    if ACCU = 0: read_key_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_key_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_key_2
    
    ; k <- load key[i % keylength]
    read_key_1

for_i_in_0_to_256_wortadressiert:
    ; load S[i]
    get_Si
    ; j += S[i]
    R1 <- R1 + MDR

    get_key
    ; j += k
    R1 <- R1 + MDR

    ; j = j % 256
    R1 <- R1 & 0xff
    
    ; bis hierhin sind Chris und Falk gekommen und haben das von gestern überarbeitet
    ;# swap sBox[i with j]

    ; load sBox[j]
    MAR <- R1
    ; tmp = sBox(j)
    R3 <- MDR[MAR]

    ; load sBox(i)
    MAR <- R2
    ; accu = sBox(i)
    ACCU <- MDR[MAR]

    ; sBox(i) = tmp
    MDR[MAR] <- R3

    ; sBox(j) = i (in accu)
    MAR <- R1
    MDR[MAR] <- ACCU

    ; repeate 256 times
    R2 - 256
    jump_if zeroResult decrypt
    jump for_i_in_0_to_256
    

decrypt:
    ; here we decrypt the final result

