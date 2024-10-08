;	Lara Filipa da Silva Bizarro - 2021130066

;	[TAC] ANO LECTIVO 2022/2023

.8086
.model small
.stack 2048

dseg	segment para public 'data'

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo_mor.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		
		;-------------------------------------------------------------------------------
		;Váriaveis criadas por nós
		FicheiroInicial db 'intro.TXT',0
		
		Menu			db 10,13,'				 Menu				',10,13
						db '  1. Jogar contra pessoa',10,13
						db '  2. Jogar contra computador',10,13
						db '  3. Sair','$',10,13
		
		NomeJogadorUm   db 100 dup('$')
		NomeJogadorDois db 100 dup('$')
		
		NumJogador		db 1
		NumTabuleiro    db 1
		
		MsgNomeUm       db 'Nome do primeiro jogador:  $', 10,13
		MsgNomeDois     db 'Nome do segundo jogador:  $',10,13 
		MsgIntro        db 'Vez do Jogador $' 
		MsgVenceTab		db 'Venceu o tabuleiro $'
		MsgVenceJogo	db 'Ganhou! Parabens Jogador $'
		MsgJogador      db 'Jogador $'
		MsgEmpateJogo   db 'EMPATE!!!! $'
		MsgVazio     db '                                     $'
		
		XO				dw 584Fh
		GuardaAlX		dw 0058h
		GuardaAlO  		dw 004fh
		AuxCaracter		db 'X'
		AuxJogador      db 1
		
		Tabuleiro1      byte 3 dup(3 dup('_')) 
		Tabuleiro2      byte 3 dup(3 dup('_'))
		Tabuleiro3      byte 3 dup(3 dup('_')) 
		Tabuleiro4      byte 3 dup(3 dup('_')) 
		Tabuleiro5      byte 3 dup(3 dup('_')) 
		Tabuleiro6      byte 3 dup(3 dup('_')) 
		Tabuleiro7      byte 3 dup(3 dup('_')) 
		Tabuleiro8      byte 3 dup(3 dup('_')) 
		Tabuleiro9      byte 3 dup(3 dup('_')) 
		
		EstadoTabuleiro byte 9 dup('_') ;para guardar 1 se o jogador1 ganhou o tabuleiro, 2 se o jogador2 ganhou o tabuleiro, 0 se empate
		
		Px				db 3
		Py				db 3

		CorMenu			db 1fh
		CorTab          db 00001111b
		
		FlagJogo        db 01
		FlagEmpate      db 00
		
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;guarda no tabuleiro correspondente
;ARRAY É SEGUIDO GUARDADO NA MEMORIA!!!
Index_Array macro Px,Py
	
	LOCAL ComparaX,ComparaY,IncrementaX,IncrementaY,fim
	;limpar tudo
	xor si,si
	xor ax,ax
	xor bx,bx

	mov bl,POSx
	mov al,Px
	
	mov bh,POSy
	mov ah,PY
	
	jmp ComparaX

IncrementaY:	
	add si, 03h
	add ah, 01h
	jmp ComparaY
	
IncrementaX:
	inc si
	add al, 02h
	jmp ComparaX

ComparaX:
	cmp al,bl
	jne IncrementaX
	
ComparaY:
	cmp bh, ah
	jne IncrementaY
fim:
	
endm

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

; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
       ; lea     dx,Fich
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

; LE UMA TECLA	

LE_TECLA	PROC
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

; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:			
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
	
			goto_xy	POSx,POSy	; Vai para posição do cursor
		
LER_SETA:
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27		; ESCAPE
			JE		FIM
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
		
	cmp		cl, 5fh		; Só escreve se for _ ->5fh	
	JNE 	LER_SETA
	
	;if else -> verificar se é O ou X
	mov cx, GuardaAlX
	cmp ch, NumJogador
	je VerificaJogada
	
	
	mov cx,GuardaAlO
	je VerificaJogada
	
VerificaJogada:
	cmp cl,al
	je Continua
	jne LER_SETA

Continua:
	mov AuxCaracter,al
	mov		ah, 02h		; coloca o caracter lido no ecra
	mov		dl, al
	int		21H	
	
	call TABULEIRO
	xor dl, dl
	
	cmp Flagjogo,00
	je fim
	goto_xy	POSx,POSy
	call  MENSAGEM_VEZ_JOGADOR
	goto_xy 0,0
	jmp		LER_SETA

ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

