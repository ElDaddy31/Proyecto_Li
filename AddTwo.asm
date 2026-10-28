; =====================================================================
; PROYECTO INTEGRADO: Sistema de Control de Inventario y Ventas - TEOLONGI
; Arquitectura x86 (MASM / Irvine32) - Versión 100% Corregida
; =====================================================================

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

.data
    MAX_PROD        EQU 10
    
    msgTitulo       BYTE 0Ah, 0Dh, "=========================================", 0Ah, 0Dh
                    BYTE "   SISTEMA DE GESTION Y VENTAS TEOLONGI  ", 0Ah, 0Dh
                    BYTE "=========================================", 0Ah, 0Dh, 0

    msgMenu         BYTE 0Ah, 0Dh, "1. Registrar Nuevo Producto", 0Ah, 0Dh
                    BYTE "2. Listar y Buscar Productos", 0Ah, 0Dh
                    BYTE "3. Realizar Venta (Con regla de 2% mayoreo)", 0Ah, 0Dh
                    BYTE "4. Recibir Mercancia (Max 100 unidades)", 0Ah, 0Dh
                    BYTE "5. Mostrar Resumen (Inventario e Ingresos)", 0Ah, 0Dh
                    BYTE "6. Guardar / Cargar Archivo", 0Ah, 0Dh
                    BYTE "7. Salir", 0Ah, 0Dh
                    BYTE "Seleccione una opcion: ", 0
    
    msgOpcionInv    BYTE 0Ah, 0Dh, "Error: Opcion invalida o dato incorrecto.", 0Ah, 0Dh, 0
    msgPedirCod     BYTE "Ingrese codigo (Formato ABC-123): ", 0
    msgPedirNombre  BYTE "Ingrese nombre del producto: ", 0
    msgPedirPrecio  BYTE "Ingrese precio en centavos (ej. 1500 para $15.00): ", 0
    msgPedirStock   BYTE "Ingrese stock inicial (0-100): ", 0
    msgProdLleno    BYTE 0Ah, 0Dh, "Error: Capacidad maxima alcanzada (10 productos).", 0Ah, 0Dh, 0
    msgCodDupl      BYTE 0Ah, 0Dh, "Error: El codigo de producto ya existe.", 0Ah, 0Dh, 0
    msgErrFormato   BYTE 0Ah, 0Dh, "Error: Formato de codigo invalido (Use ABC-123).", 0Ah, 0Dh, 0
    msgMaxStock     BYTE 0Ah, 0Dh, "Error: Supera el limite maximo permitido de 100 unidades.", 0Ah, 0Dh, 0

    msgPedirIndice  BYTE 0Ah, 0Dh, "Ingrese el indice del producto (0 a 9): ", 0
    msgPedirCant    BYTE "Ingrese la cantidad: ", 0
    msgStockInsuf   BYTE 0Ah, 0Dh, "Error: Existencias insuficientes o stock excedido.", 0Ah, 0Dh, 0
    msgVentaExito   BYTE 0Ah, 0Dh, "¡Operacion exitosa!", 0Ah, 0Dh, 0
    msgTotalTxt     BYTE "Importe total ($ MXN): ", 0
    msgDescApli     BYTE "¡Aviso: Se aplico el 2% de descuento por mayoreo!", 0Ah, 0Dh, 0
    
    msgResumenTit   BYTE 0Ah, 0Dh, "=== RESUMEN GENERAL DE LA SESION ===", 0Ah, 0Dh, 0
    msgTotalUnid    BYTE "Total de unidades en inventario: ", 0
    msgValInventario BYTE "Valor total del inventario ($ MXN): ", 0
    msgIngresosAcum BYTE "Ingresos acumulados de la sesion ($ MXN): ", 0

    msgArchivoGuard BYTE 0Ah, 0Dh, "Inventario guardado en archivo correctamente.", 0Ah, 0Dh, 0
    msgArchivoCarg  BYTE 0Ah, 0Dh, "Inventario cargado desde archivo correctamente.", 0Ah, 0Dh, 0
    msgErrorArch    BYTE 0Ah, 0Dh, "Aviso: No se encontro archivo previo. Usando base inicial.", 0Ah, 0Dh, 0

    filename        BYTE "inventario.txt", 0
    fileHandle      HANDLE ?

    ingresosAcumulados DWORD 0
    numProductos    DWORD 4
    
    codigos         BYTE 10 * 12 DUP(0)
    nombres         BYTE 10 * 20 DUP(0)
    precios         DWORD 10 DUP(0)
    stocks          DWORD 10 DUP(0)

    inputBuffer     BYTE 30 DUP(0)
    outBuffer       BYTE 30 DUP(0)

