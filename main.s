# Milka Kuznetsova
# 347335374

# I wrote the code on Mac, so if there are any weird code lines
# that's because the normal ones didn't come through on Mac :))

.extern _printf
.extern _scanf
.extern _rand
.extern _srand

.section __DATA,__data
tries:
    .long 5
boundary:
    .long 10
counter:
    .long 0
rounds_won:
    .long 0
flag_easy_mode:
    .byte 0

.section __TEXT,__cstring
ask_seed_msg:
    .string "Enter configuration seed: "
ask_guess_msg:
    .string "What is your guess? "
easy_mode_msg:
    .string "Would you like to play in easy mode? (y/n) "
double_mode_msg:
    .string "Double or nothing! Would you like to continue to another round? (y/n) "
incorrect_msg:
    .string "Incorrect. "
guess_above_msg:
    .string "Your guess was above the actual number ...\n"
guess_below_msg:
    .string "Your guess was below the actual number ...\n"
scanf_int:
    .string "%d"
scanf_string:
    .string "%s"
win_msg:
    .string "Congratz! You won %d rounds!"
lose_msg:
    .string "\nGame over, you lost :(. The correct answer was %d "

.section __BSS,__bss
user_input:
    .space 4 # skip 4 doesn't work on Mac
seed:
    .space 4
number:
    .space 4


.section __TEXT,__text
.globl	_main

_main:
    # start
    pushq %rbp
    movq %rsp, %rbp
    
    # printf("Enter configuration seed: ")
        # I use lea because i code on macOS
    leaq ask_seed_msg(%rip), %rdi 
    xorq %rax, %rax
    call _printf

    # scanf("%d") - read the int input for the seed
    leaq scanf_int(%rip), %rdi
    leaq seed(%rip), %rsi
    xorq %rax, %rax
    call _scanf

    # generating a random number
    movl seed(%rip), %edi
    call _srand # generating seed
    call _rand # ganerating
    movl boundary(%rip), %ecx
    xorl %edx, %edx
    divl %ecx # EAX / ECX -> random_number / N
    addl $1, %edx # remainder + 1 -> range 1-N
    movl %edx, number(%rip)

    # easy mode
    leaq easy_mode_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf
    leaq scanf_string(%rip), %rdi
    leaq flag_easy_mode(%rip), %rsi
    xor %rax, %rax
    call _scanf

guess:
    # asking for a guess
    leaq ask_guess_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf

    # scanf("%d", user_input)
    leaq scanf_int(%rip), %rdi
    leaq user_input(%rip), %rsi
    xorq %rax, %rax
    call _scanf

    # incriment counter of tries
    incl counter(%rip) # counter++

    # checking if answer is correct 
    movl user_input(%rip), %eax
    cmpl number(%rip), %eax

    # in case of correct one
    je double

    # incorrect one
    leaq incorrect_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf
    cmpl $'y', flag_easy_mode(%rip) # checking easy mode flag
    jne else
    movl user_input(%rip), %eax
    cmpl number(%rip), %eax
    jg greater
    leaq guess_below_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf
    jmp else # finish the loop

greater:
    leaq guess_above_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf

else:
    # counter++, then loop
    movl counter(%rip), %eax
    cmpl tries(%rip), %eax
    jne guess

    # in case the tries are over
    jmp lose
    
double:
    # double or nothing
    incl rounds_won(%rip) # rounds_won++
    movl $0, counter(%rip) # setting counter of tries to 0
    leaq double_mode_msg(%rip), %rdi
    xorq %rax, %rax
    call _printf

    # scanf("%s", user_input)
    leaq scanf_string(%rip), %rdi
    leaq user_input(%rip), %rsi
    xorq %rax, %rax
    call _scanf

    # compare input, if "n" then move to win part
    movl user_input(%rip), %eax
    cmpl $'y', %eax
    jne win 

    # in case of "y" multiply seed and boundary by 2
    shll $1, boundary(%rip)
    shll $1, seed(%rip)
    jmp guess

win:
    leaq win_msg(%rip), %rdi
    movl rounds_won(%rip), %esi
    xorq %rax, %rax
    call _printf
    jmp exit

lose:
    leaq lose_msg(%rip), %rdi
    movl number(%rip), %esi
    xorq %rax, %rax
    call _printf
    jmp exit

exit:
    # terminate
    movq %rbp, %rsp
    popq %rbp
    movq $0, %rax
    ret