fim:				
			RET
AVATAR		endp

 MENSAGEM_VEZ_JOGADOR proc
	cmp NumJogador, 01h
	je JogadorUm
	jne JogadorDois
	
JogadorUm:		
	goto_xy 33, 16
	inc NumJogador
	lea dx, NomeJogadorUm+2
	mov ah,09h
	int 21h
	jmp Fim
	
JogadorDois:		
	goto_xy 33, 16
	dec NumJogador
	lea dx, NomeJogadorDois+2
	mov ah,09h
	int 21h

Fim:
	goto_xy 33, 15
	lea dx,MsgIntro
	mov ah,09h
	int 21h
	
	mov ah,02h
	mov dl, NumJogador
	add dl,'0'
	int 21h
	
	ret
 MENSAGEM_VEZ_JOGADOR endp

;Mudar cor de fundo do ecrã
MUDAR_COR_ECRA proc
	
	mov ah,00
	mov al,03
	int 10h
	
	mov ah,09
	mov bh,00
	mov al,20h
	mov cx,800h
	mov bl,CorMenu
	int 10h
	
	ret
MUDAR_COR_ECRA endp


LINHA proc
	;Para manter o estado de td
	PUSHF
	PUSH DI
	;PUSH AX,BX,CX,DX
	xor ax,ax
	
Linha1:
	cmp si,02h
	ja Linha3
	jbe IfLinha
	
Linha2:
	add di,3
	jmp IfLinha
	
Linha3:
	cmp si,06h
	jb Linha2
	add di,6
	jae IfLinha
	
IfLinha:
	mov al,[di];0
	mov ah,[di]+1;1
	
	cmp al, 5fh
	je Fim
	cmp ah, 5fh
	je Fim
	cmp ah,bl
	je Igual
	
	mov al,[di]+2;2
	cmp al,ah
	jne Fim
	je Igual
	
IGUAL:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
Fim:
	;POP DX,CX,BX,AX
	POP DI
	POPF
	ret
LINHA endp

;Verificação da coluna
COLUNA proc
	PUSHF
	PUSH DI
	
	xor ax,ax
	xor bx,bx

	cmp si,0
	je IfColuna
	cmp si,3
	je	IfColuna
	cmp si,6
	je IfColuna
	
	add di,01
	cmp si,1
	je	IfColuna
	cmp si,4
	je IfColuna
	cmp si,7
	je	IfColuna
	
	add di,01
	cmp si,2
	je IfColuna
	cmp si,5
	je	IfColuna
	cmp si,8
	
IfColuna:
	mov al,[di];0
	mov ah,[di]+3;3
	
	cmp al, 5fh
	je Fim
	cmp ah,5fh
	je Fim
	cmp al,ah
	jne Fim
	
	mov al,[di]+6;6
	cmp ah,al
	jne Fim
	je Igual
	
Igual:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
	
Fim:
	POP DI
	POPF
	ret

COLUNA endp

DIAGONAL proc
	PUSHF
	PUSH DI
	xor ax,ax
	
IfDiagonal:
	mov al,[di];0
	mov ah,[di]+4;4
	
	cmp al, 5fh
	je ElseDiagonal
	cmp ah, 5fh
	je ElseDiagonal
	cmp al,ah
	jne ElseDiagonal
	
	mov ah,[di]+8;8
	cmp al,ah
	jne ElseDiagonal
	je Igual

ElseDiagonal:
	mov al,[di]+2;0
	mov ah,[di]+4;4
	
	cmp al, 5fh
	je Fim
	cmp ah, 5fh
	je Fim
	cmp al,ah
	jne Fim
	
	mov al,[di]+6;8
	cmp al,ah
	jne Fim
	je IGUAL

Igual:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
Fim:
	POP DI
	POPF
	ret
	
DIAGONAL endp

ATUALIZA_ESTADO_JOGO proc
	PUSHF
	PUSH SI
	PUSH AX
	xor si,si
	xor cl,cl
	
	mov ah,AuxJogador
	mov al,NumTabuleiro
	dec al

	mov cx,08
	mov bl,0
