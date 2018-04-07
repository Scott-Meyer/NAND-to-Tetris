#lang racket


;Require the while-loop package. Including this gets around one of my main problems with functional.
;If I think of a solution in an iterative way, I can write it in an iterative way.
(require dyoo-while-loop)



;When adding a comment to ASM, preface with COMMENT
(define COMMENT "//")

;; Object used when translating VM files.
;; Will advance through the file one step at a time in sync with a CodeWriter% object.
;; When tranlsating a VM file, depending on the return of (command_type), information will be sent to a CodeWriter%
;; that outputs translating.
(define Parser%
  (class object%
    (init fname)
    (super-new)
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
      (dict-ref commands (list-ref (words (string-downcase curr_instruction)) 0)))

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
            (printf "fref: ~a \n" (string-normalize-spaces (string-trim (list-ref file (- curr_line 1)))))
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
            (set! next_instruction (first (string-split line2 COMMENT))))))

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

;; This object is responsable for writing code. Is to be run in parallel with a Parser% object.
;; Mode of operation is called depending on output from Parser% object.
;; (write_arithmetic), (write_push_pop "C_POP"), (write_push_pop "C_PUSH")
(define CodeWriter%
  (class object%
    (init asm_filename)
    (super-new)
    (define curr_file null)
    (define addresses null)
    (define bool_count 0)
    (define asm (list))
    (define asm_filename2 asm_filename)


    ;;;Begin external facing functions
    (define/public (set_file_name vm_filename)
      (set! curr_file (first (string-split (last (string-split vm_filename "/")) "."))))

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

             (write (string-append "(BOOL" (number->string bool_count) ")"))
             (set_A_to_stack)
             (write "M=-1")

             (write (string-append "(ENDBOOL" (number->string bool_count) ")"))
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

    (define/public (close)
      (begin
        (printf "~a" asm_filename2)
        (display-to-file (string-join (reverse asm) "\n") asm_filename2 #:mode 'text #:exists 'replace)))
    
      
    ;;;Begin internal functions
    ;ignore that this is public, weird errors.
    (define/public (write command)
      (begin
        (printf "ASM: ~a \n" command)
        (set! asm (cons command asm))))

    (define (raise_unknown argument)
      (#t))

    (define (resolve_address segment index)
      (define address (dict-ref addresses segment null))
      (cond
        [(equal? segment "constant")
         (write (string-append "@" index))]
        [(equal? segment "static")
         (write (string-append "@" curr_file "." index))]
        [(member segment '("pointer" "temp"))
         (write (string-append "@R" (number->string (+ address (string->number index)))))]
        [(member segment '("local" "argument" "this" "that"))
         (begin
           (write (string-append "@" address))
           (write "D=M")
           (write (string-append "@" index))
           (write "A=D+A"))]
        [else
         (raise_unknown(segment))]))

    ;;;Used to make dictionary for address lookups.
    ; Base R1
    ; Base R2
    ; Base R3
    ; Base R4
    ; Edit R3, R4
    ; Edit R5-12
    ; R13-15 are free
    ; Edit R16-255
    (define (address_dict)
      (make-hash '(("local" . "LCL")
                   ("argument" . "ARG")
                   ("this" . "THIS")
                   ("that" . "THAT")
                   ("pointer" . 3)
                   ("temp" . 5)

                   ("static" . 16))))

    (define (push_D_to_stack)
      (begin
        (write "@SP")
        (write "A=M")
        (write "M=D")
        (write "@SP")
        (write "M=M+1")))

    (define (pop_stack_to_D)
      (begin
        (write "@SP")
        (write "M=M-1")
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

;;This is the main object/class.
;;(make-object Main% <PATH>) will result in translating the VM at <PATH>
(define Main%
  (class object%
    (init file_path)
    (super-new)

    ;; Class attributes, to be filled and used later. MUTABLE.
    ;; List of all VM/ASM files (incase of folder) filled by (parse_files file_path)
    (define vm_files null)
    (define asm_file null)
    ;; List of all cw objects, filled by Main% and (translate vm_file)
    (define cw null)

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

    (define (translate vm_file)
      (begin
        (define parser (make-object Parser% vm_file))
        (send cw set_file_name vm_file)
        (while (send parser has_more_commands)
         (begin
           (send parser advance)
           ;(send cw write (string-append "// " (send parser curr_instruction_pub)))
           ;(printf "command_type: ~a \n" (send parser command_type))
           ;;; Depending on parser-command_type, run aproperiate cw-write function.
           (cond
             [(equal? (send parser command_type) "C_PUSH")
              (send cw write_push_pop "C_PUSH" (send parser arg1) (send parser arg2))]
             [(equal? (send parser command_type) "C_POP")
              (send cw write_push_pop "C_POP" (send parser arg1) (send parser arg2))]
             [(equal? (send parser command_type) "C_ARITHMETIC")
              (send cw write_arithmetic (send parser arg1))])))))

    ;;When main is created, run this code block. Essentially, Parse, translate, write for all VM files.
    (begin
      (parse_files file_path)
      (set! cw (make-object CodeWriter% asm_file))
      (for ([vm_file vm_files])
        (translate vm_file))
      (send cw close))))

;;;Run the actual program
;;;Make an instance of Main and pass it the arguement
;(define main (make-object Main% (first (vector->list (current-command-line-arguments)))))

;;; Change main function to be an input loop. This is a far more robust form of running the program.
;;; TODO: Add error catching for input, so program doesn't crash when the folder does not exist.
(define main
  (begin
    (display "Welcome to the Racket VMtranslator. This is a implementation of project 07 for NAND to Tetris.\n")
    (let loop()
      (display "Enter a filename, or folder that contains a VM. Output will be saved into the given folder. \n")
      (display "    Path: ")
      (define a (read-line (current-input-port) 'any))
      (make-object Main% a)
      (loop))))

;;; TODO: Better commenting.