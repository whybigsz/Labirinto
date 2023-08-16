;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostração da navegação do Ecran com um avatar
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------


;       Algoritmo verificacao string
;   Ao pisar o carater comparar se o carater pertence a Palavra
;   Se for copiar para o string
;	Quando fizer a palavra , passa para o proximo nivel com outra palavra e reseta a string



.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		NUMDIG	        db	0	; controla o numero de digitos do numero lido
        MAXDIG	        db	4	; Constante que define o numero MAXIMO de digitos a ser aceite
        NUMERO		    db		"                    $" 	; String destinada a guardar o número lido
		NUM_SP		    db		"                    $" 	; PAra apagar zona de ecran
		str_num         db 5 dup(?),'$'

		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os últimos segundos que foram lidos
		Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		100				; tempo máximo de Jogo
		String_TJ		db		"   /100$"

        Nivel123        db      "Nivel1 $","Nivel2 $","Nivel3 $","Nivel4 $","Nivel5 $"
		String_num 		db 		"  0 $"
        String_nome  	db	    "ISEC $","NOTAS $","CRYPTO $","MOMENTO $","ALCATIFA $"
        String_nomeLen  db      4,5,6,7,8
        String_nomeAux  db	    "ISEC $","NOTAS $","CRYPTO $","MOMENTO $","ALCATIFA $"
        String_teste    db      "          $"
        Constroi_teste  db      "          $"
		found		    db		    0	;

		msg1            db      'PARABENS PASSOU DE NIVEL          $'
        msg2            db      'COMPLETE A PALAVRA E PASSE O NIVEL$'

		Ganhou          db      0
		Perdeu          db      0
		Nivel_flag      db      0

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        menu1         	db      'menu.TXT',0
        labi            db      'labi.TXT',0
        ganhouf          db      'ganhou.TXT',0
        perdeuf          db      'perdeu.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		string			db	"Teste prático de T.I",0
		Car				db	32	; Guarda um caracter do Ecran
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]
		POSya			db	3	; Posição anterior de y
		POSxa			db	3	; Posição anterior de x
		POSyn           db  3
		POSxn           db  3
		POSud           db  3 ; Posição do movimento up e down do avatar
        POSrl           db  3 ; Posição do movimento right e left do avatar
        Carn		    db	32 ; Guarda um caracter de teste para fazer verificações

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR
MOV AH,09H
LEA DX,STR
INT 21H
ENDM

; FIM DAS MACROS



;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80

apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp

;ROTINA PARA ESPERAR 3 SEC

delay       proc
            ;conta 1 sec
            MOV     CX, 0FH
            MOV     DX, 4240H
            MOV     AH, 86H
            INT     15H

            ;conta 1 sec
            MOV     CX, 0FH
            MOV     DX, 4240H
            MOV     AH, 86H
            INT     15H

            ;conta 1 sec
            MOV     CX, 0FH
            MOV     DX, 4240H
            MOV     AH, 86H
            INT     15H
            ret
delay       endp

;########################################################################
; HOJE

HOJE PROC

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSHF

		MOV AH, 2AH             ; Buscar a data
		INT 21H
		PUSH CX                 ; Ano-> PILHA
		XOR CX,CX              	; limpa CX
		MOV CL, DH              ; Mes para CL
		PUSH CX                 ; Mes-> PILHA
		MOV CL, DL				; Dia para CL
		PUSH CX                 ; Dia -> PILHA
		XOR DH,DH
		XOR	SI,SI
; DIA ------------------
; DX=DX/AX --- RESTO DX
		XOR DX,DX               ; Limpa DX
		POP AX                  ; Tira dia da pilha
		MOV CX, 0               ; CX = 0
		MOV BX, 10              ; Divisor
		MOV	CX,2
DD_DIV:
		DIV BX                  ; Divide por 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		loop dd_div
		MOV	CX,2
DD_RESTO:
		POP DX                  ; Resto da divisao
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC	SI
		LOOP DD_RESTO
		MOV DL, '/'             ; Separador
		MOV DDMMAAAA[SI],DL
		INC SI
; MES -------------------
; DX=DX/AX --- RESTO DX
		MOV DX, 0               ; Limpar DX
		POP AX                  ; Tira mes da pilha
		XOR CX,CX
		MOV BX, 10				; Divisor
		MOV CX,2