CicloSi:	
	cmp al,bl
	je Copia
	inc si
	inc bl
	LOOP CicloSi
	
Copia:
	mov EstadoTabuleiro[si],ah
	
Continua:
	
	goto_xy 04,17
	lea dx, MsgJogador
	mov ah,09h
	int 21h
	
	goto_xy 13,17
	mov ah,02h
	mov dl,AuxJogador
	add dl, '0'
	int 21h
	
	goto_xy 04,18
	lea dx, MsgVenceTab
	mov ah,09h
	int 21h
	
	goto_xy 23,18
	mov ah,02h
	mov dl,NumTabuleiro
	add dl, '0'
	int 21h
	
	call ESTADO_JOGO
	
	POP AX
	POP SI
	POPF
	ret
ATUALIZA_ESTADO_JOGO endp

VERIFICA_EMPATE proc
	PUSHF 
	PUSH DI
	
	xor ax,ax
	xor cx,cx
	
	mov cx,09
CicloDi:
	mov al, [di]
	cmp al,5fh
	je FIM
	inc di
	LOOP CicloDi
	
MOV cx,09
mov si,08
CicloSi:
	cmp NumTabuleiro,cl
	je Empate
	dec si
	LOOP CicloSi

Empate:
	mov  ax,0B800h ;Memóra de Video
    mov  es,ax
    
	call COORDENADAS_VIDEO

    mov     ax, 1003h
    mov     bx, 0   
    int     10h

	mov ch,2
	mov cl,3
	mov CorTab,01110000b
	mov ah,CorTab;cizento com branco
	
ciclo:
    cmp cl,00
	je ciclol
    mov byte ptr ES:[DI+1], ah
    add di, 4
	dec cl
	jmp ciclo
	
ciclol:
	SUB DI,12
	cmp ch,00
	je fim_ciclo
    mov byte ptr ES:[DI+1], ah 
    add di, 160
	dec ch
	MOV cl,3
	jmp ciclo

fim_ciclo:

	goto_xy 04,17
	lea dx,MsgVazio
	mov ah,09h
	int 21h
	
	goto_xy 04,18
	lea dx,MsgVazio
	mov ah,09h
	int 21h
	
	goto_xy 04,17
	lea dx, MsgEmpateJogo
	mov ah,09h
	int 21h
	
	mov EstadoTabuleiro[si],0
	call ESTADO_JOGO
	
FIM:
	POP DI
	POPF 
	ret
VERIFICA_EMPATE endp

COORDENADAS_VIDEO proc
	cmp NumTabuleiro,1
    mov di, 328
	je continua
	
	cmp NumTabuleiro,2
    mov di, 346
	je continua
	
	cmp NumTabuleiro,3
    mov di, 364
	je continua
	
	cmp NumTabuleiro,4
    mov di, 968
	je continua
	
	cmp NumTabuleiro,5
    mov di, 986
	je continua
	
	cmp NumTabuleiro,6
    mov di, 1004
	je continua
	
	cmp NumTabuleiro,7
    mov di, 1608
	je continua
	
	cmp NumTabuleiro,8
    mov di, 1626	
	je continua
	
	cmp NumTabuleiro,9
    mov di, 1644
	je continua
continua:ret
COORDENADAS_VIDEO endp

ESTADO_JOGO proc
	xor si,si
	xor ax,ax
	xor cx,cx

	call JOGO_LINHA
	call VCOLUNA
	call VDIAGONAL
	
	xor ax,ax
	xor si,si
	mov cx,08
	
JogoTabVazio:
	cmp EstadoTabuleiro[si],5fh
	je FIM
	inc si
	LOOP JogoTabVazio
	
	xor si,si
	mov cx,08	
JogoEmpatado:
	cmp EstadoTabuleiro[si],0
	je AcabaJogo
	inc si
	LOOP JogoEmpatado
	
	xor si,si
	mov cx,08
JogoUm:
	cmp EstadoTabuleiro[si], 1
	je IgualUm
	inc si
	LOOP JogoUm
IgualUm:
	inc al
	inc si
	jmp JogoUm
	
	xor si,si
	mov cx,08
JogoDois:
    cmp EstadoTabuleiro[si], 2
	je IgualDois
	inc si	
	LOOP JogoDois
	
