*=$2000
INCBIN      "SPRITES.PRG.SPT",1,1 ; sprite data

; 10 SYS (4096):REM bootstrapper
*=$801
            BYTE $1D, $08, $0A, $00, $9E, $20, $28, $34, $30, $39, $36, $29, $3a, $8f, $20, $42, $4F, $4F, $54, $53, $54, $52, $41, $50, $50, $45, $52, $00, $00, $00


*=$1000 ; start with SYS 4096

; taken from: http://cadaver.homeftp.net/
prevjoy = $05

INIT        JSR $E544     ; KERNAL ROM clear screen

            LDA #$03      
            STA $D021     ; cyan background
            LDA #$00      
            STA $D020     ; black border


setup       LDA #$01      
            STA $D015     ; switch on Sprite #0

            LDA #$01      
            STA $D027     ; let's make our sprite white, for the sake of this demo

            LDA #$80      
            STA $D000     
            STA $D001     ; start sprite at (128,128)

            LDA #$80      ; Set data for sprite #00 ($80 = 128; 128 * 64 = 8192 = $2000, where we loaded our
            STA $07F8     ; sprite data, for the default VIC-II bank)


frame       LDA $D012
            CMP $10       
            BNE frame     
joyread     LDA $DC00     ; read from JOY2
            LDX #$00      ; set up the X- and Y- deltas
            LDY #$00      
joyup       LSR
            BCS joydown   
            DEY
joydown     LSR
            BCS joyleft   
            INY
joyleft     LSR
            BCS joyright  
            DEX
joyright    LSR
            BCS setmove   
            INX
            LSR
setmove     STX $FB       ; store deltas in zero-page for now...
            STY $FC       

movex       LDA $D000
            CLC
            ADC $FB
            TAX    
            BNE movey     ; check for MSB boundary crossing

            LDA $D010     
            AND $01       ; test which side of the MSB we're on
            BEQ movex2    
            AND $FE       ; move back into LSB (switch off bit 0)
            STA $D010     
            JMP movey     
movex2      ORA #$01      ; or move in MSB... (switch on bit 0)
            STA $D010     

movey       STX $D000 
            LDA $D001
            CLC
            ADC $FC       
            CMP #$E7      ; test Hi-Y and Lo-Y and prevent
            BEQ frame     ; sprite leaving the box
            CMP #$30      
            BEQ frame     
            STA $D001     

            JMP frame     


; woo-hoo! sprite on screen!