MM_DIV:
		DIV BX                  ; Divisao or 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		LOOP MM_DIV
		MOV CX,2
MM_RESTO:
		POP DX                  ; Resto
		ADD DL, 30h             ; SOMA 30h
		MOV DDMMAAAA[SI],DL
		INC SI
		LOOP MM_RESTO

		MOV DL, '/'             ; Character to display goes in DL
		MOV DDMMAAAA[SI],DL
		INC SI

;  ANO ----------------------
		MOV DX, 0
		POP AX                  ; mes para AX
		MOV CX, 0               ;
		MOV BX, 10              ;
 AA_DIV:
		DIV BX
		PUSH DX                 ; Guarda resto
		ADD CX, 1               ; Soma 1 contador
		MOV DX, 0               ; Limpa resto
		CMP AX, 0               ; Compara quotient com zero
		JNE AA_DIV              ; Se nao zero
AA_RESTO:
		POP DX
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC SI
		LOOP AA_RESTO
		POPF
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
 		RET
HOJE   ENDP

;########################################################################
; LER_TEMPO

Ler_TEMPO PROC

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		PUSHF

		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H

		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente

		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente

		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente

		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET
Ler_TEMPO   ENDP

;########################################################################
; TRATA_HORAS

Trata_Horas PROC

				PUSHF
        		PUSH AX
        		PUSH BX
        		PUSH CX
        		PUSH DX

        		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema

        		MOV		AX, Segundos
        		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
        		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
        		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo

        		mov 	ax,Horas
        		MOV		bl, 10              ;CONVERTE EM DECIMAL
        		div 	bl
        		add 	al, 30h				; Caracter Correspondente às dezenas
        		add		ah,	30h				; Caracter Correspondente às unidades
        		MOV 	STR12[0],al			;
        		MOV 	STR12[1],ah
        		MOV 	STR12[2],'h'
        		MOV 	STR12[3],'$'
        		GOTO_XY 2,0
        		MOSTRA STR12

        		mov 	ax,Minutos
        		MOV 	bl, 10              ;CONVERTE EM DECIMAL
        		div 	bl
        		add 	al, 30h				; Caracter Correspondente às dezenas
        		add		ah,	30h				; Caracter Correspondente às unidades
        		MOV 	STR12[0],al			;
        		MOV 	STR12[1],ah
        		MOV 	STR12[2],'m'
        		MOV 	STR12[3],'$'
        		GOTO_XY	6,0
        		MOSTRA	STR12

        		mov 	ax,Segundos
        		MOV 	bl, 10              ;CONVERTE EM DECIMAL
        		div 	bl
        		add 	al, 30h				; Caracter Correspondente às dezenas
        		add		ah,	30h				; Caracter Correspondente às unidades
        		MOV 	STR12[0],al			;
        		MOV 	STR12[1],ah
        		MOV 	STR12[2],'s'
        		MOV 	STR12[3],'$'
        		GOTO_XY	10,0
        		MOSTRA	STR12


;             _______  ___   __   __  _______  ______
;            |       ||   | |  |_|  ||       ||    _ |
;            |_     _||   | |       ||    ___||   | ||
;              |   |  |   | |       ||   |___ |   |_||_
;              |   |  |   | |       ||    ___||    __  |
;              |   |  |   | | ||_|| ||   |___ |   |  | |
;              |___|  |___| |_|   |_||_______||___|  |_|


                MOV     ax,Tempo_j          ;ax auxiliar para  ajustar o tempo de jogo
                add     Tempo_j,1           ;incrementa tempo de jogo
                MOV 	bl, 10              ;CONVERTE EM DECIMAL
                div 	bl
                add 	al, 30h				; Caracter Correspondente às dezenas
                add		ah,	30h				; Caracter Correspondente às unidades
                MOV 	String_TJ[0],al			;
                MOV 	String_TJ[1],ah
                GOTO_XY	57,0
                MOSTRA	String_TJ

                cmp     Nivel_flag,0    ;verifica nivel1
                je      nivel1
                cmp     Nivel_flag,1    ;verifica nivel2
                je      nivel2
                cmp     Nivel_flag,2    ;verifica nivel3
                je      nivel3
                cmp     Nivel_flag,3    ;verifica nivel3
                je      nivel4
                cmp     Nivel_flag,4    ;verifica nivel3
                je      nivel5