IgualDois:
    inc ah
	inc si
    jmp JogoDois 
	
    cmp al,ah
    jb VenceJogador2
    mov NumJogador,1
    ja AcabaJogo
    je Empatou

VenceJogador2:
    mov NumJogador,2
    jmp AcabaJogo

Empatou:
	mov Flagjogo, 00
	mov FlagEmpate,01
	
AcabaJogo:
	mov Flagjogo,00
FIM:ret
ESTADO_JOGO endp
	
	
JOGO_LINHA proc
	xor si,si
	xor ax,ax
	xor cx,cx
	mov cx,00
CICLO:
	cmp cx,03
	JE FIM
	mov al,EstadoTabuleiro[si]
	inc si
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSELINHA
	cmp ah,0
	je VELSELINHA
	cmp al,5fh
	je VELSELINHA
	cmp ah,5fh
	je VELSELINHA
	cmp al,ah
	jne VELSELINHA
	
	inc si
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	inc si
	inc cx
	jne CICLO
	
VELSELINHA:
	add si,2
	jmp CICLO
GANHOU:
	mov Flagjogo,00
FIM:
	ret
JOGO_LINHA endp


VCOLUNA proc
	xor si,si
	xor ax,ax
	xor cx,cx
	mov cx,00
CICLO:
	cmp cx,03
	JE FIM
	mov al,EstadoTabuleiro[si]
	add si,03
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSECOLUNA
	cmp ah,0
	je VELSECOLUNA
	cmp al,5fh
	je VELSECOLUNA
	cmp ah,5fh
	je VELSECOLUNA
	cmp al,ah
	jne VELSECOLUNA
	
	add si,03
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	sub si,05
	inc cx
	jne CICLO
	
VELSECOLUNA:
	sub si,02
	jmp CICLO
	
GANHOU:
	mov Flagjogo,00

FIM:
	ret
VCOLUNA endp

VDIAGONAL proc
	xor si,si
	xor ax,ax
	xor cx,cx

	mov al,EstadoTabuleiro[si]
	add si,04
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSEDIAGONAL
	cmp ah,0
	je VELSEDIAGONAL
	cmp al,5fh
	je VELSEDIAGONAL
	cmp ah,5fh
	je VELSEDIAGONAL
	cmp al,ah
	jne VELSEDIAGONAL
	
	add si,04
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	
VELSEDIAGONAL:
	MOV SI,0
	add si,02
	mov al,EstadoTabuleiro[si]
	add si,02
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je FIM
	cmp ah,0
	je FIM
	cmp al,5fh
	je FIM
	cmp ah,5fh
	je FIM
	cmp al,ah
	jne FIM
	
	add si,02
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	jne FIM
	
GANHOU:
	mov Flagjogo,00

FIM:ret
VDIAGONAL endp
	

MUDA_COR proc
	PUSHF
    PUSH di
    xor di,di
    xor ax,ax
	xor bx,bx

    mov   ax,0B800h ;Memóra de Video
    mov   es,ax
    
    cmp NumTabuleiro,1
    mov di, 328
    je BLINK
	
	cmp NumTabuleiro,2
    mov di, 346
    je BLINK
	
	cmp NumTabuleiro,3
    mov di, 364
    je BLINK

	cmp NumTabuleiro,4
    mov di, 968
    je BLINK
	
	cmp NumTabuleiro,5
    mov di, 986
    je BLINK
	
	cmp NumTabuleiro,6
    mov di, 1004
    je BLINK
	
	cmp NumTabuleiro,7
    mov di, 1608
    je BLINK
	
	cmp NumTabuleiro,8
    mov di, 1626
    je BLINK	
	
	cmp NumTabuleiro,9
    mov di, 1644
    je BLINK
	
BLINK:	
    ; disable blinking
    mov     ax, 1003h
    mov     bx, 0   
    int     10h
    
	mov CorTab,10011111b ;azul
	mov ah, CorTab
    mov al,AuxCaracter
	cmp al, 58H
	je CONTINUA
	jne MUDACOR
	
MUDACOR:
	mov CorTab,10100000b;verde
	mov ah, CorTab 
	
CONTINUA:
	mov ch,2
	mov cl,3
	