.code
main PROC
    call ClrScr
    call CargarInventarioInicio  

    ; --- INICIALIZACIÓN DEL CATÁLOGO BASE (4 PRODUCTOS CON ABC-123) ---
    mov numProductos, 4

    ; Producto 0: TET-500
    mov edx, OFFSET codigos
    mov byte ptr [edx+0], 'T'
    mov byte ptr [edx+1], 'E'
    mov byte ptr [edx+2], 'T'
    mov byte ptr [edx+3], '-'
    mov byte ptr [edx+4], '5'
    mov byte ptr [edx+5], '0'
    mov byte ptr [edx+6], '0'

    mov esi, OFFSET nombres
    mov byte ptr [esi+0], 'T'
    mov byte ptr [esi+1], 'e'
    mov byte ptr [esi+2], ' '
    mov byte ptr [esi+3], '5'
    mov byte ptr [esi+4], '0'
    mov byte ptr [esi+5], '0'
    mov byte ptr [esi+6], 'm'
    mov byte ptr [esi+7], 'l'

    ; Producto 1: TET-1LT
    mov edx, OFFSET codigos
    add edx, 12
    mov byte ptr [edx+0], 'T'
    mov byte ptr [edx+1], 'E'
    mov byte ptr [edx+2], 'T'
    mov byte ptr [edx+3], '-'
    mov byte ptr [edx+4], '1'
    mov byte ptr [edx+5], 'L'
    mov byte ptr [edx+6], 'T'

    mov esi, OFFSET nombres
    add esi, 16
    mov byte ptr [esi+0], 'T'
    mov byte ptr [esi+1], 'e'
    mov byte ptr [esi+2], ' '
    mov byte ptr [esi+3], '1'
    mov byte ptr [esi+4], ' '
    mov byte ptr [esi+5], 'L'
    mov byte ptr [esi+6], 'i'
    mov byte ptr [esi+7], 't'
    mov byte ptr [esi+8], 'r'
    mov byte ptr [esi+9], 'o'

    ; Producto 2: TET-2LT
    mov edx, OFFSET codigos
    add edx, 24
    mov byte ptr [edx+0], 'T'
    mov byte ptr [edx+1], 'E'
    mov byte ptr [edx+2], 'T'
    mov byte ptr [edx+3], '-'
    mov byte ptr [edx+4], '2'
    mov byte ptr [edx+5], 'L'
    mov byte ptr [edx+6], 'T'

    mov esi, OFFSET nombres
    add esi, 32
    mov byte ptr [esi+0], 'T'
    mov byte ptr [esi+1], 'e'
    mov byte ptr [esi+2], ' '
    mov byte ptr [esi+3], '2'
    mov byte ptr [esi+4], ' '
    mov byte ptr [esi+5], 'L'
    mov byte ptr [esi+6], 'i'
    mov byte ptr [esi+7], 't'
    mov byte ptr [esi+8], 'r'
    mov byte ptr [esi+9], 'o'
    mov byte ptr [esi+10], 's'

    ; Producto 3: TET-5LT
    mov edx, OFFSET codigos
    add edx, 36
    mov byte ptr [edx+0], 'T'
    mov byte ptr [edx+1], 'E'
    mov byte ptr [edx+2], 'T'
    mov byte ptr [edx+3], '-'
    mov byte ptr [edx+4], '5'
    mov byte ptr [edx+5], 'L'
    mov byte ptr [edx+6], 'T'

    mov esi, OFFSET nombres
    add esi, 48
    mov byte ptr [esi+0], 'T'
    mov byte ptr [esi+1], 'e'
    mov byte ptr [esi+2], ' '
    mov byte ptr [esi+3], '5'
    mov byte ptr [esi+4], ' '
    mov byte ptr [esi+5], 'L'
    mov byte ptr [esi+6], 'i'
    mov byte ptr [esi+7], 't'
    mov byte ptr [esi+8], 'r'
    mov byte ptr [esi+9], 'o'
    mov byte ptr [esi+10], 's'

    ; Precios en centavos y stocks iniciales
    mov eax, 1500
    mov [precios+0], eax
    mov eax, 3000
    mov [precios+4], eax
    mov eax, 4500
    mov [precios+8], eax
    mov eax, 9000
    mov [precios+12], eax

    mov eax, 50
    mov [stocks+0], eax
    mov eax, 30
    mov [stocks+4], eax
    mov eax, 20
    mov [stocks+8], eax
    mov eax, 10
    mov [stocks+12], eax