nivel1:
                cmp 	Tempo_j,101
                jb      continua
                call    DERROTA
                jmp     fim_horas
nivel2:
                MOV 	String_TJ[4],39h
                MOV 	String_TJ[5],35h
                MOV 	String_TJ[6],20h
                cmp 	Tempo_j,96
                jb      continua
                call    DERROTA
                jmp     fim_horas
nivel3:
                MOV 	String_TJ[4],39h
                MOV 	String_TJ[5],30h
                cmp 	Tempo_j,91
                jb      continua
                call    DERROTA
                jmp     fim_horas
nivel4:
                MOV 	String_TJ[4],38h
                MOV 	String_TJ[5],35h
                cmp 	Tempo_j,86
                jb      continua
                call    DERROTA
                jmp     fim_horas
nivel5:
                MOV 	String_TJ[4],38h
                MOV 	String_TJ[5],30h
                cmp 	Tempo_j,81
                jb      continua
                call    DERROTA
                jmp     fim_horas


continua:
        		CALL 	HOJE				; Data de HOJE
        		MOV 	al ,DDMMAAAA[0]
        		MOV 	STR12[0], al
        		MOV 	al ,DDMMAAAA[1]
        		MOV 	STR12[1], al
        		MOV 	al ,DDMMAAAA[2]
        		MOV 	STR12[2], al
        		MOV 	al ,DDMMAAAA[3]
        		MOV 	STR12[3], al
        		MOV 	al ,DDMMAAAA[4]
        		MOV 	STR12[4], al
        		MOV 	al ,DDMMAAAA[5]
        		MOV 	STR12[5], al
        		MOV 	al ,DDMMAAAA[6]
        		MOV 	STR12[6], al
        		MOV 	al ,DDMMAAAA[7]
        		MOV 	STR12[7], al
        		MOV 	al ,DDMMAAAA[8]
        		MOV 	STR12[8], al
        		MOV 	al ,DDMMAAAA[9]
        		MOV 	STR12[9], al
        		MOV 	STR12[10],'$'
        		GOTO_XY	68,0
        		MOSTRA	STR12



fim_horas:
        		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas

        		POPF
        		POP DX
        		POP CX
        		POP BX
        		POP AX
        		RET

Trata_Horas ENDP



;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		RET

IMP_FICH	endp




;########################################################################
; LE UMA TECLA

LE_TECLA	PROC

sem_tecla:
		call Trata_Horas
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax

			mov ax,Tempo_init
            mov Tempo_j,ax      ;RESET AO TIME

            call Trata_Horas

            cmp         Ganhou,1
            jne          nivel

nivel:
			cmp     Nivel_flag,0    ;verifica nivel1
			je      nivel1
			cmp     Nivel_flag,1    ;verifica nivel2
			je      nivel2
			cmp     Nivel_flag,2    ;verifica nivel3
			je      nivel3
			cmp     Nivel_flag,3    ;verifica vitoria
			je      nivel4
			cmp     Nivel_flag,4    ;verifica vitoria
            je      nivel5
            cmp     Nivel_flag,5    ;verifica vitoria
            je     win


nivel1:
            call        lv1
            jmp         CICLO
nivel2:
            call        lv2
            jmp         CICLO
nivel3:
            call        lv3
            jmp         CICLO
nivel4:
            call        lv4
            jmp         CICLO
nivel5:
            call        lv5
            jmp         CICLO

win:
            call        delay
            call        VITORIA

CICLO:		goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
			mov		ah, 02h
			mov		dl, Car			; Repoe Caracter guardado
			int		21H

			goto_xy	POSx,POSy		; Vai para nova possição
			mov 	ah, 08h
			mov		bh,0			; numero da página
			int		10h
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor

			goto_xy	78,0			; Mostra o caractr que estava na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car
			int		21H

            cmp     Nivel_flag,5    ;verifica se chegou ao fim
            je      fim