ciclo:
    cmp cl,00
	je ciclol
    mov byte ptr ES:[DI],  AL;Letra em ASCII
    mov byte ptr ES:[DI+1], ah ;Atributos
    add di, 4
	dec cl
	jmp ciclo
	
ciclol:
	SUB DI,12
	cmp ch,00
	je fim_ciclo
	mov byte ptr ES:[DI],  AL;Letra em ASCII
    mov byte ptr ES:[DI+1], ah ;Atributos
    add di, 160
	dec ch
	MOV cl,3
	jmp ciclo

fim_ciclo:
    
    POP di
    POPF
    ret
MUDA_COR endp

;Dá o tabuleiro em q se encontra segundo as coordenadas
TABULEIRO proc
	
	xor si,si
	xor di,di
	mov al, NumJogador
	mov AuxJogador,al
	
Coluna1:
	cmp POSx,08h
	jbe Linha1
	ja  Coluna2
	
Linha1:
	cmp POSy,04h
	ja Linha2
	Index_Array 04h,02h
	mov Tabuleiro1[si],dl
	mov NumTabuleiro, 01
	
	lea di, Tabuleiro1
	;call PRINT_ARRAY
	jmp CONTINUA

Linha2:
	cmp POSy,08h
	ja Linha3
	Index_Array 04h,06h
	mov Tabuleiro4[si],dl
	mov NumTabuleiro, 04
		
	lea di, Tabuleiro4
	jmp CONTINUA
	
Linha3:
	Index_Array 04h,0Ah ;10 decimal
	mov Tabuleiro7[si],dl
	mov NumTabuleiro, 07
	
	lea di, Tabuleiro7
	jmp CONTINUA
	
Coluna2:
	cmp POSx, 11h ;17 decimal
	ja Coluna3
	cmp POSy,04h
	ja Linha22
	
	Index_Array 0dh,02h ;13 decimal
	mov Tabuleiro2[si],dl
	mov NumTabuleiro, 02

	lea di, Tabuleiro2
	jmp CONTINUA

Coluna3:
	cmp POSy,04h
	ja  Linha23
	
	Index_Array 16h,02h ;22 decimal
	mov Tabuleiro3[si],dl
	mov NumTabuleiro,03
	
	lea di, Tabuleiro3
	jmp CONTINUA
	
Linha22:
	cmp POSy,08h
	ja Linha32
	
	Index_Array 0dh,06h
	mov Tabuleiro5[si],dl
	mov NumTabuleiro,05
	
	lea di, Tabuleiro5
	jmp CONTINUA

Linha32:
	Index_Array 0dh,0ah
	mov Tabuleiro8[si],dl
	mov NumTabuleiro,08
	
	lea di, Tabuleiro8
	jmp CONTINUA

Linha23:
	cmp POSy,08h
	ja Linha33
	
	Index_Array 16h,06h
	mov Tabuleiro6[si],dl
	mov NumTabuleiro,06
	
	lea di, Tabuleiro6
	jmp CONTINUA
Linha33:
	Index_Array 16h,0ah
	mov Tabuleiro9[si],dl
	mov NumTabuleiro,09
	
	lea di, Tabuleiro9
	jmp CONTINUA

CONTINUA:		
	call LINHA
	call COLUNA
	call DIAGONAL
	call VERIFICA_EMPATE
	jmp sair
sair:	

	ret
TABULEIRO endp

;Gera número aleatório-> mesmo funcionamento de qqr random noutra linguagem
RANDOM proc
	
	call ESPERA
	mov ah,0h
	int 1ah ;hora do sistema-> cx high part clock count;dx low part clock count
	mov ax,dx ;interessa dx
	mov dx,0
	mov bx, 2 ;pq queremos um número entre 0 e 1 (logo são 2 números)
	div bx ;divide AX(oq estava no relógio (low)) por BX(2)
	mov NumJogador,dl ;resto=num aleatório
	
	ret
RANDOM endp

;Para não dar sempre 1, faz se um delay.  
;Função q n faz nada, só queima tempo
ESPERA proc
	mov cx,1
inicio:
	cmp cx,30000
	je fim
	inc cx
	jmp inicio
fim:
	ret
ESPERA endp