menu_principal:
    mov edx, OFFSET msgTitulo
    call WriteString
    
    call MostrarInventarioMemoria

    mov edx, OFFSET msgMenu
    call WriteString

    mov edx, OFFSET inputBuffer
    mov ecx, 2
    call ReadString
    movzx eax, byte ptr [inputBuffer]
    sub eax, '0'
    
    cmp eax, 1
    je opt_registrar
    cmp eax, 2
    je opt_buscar
    cmp eax, 3
    je opt_venta
    cmp eax, 4
    je opt_recibir
    cmp eax, 5
    je opt_resumen
    cmp eax, 6
    je opt_archivo
    cmp eax, 7
    je opt_salir

    mov edx, OFFSET msgOpcionInv
    call WriteString
    jmp menu_principal

opt_registrar:
    call RegistrarProducto
    jmp menu_principal

opt_buscar:
    call BuscarProductoUI
    jmp menu_principal

opt_venta:
    call RealizarVenta
    jmp menu_principal

opt_recibir:
    call RecibirMercancia
    jmp menu_principal

opt_resumen:
    call MostrarResumen
    jmp menu_principal

opt_archivo:
    call GuardarInventarioArchivo
    jmp menu_principal

opt_salir:
    invoke ExitProcess, 0
main ENDP


RegistrarProducto PROC
    pushad
    
    mov eax, numProductos
    cmp eax, MAX_PROD
    jge error_lleno

    mov edx, OFFSET msgPedirCod
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString

    movzx eax, byte ptr [inputBuffer+3]
    cmp al, '-'
    jne error_formato

    call VerificarDuplicado
    cmp eax, 1
    je error_duplicado

    mov ebx, numProductos
    imul ebx, 12
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET codigos
    add edi, ebx
    mov ecx, 8
    rep movsb

    mov edx, OFFSET msgPedirNombre
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 19
    call ReadString

    mov ebx, numProductos
    shl ebx, 4
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET nombres
    add edi, ebx
    mov ecx, 16
    rep movsb

    mov edx, OFFSET msgPedirPrecio
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt            
    
    mov ebx, numProductos
    mov [precios + ebx*4], eax

    mov edx, OFFSET msgPedirStock
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt

    cmp eax, 100
    jg error_stock_limite
    
    mov ebx, numProductos
    mov [stocks + ebx*4], eax

    inc numProductos
    mov edx, OFFSET msgVentaExito
    call WriteString
    jmp fin_reg

error_lleno:
    mov edx, OFFSET msgProdLleno
    call WriteString
    jmp fin_reg

error_formato:
    mov edx, OFFSET msgErrFormato
    call WriteString
    jmp fin_reg

error_duplicado:
    mov edx, OFFSET msgCodDupl
    call WriteString
    jmp fin_reg

error_stock_limite:
    mov edx, OFFSET msgMaxStock
    call WriteString
    jmp fin_reg

fin_reg:
    popad
    ret
RegistrarProducto ENDP


VerificarDuplicado PROC
    push ecx
    push esi
    push edi
    
    xor eax, eax            
    mov ecx, numProductos
    xor esi, esi            

ciclo_dup:
    push ecx
    mov edx, OFFSET codigos
    mov eax, esi
    imul eax, 12
    add edx, eax            

    mov edi, OFFSET inputBuffer
    call CompararCadenas
    cmp eax, 1
    je es_duplicado

    pop ecx
    inc esi
    loop ciclo_dup
    xor eax, eax
    jmp fin_dup

