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

    if counter = 0: decrypt
    for_i_in_0_to_256

decrypt:
    ; here we decrypt the final result
    ; this is to be done after setup of the s-box

    ; for every byte in the input the s-box gets shuffled slightly again.