RANDOMXO proc
	
	call ESPERA
	mov ah,0h
	int 1ah ;hora do sistema-> cx high part clock count;dx low part clock count
	mov ax,dx ;interessa dx
	mov dx,0
	mov bx, 2 ;pq queremos um número entre 0 e 1 (logo são 2 números)
	div bx ;divide AX(oq estava no relógio (low)) por BX(2)
	cmp dl, 01
	mov cx, XO
	je  MOSTRAX
	jne MOSTRAO

MostraX:
	mov GuardaAlX,158h
	mov GuardaAlO,24fh
	;call REGRAS_JOGADORES_MENSAGEM
	jmp Mensagem
	
MostraO:
	mov GuardaAlX,258h
	mov GuardaAlO,14fh

	;call REGRAS_JOGADORES_MENSAGEM
Mensagem:
	goto_xy 35,03
	lea dx, MsgJogador
	mov ah,09h
	int 21h
	
	goto_xy 43,03
	mov bx, GuardaAlX
	
	mov ah,02h
	mov dl, bh
	add dl, '0'
	int 21h
	
	goto_xy 47,03
	mov ah,02h
	mov dl,bl
	int 21h
	
	mov cx, GuardaAlO
	goto_xy 35,02
	lea dx, MsgJogador
	mov ah,09h
	int 21h
	
	goto_xy 43,02
	mov ah,02h
	mov dl, ch
	add dl, '0'
	int 21h
	
	goto_xy 47,02
	mov ah,02h
	mov dl,cl
	int 21h
Fim:ret
RANDOMXO endp

;Receber nome e mostrar nome do jogador
INTRO_NOME proc
		
	;Mostra mensagem inicial
	lea dx, MsgNomeUm
	mov ah,09h
	int 21h
	
	;Lê input
	mov ah,0ah
	lea dx,NomeJogadorUm
	int 21h	
	
	;Mostra mensagem inicial
	goto_xy 5,3
	lea dx, MsgNomeDois
	mov ah,09h
	int 21h
	
	;Lê input
	mov ah,0ah
	lea dx,NomeJogadorDois
	int 21h
	
	ret	
INTRO_NOME endp

Main  proc
	mov			ax, dseg
	mov			ds,ax
	
	mov			ax,0B800h
	mov			es,ax
	

	call apaga_ecran
	
	;Mosra ecrã inicial
	mov CorMenu,04eh
	call MUDAR_COR_ECRA
	lea dx, FicheiroInicial
	call IMP_FICH
	
	;espera por uma tecla
	mov ah,01h
	int 21h
	
Inicio:	
	call apaga_ecran
	goto_xy	5,1
	
	mov CorMenu,1fh
	call MUDAR_COR_ECRA
	lea dx,Menu ;lê menu	
	mov ah,09h ;mostra menu
	int 21h
	
ValidacaoMenu:
	call LE_TECLA
	sub al,48 ;tabela ascii 49->1, 50->2...
	cmp al,01h 
	je 	JogaPessoa
	cmp al,02h
	je  JogaComputador
	cmp	al,03h
	je	Fim
	jne ValidacaoMenu

JogaPessoa:
	call apaga_ecran
	goto_xy		5,1
	
	call INTRO_NOME
	call apaga_ecran
	goto_xy    0,0
	
	lea dx, Fich
	call IMP_FICH
	call RANDOM
	inc NumJogador ;só existe jogador 1 e 2 
	call MENSAGEM_VEZ_JOGADOR
	call RANDOMXO
	
Continua:
	mov FlagJogo,01
	call AVATAR
	
	cmp FlagEmpate, 01
	je MensagemEmpate
	cmp FlagJogo,00
	JE MensagemFinal
	jne Continua
	
MensagemFinal:
	call apaga_ecran
	goto_xy 25,12
	mov ah,09h
	lea dx, MsgVenceJogo	
	int 21h
	
	goto_xy 54,12
	mov ah,02h
	mov dl,NumJogador
	add dl,'0'
	int 21h
	
	call LE_TECLA
	jmp Inicio
	
MensagemEmpate:
	call apaga_ecran
	goto_xy 28,12
	mov ah,09h
	lea dx, MsgEmpateJogo
	int 21h
	call LE_TECLA
	jmp Inicio
	
JogaComputador:


Fim:
	call apaga_ecran
	mov	 ah,4CH
	int	 21H
Main	endp
Cseg	ends
end	Main