es_duplicado:
    pop ecx
    mov eax, 1

fin_dup:
    pop edi
    pop esi
    pop ecx
    ret
VerificarDuplicado ENDP

CompararCadenas PROC
    push esi
    push edi
    mov esi, edx
    mov edi, OFFSET inputBuffer
comp_loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne no_iguales
    cmp al, 0
    je iguales
    inc esi
    inc edi
    jmp comp_loop
iguales:
    mov eax, 1
    jmp fin_comp
no_iguales:
    xor eax, eax
fin_comp:
    pop edi
    pop esi
    ret
CompararCadenas ENDP


MostrarInventarioMemoria PROC
    pushad
    mov ecx, numProductos
    xor esi, esi            

ciclo_mostrar:
    push ecx
    
    mov eax, esi
    call IntToString            
    mov edx, OFFSET outBuffer
    call WriteString
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    mov edx, OFFSET codigos
    mov eax, esi
    imul eax, 12
    add edx, eax
    call WriteString
    mov al, ' '
    call WriteChar

    mov edx, OFFSET nombres
    mov eax, esi
    shl eax, 4              
    add edx, eax
    call WriteString
    mov al, ' '
    call WriteChar

    mov edx, OFFSET stocks
    mov eax, [edx + esi*4]
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    
    call Crlf
    pop ecx
    inc esi
    loop ciclo_mostrar

    popad
    ret
MostrarInventarioMemoria ENDP


BuscarProductoUI PROC
    pushad
    mov edx, OFFSET msgPedirIndice
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt

    cmp eax, numProductos
    jge error_busq
    cmp eax, 0
    jl error_busq

    mov esi, eax        
    mov edx, OFFSET nombres
    shl eax, 4
    add edx, eax
    call WriteString
    call Crlf
    jmp fin_busq

error_busq:
    mov edx, OFFSET msgOpcionInv
    call WriteString

fin_busq:
    popad
    ret
BuscarProductoUI ENDP


RealizarVenta PROC
    pushad
    mov edx, OFFSET msgPedirIndice
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt
    
    cmp eax, numProductos
    jge venta_error
    cmp eax, 0
    jl venta_error
    mov esi, eax        

    mov edx, OFFSET msgPedirCant
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt
    mov ebx, eax        

    mov edx, OFFSET stocks
    mov ecx, [edx + esi*4]
    cmp ebx, ecx
    jg error_stock

    mov edx, OFFSET precios
    mov eax, [edx + esi*4]  
    mul ebx                 
    
    push eax                

    cmp ebx, 5
    jl sin_desc

    mov edx, OFFSET msgDescApli
    call WriteString

    pop eax                 
    push eax
    mov ecx, 2
    mul ecx                 
    mov ecx, 100
    div ecx                 
    
    mov ecx, eax            
    pop eax                 
    sub eax, ecx            
    push eax                
    jmp mostrar_tot

sin_desc:

mostrar_tot:
    pop eax                 
    add ingresosAcumulados, eax

    mov edx, OFFSET stocks
    mov ecx, [edx + esi*4]
    sub ecx, ebx
    mov [edx + esi*4], ecx

    mov edx, OFFSET msgTotalTxt
    call WriteString

    mov edx, 0
    mov ebx, 100
    div ebx                 
    
    push edx                
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    mov al, '.'
    call WriteChar
    
    pop eax                 
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    call Crlf

    mov edx, OFFSET msgVentaExito
    call WriteString
    jmp fin_ven

error_stock:
    mov edx, OFFSET msgStockInsuf
    call WriteString
    jmp fin_ven

venta_error:
    mov edx, OFFSET msgOpcionInv
    call WriteString

fin_ven:
    popad
    ret
RealizarVenta ENDP


RecibirMercancia PROC
    pushad
    mov edx, OFFSET msgPedirIndice
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt

    cmp eax, numProductos
    jge error_rec
    cmp eax, 0
    jl error_rec
    mov esi, eax            

    mov edx, OFFSET msgPedirCant
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 10
    call ReadString
    call StringToInt
    mov ebx, eax            

    mov edx, OFFSET stocks
    mov ecx, [edx + esi*4]  
    add ecx, ebx            
    
    cmp ecx, 100
    jg error_limite

    mov [edx + esi*4], ecx
    mov edx, OFFSET msgVentaExito
    call WriteString
    jmp fin_rec