IMPRIME:    goto_xy	POSx,POSy		; Vai para posição do cursor
	        mov		ah, 02h
			mov		dl, 190	; Coloca AVATAR
			int		21H
			goto_xy	POSx,POSy	; Vai para posição do cursor

			mov		al, POSx	; Guarda a posição do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posição do cursor
			mov 	POSya, al

LER_SETA:	call 	LE_TECLA
            cmp     Nivel_flag,0    ;verifica nivel1
			je      tempo1
			cmp     Nivel_flag,1    ;verifica nivel2
			je      tempo2
			cmp     Nivel_flag,2    ;verifica nivel3
			je      tempo3
tempo1:
            cmp 	Tempo_j,102 ; VERIFICA SE O TEMPO ACABOU
            jae      fim
tempo2:
            cmp 	Tempo_j,96
            jae      fim
tempo3:
            cmp 	Tempo_j,91
            jae      fim
tempo4:
            cmp 	Tempo_j,86
            jae      fim
tempo5:
            cmp 	Tempo_j,81
            jae      fim
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			jmp		LER_SETA



ESTEND:		cmp 	al,48h
			jne		BAIXO
			call    UP
			call    VERIFICA_CARATER
			call    VERIFICA_STRING
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			call    DOWN
			call    VERIFICA_CARATER
			call    VERIFICA_STRING
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			call    LEFT
			call    VERIFICA_CARATER
			call    VERIFICA_STRING
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA
			call    RIGHT
			call    VERIFICA_CARATER
			call    VERIFICA_STRING
			jmp		CICLO

fim:
			RET
AVATAR		endp

;########################################################################
; INICIO PROCEDIMENTOS MOVIMENTOS DO AVATAR

UP PROC                     ;move avatar para cima verificando parede

        mov al, POSy
        mov POSud, al       ;guarda POSy numa var de test
        dec POSud           ;decrementa  a var de teste

        goto_xy	POSx,POSud  ;coloco as POS no novo local
        mov 	ah, 08h
        mov		bh,0		;numero da página
        int		10h
        mov		Carn, al	;Guarda o Caracter que está na posição do Curso numa var de teste
        cmp     Carn, 177   ;comparo o caracter de teste com o carater ±. Se for parede salta fora e não mexe o avatar
        je      return

        mov   al, POSud     ;Reset na posiçao do avatar teste
        mov   POSy,al
        mov   al, POSya
        mov   POSud,al      ;Reset na POS de teste
        jmp return
return:
        ret

UP ENDP

DOWN PROC                   ;move avatar para baixo verificando parede

        mov al, POSy
        mov POSud, al       ;guarda POSy numa var de test
        inc POSud           ;incrementa a var de teste

        goto_xy	POSx,POSud  ;coloco as POS no novo local
        mov 	ah, 08h
        mov		bh,0		;numero da página
        int		10h
        mov		Carn, al	;Guarda o Caracter que está na posição do Curso numa var de teste
        cmp     Carn, 177   ;comparo o caracter de teste com o carater ±. Se for parede salta fora e não mexe o avatar
        je      return

        mov   al, POSud     ;Reset na posiçao do avatar teste
        mov   POSy,al
        mov   al, POSya
        mov   POSud,al      ;Reset na POS de teste
        jmp return
return:
        ret

DOWN ENDP

RIGHT PROC                  ;move avatar para direita verificando parede

        mov al, POSx
        mov POSrl, al       ;guarda POSx numa var de teste
        inc POSrl           ;incrementa var de teste

        goto_xy	POSrl,POSy  ;coloco as POS no novo local
        mov 	ah, 08h
        mov		bh,0		;numero da página
        int		10h
        mov		Carn, al	;Guarda o Caracter que está na posição do Curso numa var de teste
        cmp     Carn, 177   ;comparo o caracter de teste com o carater ±. Se for parede salta fora e não mexe o avatar
        je      return

        mov   al, POSrl     ;Reset na posiçao do avatar teste
        mov   POSx,al
        mov   al, POSxa
        mov   POSrl,al      ;Reset na POS de teste
        jmp return
return:
        ret

RIGHT ENDP

