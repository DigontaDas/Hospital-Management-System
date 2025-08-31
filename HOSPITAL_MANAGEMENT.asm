.MODEL SMALL

 
.STACK 100H

.DATA

; declare variables here
;MENU Prompts      
main_menu db 10,13,'========================= HOSPITAL MANAGEMENT SYSTEM ===========================$'
menu1 db 10,13,'1. Register New Patient$'
menu2 db 10,13,'2. Disease Select$'
menu3 db 10,13,'3. Discharge$'
menu4 db 10,13,'4. Patient Details$'
menu5 db 10,13,'5. Report$'
menu6 DB 10,13,'6. Exit$'

menuerror db 'Wrong input. Please try again$'  
menu_prompt db 'Enter a choice: $'
input db ?
    
;CLEAR
clear db '#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX#$'
    
;;;;;;;;;;;;;;;;;;;;;;Variables;;;;;;;;;;;;;;;;;;;

;register patient
registermsg1 db 10,13,'1. Enter Patient Name (ENTER TO END): $'   
registermsg2 db 10,13,'2. Enter Patient Age: $'
registermsg3 db 10,13,'3. Enter Patient Gender (M/F) : $' 
registermsg4 db 10,13,'4. Enter Patient Blood Type (ENTER TO END) : $'    
registermsg5 db 10,13,'Patient is Successfully Registered ! $'    
registration_complete db 10,13,'Press any key to return to main menu...$'

; Error messages
age_error db 10,13,'Error: Please enter exactly 2 digits for age! $'
gender_error db 10,13,'Error: Please enter M or F only! $'
no_patient_error db 10,13,'Error: Please register a patient first!$'
    
; Disease Selection Messages
disease_menu db 10,13,'========================= DISEASE SELECTION ===========================$'
disease1 db 10,13,'1. Fever$'
disease2 db 10,13,'2. Cold/Flu$'
disease3 db 10,13,'3. Headache$'
disease4 db 10,13,'4. Stomach Pain$'
disease5 db 10,13,'5. Heart Problem$'
disease6 db 10,13,'6. Diabetes$'
disease7 db 10,13,'7. Other (Specify)$'
disease_prompt db 10,13,'Select disease (1-7): $'
other_disease_msg db 10,13,'Enter disease name: $'
disease_selected_msg db 10,13,'Disease selected successfully!$'
disease_error db 10,13,'Invalid choice! Please select 1-7.$'

NEWLINE DB 0DH,0AH,'$' 
SPCAE DB "$"       

;;;;;;;;;;;;;;;;;;;;;DATA STORE;;;;;;;;;;;;;;;;;;;;
;patient data    
MAX_PATIENT DB 5    
PATIENT_NAME DB MAX_PATIENT*30 DUP(0), '$'
PATIENT_AGE DB 0
PATIENT_GENDER DB 0   ;M OR F
PATIENT_BLOOD  DB MAX_PATIENT*4 DUP(0),'$' ; A+ OR O+ OR AB+
PATIENT_ID DW 1001 
PATIENT_REGISTERED DB 0 ;REG OR NOT  

;disease data
DISEASE_ARRAY DB 'Fever          $'
              DB 'Cold/Flu       $'  
              DB 'Headache       $'
              DB 'Stomach Pain   $'
              DB 'Heart Problem  $'
              DB 'Diabetes       $'


.CODE

NEWLINE_PROC PROC
    LEA DX, NEWLINE
    MOV AH, 9
    INT 21H
    RET
NEWLINE_PROC ENDP  

CLEAR_SCREEN PROC
    CALL NEWLINE_PROC
    LEA DX, CLEAR
    MOV AH, 9
    INT 21H
    RET
CLEAR_SCREEN ENDP

MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here
MENU:
CALL CLEAR_SCREEN
LEA DX, MAIN_MENU
MOV AH,9
INT 21H
LEA DX, MENU1
MOV AH,9
INT 21H
    
