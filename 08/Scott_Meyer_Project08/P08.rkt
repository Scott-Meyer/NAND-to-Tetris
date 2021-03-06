#lang racket
;;; Racket Implementation made by scott meyer.



;;; Code done in a very mutable iterative way.
;;;     do/while loops allow avoiding maps/folds to match the coding style.
(require dyoo-while-loop)

;;; This makes it more obvious what we are doing when splitting out comments.
;;;    At this time comment re-entry does not work.
(define COMMENT "//")

(define Parser%
  (class object%
    (init fname)
    (super-new)
    ;(printf "~a" fname)
    (define vm (file->lines fname))
    (define commands (make-hash '(("add" . "C_ARITHMETIC")
                                  ("sub" . "C_ARITHMETIC")
                                  ("neg" . "C_ARITHMETIC")
                                  ("eq" . "C_ARITHMETIC")
                                  ("gt" . "C_ARITHMETIC")
                                  ("lt" . "C_ARITHMETIC")
                                  ("and" . "C_ARITHMETIC")
                                  ("or" . "C_ARITHMETIC")
                                  ("not" . "C_ARITHMETIC")
                                  ("push" . "C_PUSH")
                                  ("pop" . "C_POP")
                                  ("label" . "C_LABEL")
                                  ("goto" . "C_GOTO")
                                  ("if-goto" . "C_IF")
                                  ("function" . "C_FUNCTION")
                                  ("return" . "C_RETURN")
                                  ("call" . "C_CALL"))))
    (define curr_instruction "")
    (define next_instruction "")
    (define curr_line 0)


    ;;; External Use
    (define/public (curr_instruction_pub)
      curr_instruction)
    
    (define/public (advance)
      (begin
        (set! curr_instruction next_instruction)
        (load_next_instruction "")))

    (define/public (has_more_commands)
      (not (null? next_instruction)))

    (define/public (command_type)
      (begin
        ;(printf "Cmd?: ~a" (list-ref (words (string-downcase curr_instruction)) 0))
      (dict-ref commands (list-ref (words (string-downcase curr_instruction)) 0))))

    (define/public (arg1)
      (if (equal? (command_type) "C_ARITHMETIC")
          (argn 0)
          (argn 1)))

    (define/public (arg2)
      (argn 2))
      

    ;;; Internal Use
    (define (words str)
      (string-split str " "))
      
    (define (fref file)
      (if (>= curr_line (length vm))
          null
          (begin
            (set! curr_line (+ curr_line 1))
            ;(printf "fref: ~a -- ~a\n" (string-normalize-spaces (string-trim (list-ref file (- curr_line 1)))) (is_instruction (string-normalize-spaces (string-trim (list-ref file (- curr_line 1))))))
            (string-normalize-spaces (string-trim (list-ref file (- curr_line 1)))))))

    (define (initialize_file)
      (define (init line)
        (if (not (is_instruction line))
            (init (fref vm))
            line))
      (define line (init (fref vm)))
      (load_next_instruction line))

    (define (load_next_instruction line)
      (let [(line2 (if (or (null? line) (equal? line ""))
                       (fref vm)
                       line))]
        (if (null? line2)
            (set! next_instruction null)
            (if (is_instruction line2)
                (set! next_instruction (first (string-split line2 COMMENT)))
                (load_next_instruction (fref vm))))))

    (define (is_instruction line)
      (cond
        [(< (string-length line) 2) #f]
        [(equal? (substring line 0 2) COMMENT) #f]
        [else #t]))
    
    (define (argn n)
      (if (>= (length (words curr_instruction)) (+ n 1))
          (list-ref (words curr_instruction) n)
          null))

      ;;;Begin Running
      (begin
        (initialize_file))))

(define CodeWriter%
  (class object%
    (init asm_filename)
    (super-new)
    (define curr_file null)
    (define addresses null)
    (define bool_count 0)
    (define line_count 0)
    (define call_count 0)
    (define asm (list))
    (define asm_filename2 asm_filename)


    ;;;Begin external facing functions

    ;;;Initial code, for multi file programs with a Main and Sys.vm
    ;;;   Only called if code contains functions, a Main function, and a Sys.init function
    (define/public (write_init #:sys-init [sys-init #t])
      (begin
        (write "@256")
        (write "D=A")
        (write "@SP")
        (write "M=D")
        (if sys-init
            (write_call "Sys.init" 0)
            null)))
    
    (define/public (set_file_name vm_filename)
      (begin
        (set! curr_file (first (string-split (last (string-split vm_filename "/")) ".")))
        (write "//-------------------//" #:code #f)
        (write (string-append "// " curr_file) #:code #f)
        (write "//-------------------//" #:code #f)))

    (define/public (write_arithmetic operation)
      (begin
        (if (not (member operation (list "neg" "not")))
            (pop_stack_to_D)
            null)
        (decrement_SP)
        (set_A_to_stack)

        (cond
          [(equal? operation "add") (write "M=M+D")]
          [(equal? operation "sub") (write "M=M-D")]
          [(equal? operation "and") (write "M=M&D")]
          [(equal? operation "or") (write "M=M|D")]
          [(equal? operation "neg") (write "M=-M")]
          [(equal? operation "not") (write "M=!M")]
          [(member operation (list "eq" "gt" "lt"))
           (begin
             (write "D=M-D")
             (write (string-append "@BOOL" (number->string bool_count)))

             (cond
               [(equal? operation "eq") (write "D;JEQ")]
               [(equal? operation "gt") (write "D;JGT")]
               [(equal? operation "lt") (write "D;JLT")])

             (set_A_to_stack)
             (write "M=0")
             (write (string-append "@ENDBOOL" (number->string bool_count)))
             (write "0;JMP")

             (write (string-append "(BOOL" (number->string bool_count) ")") #:code #f)
             (set_A_to_stack)
             (write "M=-1")

             (write (string-append "(ENDBOOL" (number->string bool_count) ")") #:code #f)
             (set! bool_count (+ bool_count 1)))]
          [else (raise_unknown operation)])
          (increment_SP)))

    (define/public (write_push_pop command segment index)
      (begin
        (resolve_address segment index)
        (cond
          [(equal? command "C_PUSH") (begin
                                       (if (equal? segment "constant")
                                           (write "D=A")
                                           (write "D=M"))
                                       (push_D_to_stack))]
          [(equal? command "C_POP") (begin
                                      (write "D=A")
                                      (write "@R13")
                                      (write "M=D")
                                      (pop_stack_to_D)
                                      (write "@R13")
                                      (write "A=M")
                                      (write "M=D"))]
          [else (raise_unknown command)])))

    (define/public (write_label label)
      (write (string-append "(" curr_file "$" label ")") #:code #f))

    (define/public (write_goto label)
      (begin
        (write (string-append "@" curr_file "$" label))
        (write "0;JMP")))

    (define/public (write_if label)
      (begin
        (pop_stack_to_D)
        (write (string-append "@" curr_file "$" label))
        (write "D;JNE")))

    (define/public (write_function function_name num_locals)
      (begin
        (write (string-append "(" function_name ")") #:code #f)

        (for ([i (in-range num_locals)])
          (begin
            (write "D=0")
            (push_D_to_stack)))))

    (define/public (write_call function_name num_args)
      (define RET (string-append function_name "FUNCTIONRETURN" (number->string call_count)))
      (begin
        (set! call_count (+ call_count 1))

        (write (string-append "@" RET))
        (write "D=A")
        (push_D_to_stack)

        (for ([address '("@LCL" "@ARG" "@THIS" "@THAT")])
          (begin
            (write address)
            (write "D=M")
            (push_D_to_stack)))

        (write "@SP")
        (write "D=M")
        (write "@LCL")
        (write "M=D")

        (write (string-append "@" (number->string (+ num_args 5))))
        (write "D=D-A")
        (write "@ARG")
        (write "M=D")

        ;;;GoTo 'function_name'
        (write (string-append "@" function_name))
        (write "0;JMP")

        (write (string-append "(" RET ")") #:code #f)))

    (define/public (write_return)
      (define FRAME "R13")
      (define RET "R14")

      (begin
        (write "@LCL")
        (write "D=M")
        (write (string-append "@" FRAME))
        (write "M=D")

        (write (string-append "@" FRAME))
        (write "D=M")
        (write "@5")
        (write "D=D-A")
        (write "A=D")
        (write "D=M")
        (write (string-append "@" RET))
        (write "M=D")

        (pop_stack_to_D)
        (write "@ARG")
        (write "A=M")
        (write "M=D")

        (write "@ARG")
        (write "D=M")
        (write "@SP")
        (write "M=D+1")

        (define offset 1)
        (for ([address (list "@THAT" "@THIS" "@ARG" "@LCL")])
          (begin
            (write (string-append "@" FRAME))
            (write "D=M")
            (write (string-append "@" (number->string offset)))
            (write "D=D-A")
            (write "A=D")
            (write "D=M")
            (write address)
            (write "M=D")
            (set! offset (+ offset 1))))

        ;;;insert "GOTO @R14" in asm.
        (write (string-append "@" RET))
        (write "A=M")
        (write "0;JMP")))
    
    (define/public (close)
      (begin
        (printf "~a" asm_filename2)
        (display-to-file (string-join (reverse asm) "\n") asm_filename2 #:mode 'text #:exists 'replace)))
    
      
    ;;;Begin internal functions

    ;;;This is the internal function used to actually write the ASM to the file.
    (define/public write
      (lambda (command #:code [code #t])
          ;(let ([myCommand command])
          ;  (begin
          ;    (if code
          ;        (begin
          ;          (set! myCommand (string-append myCommand " // " (number->string line_count)))
          ;          (set! line_count (+ line_count 1)))
          ;        null)
          ;    (set! asm (cons myCommand asm))))))
        (set! asm (cons command asm))))   ;Just add the command string to the front of the ASM list.

    (define (raise_unknown argument)
      (#t))

    (define (resolve_address segment index)
      (define address (dict-ref addresses segment null))
      (cond
        [(equal? segment "constant")
         (write (string-append "@" (number->string index)))]
        [(equal? segment "static")
         (write (string-append "@" curr_file "." (number->string index)))]
        [(member segment '("pointer" "temp"))
         (write (string-append "@R" (number->string (+ address index))))]
        [(member segment '("local" "argument" "this" "that"))
         (begin
           (write (string-append "@" address))
           (write "D=M")
           (write (string-append "@" (number->string index)))
           (write "A=D+A"))]
        [else
         (raise_unknown(segment))]))

    (define (address_dict)
      (make-hash '(("local" . "LCL")    ; Base R1
                   ("argument" . "ARG") ; Base R2
                   ("this" . "THIS")    ; Base R3
                   ("that" . "THAT")    ; Base R4
                   ("pointer" . 3)      ; Edit R3, R4
                   ("temp" . 5)         ; Edit R5-12
                                        ; R13-15 are free
                   ("static" . 16))))   ; Edit R16-255

    (define (push_D_to_stack)
      (begin
        (write "@SP")
        (write "A=M")
        (write "M=D")
        (increment_SP)))

    (define (pop_stack_to_D)
      (begin
        (decrement_SP)
        (write "A=M")
        (write "D=M")))

    (define (decrement_SP)
      (begin
        (write "@SP")
        (write "M=M-1")))

    (define (increment_SP)
      (begin
        (write "@SP")
        (write "M=M+1")))

    (define (set_A_to_stack)
      (begin
        (write "@SP")
        (write "A=M")))

    (begin
      (set! addresses (address_dict)))))

;;;Main class, takes a "file_path" as argument (make-object Main% "FunctionCalls/FibonacciElement") Foward Slashes.
(define Main%
  (class object%
    (init file_path)
    (super-new)
    (define cw null)
    (define vm_files null)
    (define asm_file null)

    ;;;Find all vm and related files in file_path, fill asm_file and vm_files variables.
    (define (parse_files file_path)
      (if (string-contains? file_path ".vm")
          (begin
            (set! asm_file (string-replace file_path ".vm" ".asm"))
            (set! vm_files (list file_path)))
          (let ([slash (if (string-contains? file_path "/") "/" "\\")])
            (begin
              (if (member (string-ref file_path (- (string-length file_path) 1)) (list #\\ #\/))
                  (set! file_path (substring file_path 0 (- (string-length file_path) 2)))
                  (set! file_path file_path))
              (define path_elements (string-split file_path slash))
              (define path (string-join path_elements "/"))
              (set! asm_file (string-append path "/" (last path_elements) ".asm"))
              ;;dirpath, dirnames, filenames = next(os.walk(file_path), [[],[],[]])
              (define vm_files_tmp (filter (λ (str) (string-contains? str ".vm")) (map path->string (directory-list file_path))))
              (set! vm_files (for/list ([fi vm_files_tmp])
                               (string-append path "/" fi)))))))

    ;;; This function is run on a loop for all VM files and handles the actual code tranlation.
    (define (translate vm_file)
      (begin
        (define parser (make-object Parser% vm_file))
        (send cw set_file_name vm_file)
        (send cw write (string-append "////// BEGIN /////" vm_file) #:code #f)
        (while (send parser has_more_commands)
         (begin
           (send parser advance)
           (send cw write (string-append "// " (send parser curr_instruction_pub)) #:code #f)
           ;(printf "command_type: ~a \n" (send parser command_type))
           ;;; Depending on parser-command_type, run aproperiate cw-write function.
           (cond
             [(equal? (send parser command_type) "C_PUSH")
              (send cw write_push_pop "C_PUSH" (send parser arg1) (string->number (send parser arg2)))]
             [(equal? (send parser command_type) "C_POP")
              (send cw write_push_pop "C_POP" (send parser arg1) (string->number (send parser arg2)))]
             [(equal? (send parser command_type) "C_ARITHMETIC")
              (send cw write_arithmetic (send parser arg1))]
             [(equal? (send parser command_type) "C_LABEL")
              (send cw write_label (send parser arg1))]
             [(equal? (send parser command_type) "C_GOTO")
              (send cw write_goto (send parser arg1))]
             [(equal? (send parser command_type) "C_IF")
              (send cw write_if (send parser arg1))]
             [(equal? (send parser command_type) "C_FUNCTION")
              (send cw write_function (send parser arg1) (string->number (send parser arg2)))]
             [(equal? (send parser command_type) "C_CALL")
              (send cw write_call (send parser arg1) (string->number (send parser arg2)))]
             [(equal? (send parser command_type) "C_RETURN")
              (send cw write_return)])))))
    ;;;This code is run automatically when a Main% object is made.
    (begin
      (parse_files file_path)    ;fill vm_files/asm_file variables.
      (set! cw (make-object CodeWriter% asm_file))
      ;;;If file contains a function defenition, a Main function and a Sys.init function:
      ;;;     write some initial header code into the asm file.
      (let ([files-string (string-downcase (foldl (λ(fi str) (string-append str (file->string fi))) "" vm_files))]
            [must-contain (map string-downcase (list "function"  ))]); "Sys.init" "Main"))])
        (if (for/and ([str must-contain])
              (string-contains? files-string str))
            ;;;If there is a sys.init, write out the sys.init stuff, otherwise just the standard file-init
            (if (string-contains? files-string "sys.init")
                (send cw write_init)
                (send cw write_init #:sys-init #f))
            null))
      ;;; Handle translating of file
      (for ([vm_file vm_files])
        (translate vm_file))
      (send cw close))))

;;;I had tons of trouble with this one, I would get FunctionCalls/Fib+nest+stat working
;;;    and it would make all the flow + calls/simple stop working
;;;    eventually I got flow + first 3 working, but not simple. I had to refrence tons of stuff so:
;;;    http://inworks.ucdenver.edu/jkb/iwks3300/JKB-VM-Translator.zip
;;;    https://github.com/omarrayward/from-nand-to-tetris/tree/master/08/VMTranslator
;;;    https://github.com/itzhak-razi/From-Nand-to-Tetris/tree/master/08

;;;Run the actual program
;;;Make an instance of Main and pass it the arguement
;(define main (make-object Main% (first (vector->list (current-command-line-arguments)))))

;;; Change main function to be an input loop. This is a far more robust form of running the program.
;;; TODO: Add error catching for input, so program doesn't crash when the folder does not exist.
(define main
  (begin
    (display "Welcome to the Racket VMtranslator. This is a implementation of project 08 for NAND to Tetris.\n")
    (let loop()
      (display "\n Enter a filename, or folder that contains a VM. Output will be saved into the given folder. \n")
      (display "    Path: ")
      (define a (read-line (current-input-port) 'any))
      (make-object Main% a)
      (loop))))

;;; TODO: Better commenting.