LEFT PROC                   ;move avatar para esquerda verificando parede

        mov al, POSx
        mov POSrl, al       ;guarda POSx numa var de teste
        dec POSrl           ;decrementa var de teste

        goto_xy	POSrl,POSy  ;coloco as POS no novo local
        mov 	ah, 08h
        mov		bh,0		;numero da página
        int		10h
        mov		Carn, al	;Guarda o Caracter que está na posição do Curso numa var de teste
        cmp     Carn, 177   ;comparo o caracter de teste com o carater ±. Se for parede salta fora e não mexe o avatar
        je      return

        mov   al, POSrl     ;Reset na posiçao do avatar teste
        mov   POSx,al
        mov   al, POSxa
        mov   POSrl,al      ;Reset na POS de teste
        jmp return
return:
        ret

LEFT ENDP

;FIM PROCEDIMENTOS MOVIMENTOS DO AVATAR
;########################################################################

;########################################################################
; VERIFICA_CARATER

VERIFICA_CARATER PROC

        mov 	ah, 08h
        mov		bh,0			; numero da página
        int		10h

        CMP al, 'A'
        JB return
        CMP al, 'Z'
        JA return

        lea SI,String_nome
        lea di, String_nomeAux
        lea BP,String_teste


        cmp     Nivel_flag,0
        je      ciclo
        cmp     Nivel_flag,1
        je      sec
        cmp     Nivel_flag,2
        je      thrd
        cmp     Nivel_flag,3
        je      frd
        cmp     Nivel_flag,4
        je      quint

sec:
    add SI,6
    add DI,6
    jmp ciclo

thrd:
    add SI,13
    add DI,13
    jmp ciclo
frd:
    add SI,21
    add DI,21
    jmp ciclo
quint:
    add SI,30
    add DI,30


ciclo:
        MOV bl, byte ptr [SI]
        cmp bl,' '
        je return
        CMP bl, al
        jne c2
        MOV bl, byte ptr [DI]
        cmp bl, '_'
        je c2
        inc found
        mov byte ptr [DI], '_'
        mov String_teste[BP], al
        goto_xy 10,21
        mostra byte ptr[DI]     ; byte ptr[BP] STRING TESTE DÁ ERRO DE PRINT // FIXME
        jmp return
c2:
        inc SI
        inc DI
        inc BP
        loop ciclo


        ;VARIANTE 2
        ;CMP al,String_nome[SI]
        ;JNE return
        ;mov String_teste[SI],al
        ;INC SI
return:

        ret

VERIFICA_CARATER ENDP

;########################################################################
; VERIFICA_STRING

VERIFICA_STRING PROC

        lea BX, String_nomeLen

        cmp Nivel_flag,0
        je  nivel1
        cmp Nivel_flag,1
        je  nivel2
        cmp Nivel_flag,2
        je  nivel3
        cmp Nivel_flag,3
        je  nivel4
        cmp Nivel_flag,4
        je  nivel5
nivel2:
       mov bl, byte ptr [BX+1]
       jmp encontrou
nivel3:
       mov bl, byte ptr [BX+2]
       jmp encontrou
nivel4:
       mov bl, byte ptr [BX+3]
       jmp encontrou
nivel5:
       mov bl, byte ptr [BX+4]
       jmp encontrou
nivel1:
        mov bl , byte ptr [BX]
encontrou:
       mov cl, found
       cmp bl, cl
       jne return
       goto_xy  24,22
       mostra   msg1
       call   PROX_NIVEL
return:
        ret
VERIFICA_STRING ENDP

;########################################################################
; PROX_NIVEL

PROX_NIVEL  proc

        add Nivel_flag,1
        call RESET_STRING
        cmp Nivel_flag,4
        jne continua
        add Ganhou,1
continua:
        call avatar


return:
        ret
PROX_NIVEL  endp

;########################################################################
;RESET_STRING

RESET_STRING    proc

        lea si, Constroi_teste                            ;ds:si aponta Constroi_teste
        lea di, String_teste                          ;ds:di aponta String_teste

;COPIA CONSTROI_TESTE PARA STRING_TESTE
ciclo:
        mov bl, [si];copia origem para destino
	    mov [di], bl
	    inc si;incrementa origem e destino
	    inc di
	    cmp byte ptr [DI],' '
	    jne ciclo;SE NAÕ CHEGOU AO FIM DA STRING_TESTE TORNA A COPIAR


