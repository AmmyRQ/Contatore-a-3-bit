;====================================================================
; File main.asm generato da Progetto guidato
;
; Creato: ven. 11 ott. 2024
; Processore: PIC16F84A
; Compilatore:  MPASM (Proteus)
; Descrizione: 
;    Contatore automatico a 3 bit, utilizzando 3 LED per mostrare il conteggio (RA0-RA2).
;    Per resettare l'account viene utilizzato un interrupt, tramite un pulsante di pull-up (RB0/INT).
;    Il progetto utilizza una frequenza di clock di 4 MHz.
;====================================================================

;====================================================================
; DEFINIZIONI
;====================================================================

#include p16f84a.inc    ; Indica il modello di PIC da utilizzare.
#include <p16F84A.inc>  ; Definizioni e librerie specifiche del PIC.

;====================================================================
; VARIABILI
;====================================================================
DELL EQU 0x20   ; Variabile bassa per il ritardo.
DELH EQU 0x21   ; Variabile alta per il ritardo.
DELM EQU 0x22   ; Variabile media per il ritardo.


;====================================================================
; Vettori di RESET e INTERRUZIONE
;====================================================================

; Vettori di RESEST
; Indica al microcontrollore da quale indirizzo di memoria verrà utilizzata la routine.
    ORG 0x0000
    GOTO MAIN

; Vettori di INTERRUZIONE.
; Indica al microcontrollore l'indirizzo di memoria da utilizzare in caso di interruzione.
    ORG 0x0004
    GOTO INTR

;====================================================================
; CODICE
;====================================================================

MAIN
    ; Configurazione iniziale
    CLRF PORTA        ; Pulire la porta A.
    BSF STATUS, RP0   ; Seleziona il banco di memoria 1.
    CLRF TRISA        ; Imposta la porta A come uscita.
    BCF STATUS, RP0   ; Ritorna al banco di memoria 0.
    
    CLRF PORTB        ; Pulire la porta B.
    BSF STATUS, RP0   ; Seleziona il banco di memoria 1.
    MOVLW b'00000001' ; Configurare RB0/INT come ingresso, gli altri come uscite.
    MOVWF TRISB
    BCF STATUS, RP0   ; Ritorna al banco di memoria 0.

    BSF INTCON, INTE  ; Abilita l'interruzione esterno su RB0/INT.
    BSF INTCON, GIE   ; Abilita gli interruzione globali.

; Routine che eseguono le operazioni automatiche.
Loop
    CALL delay          ; Chiama l'istruzione di ritardo.
    INCF PORTA, F       ; Aumenta il valore della porta A.
    MOVLW 0x08          ; Imposta il valore 0x08 in W.
    SUBWF PORTA, W      ; Confronta W con PORTA (PORTA - 0x08).
    BTFSC STATUS, C     ; Se W < 8 (bit di riporto), salta l'istruzione successiva. In caso contrario, significa che il contatore è a 7 e il conteggio viene riavviato.
    CALL RestartCounter ; Azzerare il contatore.
    GOTO Loop           ; Ripetere il ciclo.

; Routine di interruzione.
INTR:
    BTFSC INTCON, INTF  ; Verificare se l'interruzione è esterna.
    BCF INTCON, INTF    ; Cancellare il flag di interrupt esterno se la condizione precedente è soddisfatta.
    CALL RestartCounter ; Azzerare il contatore.
    RETFIE              ; Si rientra dall'interruzione e si riprende il programma principale.
    
; Routine di ritardo
delay:
    MOVLW 0xFF
    MOVWF DELH
    MOVLW 0x0A
    MOVWF DELM
del3:
    MOVLW 0xFF
    MOVWF DELL
del2:
    DECFSZ DELL,F
    GOTO del2
    DECFSZ DELH,F
    GOTO del3
    DECFSZ DELM,F
    GOTO del3
    RETURN

; Istruzione per azzerare il contatore
RestartCounter
    CLRF PORTA        ; Azzerare il contatore impostando la porta A su 0.
    RETURN

    END