LEA DX, MENU2
MOV AH,9
INT 21H
    
LEA DX, MENU3
MOV AH,9
INT 21H
    
LEA DX, MENU4
MOV AH,9
INT 21H
    
LEA DX, MENU5
MOV AH,9
INT 21H
    
LEA DX, MENU6
MOV AH,9
INT 21H

CALL NEWLINE_PROC
LEA DX, MENU_PROMPT
MOV AH,9
INT 21H 
;CHOICES
MOV AH,1
INT 21H
MOV INPUT, AL
CMP AL, '1'
JE REGISTER
CMP AL, '2'
JE DISEASE_SELECT
CMP AL, '6'
JE EXIT
;ERROR
LEA DX, MENUERROR
MOV AH,9
INT 21H      

CALL NEWLINE_PROC
LEA DX, REGISTRATION_COMPLETE
MOV AH,9
INT 21H
MOV AH,1
INT 21H
JMP MENU
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;                      REGISTER                        ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

REGISTER:   
GEN_ID:
MOV AX,PATIENT_ID
INC PATIENT_ID

NAME:
LEA DX, registermsg1
MOV AH,9
INT 21H

LEA SI,PATIENT_NAME
MOV CX,0

NAME_LOOP:
MOV AH,1
INT 21H   

CMP AL,13
JE AGE
 
CMP CX,29
JGE NAME_LOOP
MOV [SI],AL
INC SI
INC CX
JMP NAME_LOOP 

AGE:  
LEA DX, registermsg2
MOV AH,9
INT 21H
  
;FIRST
MOV AH,1
INT 21H  
CMP AL,'0'
JL AGE_ERROR_HANDLER
CMP AL, '9'
JG AGE_ERROR_HANDLER
SUB AL, 30H
MOV BL,AL
 
;SECOND
MOV AH,1
INT 21H  
CMP AL,'0'
JL AGE_ERROR_HANDLER
CMP AL,'9'
JG AGE_ERROR_HANDLER
SUB AL, 30H
MOV BH,AL

MOV AL,BL
MOV AH,10
MUL AH
ADD AL,BH
MOV PATIENT_AGE, AL
JMP GENDER 

AGE_ERROR_HANDLER:
LEA DX, AGE_ERROR
MOV AH, 9
INT 21H
JMP AGE 

GENDER:
LEA DX, registermsg3
MOV AH,9
INT 21H 

MOV AH,1
INT 21H
CMP AL,'a'
JL CHECK_GENDER
CMP AL,'z'
JG CHECK_GENDER
SUB AL, 32

CHECK_GENDER:
CMP AL, 'M'
JE GENDER_VALID 
CMP AL, 'F'
JE GENDER_VALID

;Invalid
LEA DX, GENDER_ERROR
MOV AH,9
INT 21H
JMP GENDER

GENDER_VALID:
MOV PATIENT_GENDER,AL
JMP BLOOD_TYPE

  
BLOOD_TYPE:
LEA DX, registermsg4
MOV AH,9
INT 21H  
LEA SI, PATIENT_BLOOD
MOV CX,0

BLOOD_LOOP:
MOV AH,1
INT 21H
CMP AL, 13
JE EXIT
CMP CX,9
JGE BLOOD_LOOP
MOV [SI],AL
INC SI
INC CX
JMP BLOOD_LOOP 

REGISTRATION_SUCCESS:
MOV PATIENT_REGISTERED, 1  
LEA DX, REGISTERMSG5
MOV AH,9
INT 21H
CALL NEWLINE_PROC
LEA DX, REGISTRATION_COMPLETE
MOV AH,9
INT 21H
MOV AH,1
INT 21H
JMP MENU

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                      DISEASE SELECTION                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISEASE_SELECT:

  

;exit to DOS
EXIT: 


MOV AX,4C00H
INT 21H

MAIN ENDP
END MAIN