return:
        ret
RESET_STRING    endp

VITORIA         proc
            call        APAGA_ECRAN
            goto_xy	    0,0
            lea         dx,ganhouf
            call        IMP_FICH
            goto_xy     0,0

            ret
VITORIA         endp

DERROTA         proc
            call        APAGA_ECRAN
            goto_xy	    0,0
            lea         dx,perdeuf
            call        IMP_FICH
            goto_xy     0,0

            ret
DERROTA         endp

lv1             proc

            lea SI,String_nome
            lea bx,Nivel123
            goto_xy	POSx,POSy		; Vai para nova possição (3,3)
            mov 	ah, 08h		; Guarda o Caracter que está na posição do Cursor
            mov		bh,0			; numero da página
            int		10h
            mov		Car, al			; Guarda o Caracter que está na posição do Cursor
            mov		Cor, ah			; Guarda a cor que está na posição do Cursor
            goto_xy	    10,20
            mostra      byte ptr [SI]
            goto_xy 24,22
            mostra  msg2
            goto_xy 20,0
            mostra  byte ptr[BX]

            ret
lv1             endp

lv2             proc
            lea SI,String_nome
            lea bx,Nivel123
            CALL    delay       ;chama procedimento , com delay de 3 s, para mostrar mensagem
            mov     found,0
            mov     POSx,3
            mov     POSy,3
            goto_xy	POSx,POSy   ;Retoma posição do cursor
            goto_xy	    10,20
            mostra      byte ptr [SI+6]
            goto_xy 24,22
            mostra  msg2
            goto_xy 20,0
            mostra  byte ptr[BX+8]

            ret

lv2             endp

lv3             proc
            lea SI,String_nome
            lea bx,Nivel123
            CALL    delay       ;chama procedimento , com delay de 3 s, para mostrar mensagem
            mov     found,0
            mov     POSx,3
            mov     POSy,3
            goto_xy	POSx,POSy   ;Retoma posição do cursor
            goto_xy	    10,20
            mostra      byte ptr [SI+13]
            goto_xy 24,22
            mostra  msg2
            goto_xy 20,0
            mostra  byte ptr[BX+16]

            ret

lv3             endp

lv4             proc

            lea SI,String_nome
            lea bx,Nivel123
            CALL    delay       ;chama procedimento , com delay de 3 s, para mostrar mensagem
            mov     found,0
            mov     POSx,3
            mov     POSy,3
            goto_xy	POSx,POSy   ;Retoma posição do cursor
            goto_xy	    10,20
            mostra      byte ptr [SI+21]
            goto_xy 24,22
            mostra  msg2
            goto_xy 20,0
            mostra  byte ptr[BX+24]

            ret

lv4             endp

lv5             proc

            lea SI,String_nome
            lea bx,Nivel123
            CALL    delay       ;chama procedimento , com delay de 3 s, para mostrar mensagem
            mov     found,0
            mov     POSx,3
            mov     POSy,3
            goto_xy	POSx,POSy   ;Retoma posição do cursor
            goto_xy	    10,20
            mostra      byte ptr [SI+30]
            goto_xy 24,22
            mostra  msg2
            goto_xy 20,0
            mostra  byte ptr[BX+32]

            ret

lv5             endp

;########################################################################
;MAIN

Main  proc
        MOV     	AX,DSEG
        MOV     	DS,AX
        MOV			AX,0B800H
        MOV			ES,AX		; ES É PONTEIRO PARA MEM VIDEO

MENU:
        CALL 		APAGA_ECRAN
        lea         dx,menu1
        call        IMP_FICH
        MOV         AH,07h      ;espera input utilizador
        int         21h
        cmp         AL,'1'
        je          jogo
        cmp         AL,'2'
        je          jogo
        cmp         AL,'3'
        je          fim
        jmp        MENU

jogo:
        call        APAGA_ECRAN
        goto_xy	    0,0
        lea         dx,labi
        call        IMP_FICH
        call        AVATAR
        goto_xy	    0,22

 fim:
	    mov al, 0
		mov			ah,4CH
		INT			21H
Main	endp




Cseg	ends
end	Main