error_limite:
    mov edx, OFFSET msgMaxStock
    call WriteString
    jmp fin_rec

error_rec:
    mov edx, OFFSET msgOpcionInv
    call WriteString

fin_rec:
    popad
    ret
RecibirMercancia ENDP


MostrarResumen PROC
    pushad
    mov edx, OFFSET msgResumenTit
    call WriteString

    mov ecx, numProductos
    xor esi, esi
    xor ebx, ebx            

ciclo_unid:
    mov edx, OFFSET stocks
    add ebx, [edx + esi*4]
    inc esi
    loop ciclo_unid

    mov edx, OFFSET msgTotalUnid
    call WriteString
    mov eax, ebx
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    call Crlf

    mov ecx, numProductos
    xor esi, esi
    xor edi, edi            

ciclo_val:
    mov edx, OFFSET stocks
    mov eax, [edx + esi*4]  
    mov edx, OFFSET precios
    mov ebx, [edx + esi*4]  
    mul ebx                 
    add edi, eax            
    inc esi
    loop ciclo_val

    mov edx, OFFSET msgValInventario
    call WriteString

    mov eax, edi            
    mov edx, 0
    mov ebx, 100
    div ebx                 
    
    push edx
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    mov al, '.'
    call WriteChar
    pop eax
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    call Crlf

    mov edx, OFFSET msgIngresosAcum
    call WriteString

    mov eax, ingresosAcumulados
    mov edx, 0
    mov ebx, 100
    div ebx                 

    push edx
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    mov al, '.'
    call WriteChar
    pop eax
    call IntToString
    mov edx, OFFSET outBuffer
    call WriteString
    call Crlf

    popad
    ret
MostrarResumen ENDP


StringToInt PROC
    push ecx
    push edx
    push esi
    
    mov esi, OFFSET inputBuffer
    xor eax, eax
conv_loop:
    movzx edx, byte ptr [esi]
    cmp dl, 0
    je conv_done
    cmp dl, 10          
    je conv_done
    cmp dl, 13          
    je conv_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp conv_loop

conv_done:
    pop esi
    pop edx
    pop ecx
    ret
StringToInt ENDP

IntToString PROC
    pushad
    mov ecx, 10
    mov esi, OFFSET outBuffer
    add esi, 11
    mov byte ptr [esi], 0
    dec esi

    cmp eax, 0
    jne itoa_loop
    mov byte ptr [esi], '0'
    mov edx, esi
    jmp itoa_done

itoa_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [esi], dl
    dec esi
    cmp eax, 0
    jne itoa_loop
    mov edx, esi
    inc edx

itoa_done:
    mov esi, edx
    mov edi, OFFSET outBuffer
mov_str:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne mov_str

    popad
    ret
IntToString ENDP


CargarInventarioInicio PROC
    pushad
    mov edx, OFFSET filename
    call OpenInputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je error_carga_i

    mov eax, fileHandle
    mov edx, OFFSET stocks
    mov ecx, 40             
    call ReadFromFile

    mov eax, fileHandle
    call CloseFile

    mov edx, OFFSET msgArchivoCarg
    call WriteString
    jmp fin_c_i

error_carga_i:
    mov edx, OFFSET msgErrorArch
    call WriteString

fin_c_i:
    popad
    ret
CargarInventarioInicio ENDP

GuardarInventarioArchivo PROC
    pushad
    mov edx, OFFSET filename
    call CreateOutputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je error_arch_g

    mov eax, fileHandle
    mov edx, OFFSET stocks
    mov ecx, 40             
    call WriteToFile

    mov eax, fileHandle
    call CloseFile

    mov edx, OFFSET msgArchivoGuard
    call WriteString
    jmp fin_g

error_arch_g:
    mov edx, OFFSET msgErrorArch
    call WriteString

fin_g:
    popad
    ret
GuardarInventarioArchivo ENDP

END main