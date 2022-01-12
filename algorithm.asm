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

const counter = 255
get_key: 
    ; richtige Speicheradresse finden
    MAR <- 80
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; i % keylength, je nachdem read-Funktion aufrufen
    ACCU <- i % 4 

    if ACCU = 0: read_key_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_key_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_key_2
    
    ; k <- load key[i % keylength]
    read_key_1
    
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
////////////////////////////
get_Si:
    ; richtige Speicheradresse finden
    MAR = i / 4
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem read-Funktion aufrufen
    ACCU = i % 4

    if ACCU = 0: read_Si_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Si_2
    
    read_Si_1

read_Si_4:
    MDR <- MDR AND 255
    tmp_data <- MDR

read_Si_3: 
    MDR <- MDR AND 65280
    tmp_data <- MDR
    MDR <- MDR[31]^8@MDR[31..8]
read_Si_2: 
    MDR <- MDR AND 16711680
    tmp_data <- MDR
    MDR <- MDR[31]^16@MDR[31..16]
read_Si_1: 
    MDR <- MDR AND -16777216
    tmp_data <- MDR
    MDR <- MDR[31]^24@MDR[31..24]
///////////////////////
get_Sj:
    ; richtige Speicheradresse finden
    MAR = j / 4
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem read-Funktion aufrufen
    ACCU = j % 4

    if ACCU = 0: read_Sj_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Sj_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : read_Sj_2
    
    read_Sj_1

read_Sj_4:
    MDR <- MDR AND 255
    tmp_j <- MDR

read_Sj_3: 
    MDR <- MDR AND 65280
    tmp_j <- MDR
    MDR <- MDR[31]^8@MDR[31..8]
read_Sj_2: 
    MDR <- MDR AND 16711680
    tmp_j <- MDR
    MDR <- MDR[31]^16@MDR[31..16]
read_Sj_1: 
    MDR <- MDR AND -16777216
    MDR <- MDR[31]^24@MDR[31..24]
///////////
swap:
    ;status quo: Daten von S[i] in tmp_data, tmp_adr ist Adresse von S[i], Daten von S[j] in MDR, MAR ist Adresse von S[j]
    put_si_into_sj
    put_sj_into_si
///////
put_si_into_sj:
    ; Daten schonmal reinladen
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem write-Funktion aufrufen
    ACCU = j % 4

    if ACCU = 0: write_Sj_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : write_Sj_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : write_Sj_2
    
    write_Sj_1

write_Sj_4:

    MDR <- MDR AND -256 ;delete_byte_4
    MDR <- MDR OR tmp_i ;write tmp_i in S[j] 
    [MAR] <- MDR 

write_Sj_3:

    MDR <- MDR AND -65281 ;delete_byte_3
    MDR <- MDR OR tmp_i ;write tmp_i in S[j] 
    [MAR] <- MDR 

write_Sj_2:

    MDR <- MDR AND -16711681 ;delete_byte_2
    MDR <- MDR OR tmp_i ;write tmp_i in S[j] 
    [MAR] <- MDR 

write_Sj_1:

    MDR <- MDR AND 16777215 ;delete_byte_1
    MDR <- MDR OR tmp_i ;write tmp_i in S[j] 
    [MAR] <- MDR 
//////
put_sj_into_si:
    ; Daten schonmal reinladen
    MAR <- tmp_adr
    MDR <- [MAR]

    ; richtige Speicherzelle finden, je nachdem write-Funktion aufrufen
    ACCU = i % 4

    if ACCU = 0: write_Si_4
    
    ACCU = ACCU - 1
    if ACCU = 0 : write_Si_3
    
    ACCU = ACCU - 1
    if ACCU = 0 : write_Si_2
    
    write_Si_1

write_Si_4:

    MDR <- MDR AND -256 ;delete_byte_4
    MDR <- MDR OR tmp_j ;write tmp_j in S[i] 
    [MAR] <- MDR 

write_Si_3:

    MDR <- MDR AND -65281 ;delete_byte_3
    MDR <- MDR OR tmp_j ;write tmp_j in S[i] 
    [MAR] <- MDR 

write_Si_2:

    MDR <- MDR AND -16711681 ;delete_byte_2
    MDR <- MDR OR tmp_j ;write tmp_j in S[i] 
    [MAR] <- MDR 

write_Si_1:

    MDR <- MDR AND 16777215 ;delete_byte_4
    MDR <- MDR OR tmp_j ;write tmp_j in S[j] 
    [MAR] <- MDR 

////////////////

for_i_in_0_to_256_wortadressiert:

    ; load k
    get_key
    ; j += k
    j <- j + MDR

    ; load S[i]
    get_Si
    ; j += S[i]
    j <- j + MDR

    ; j = j % 256
    j <- j % 256
    
    ; load sBox(j)
    get_Sj
    
    ; bis hierhin sind Chris und Falk gekommen und haben das von gestern überarbeitet
    ;# swap sBox[i with j]
    swap

    ; repeat 256 times
    i <- i + 1
    counter - 1
    
    if counter = 0: decrypt
    
    for_i_in_0_to_256
    
decrypt:
    ; here we decrypt the final result

