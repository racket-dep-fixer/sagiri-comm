#lang racket/base
(require racket/match)
(provide (all-defined-out))

(struct ctl-version (major
                     minor
                     patch)
  #:transparent)

(struct ctl-greeting (version
                      socks-port)
  #:transparent)

(struct ctl-command (verb
                     priv-key
                     int-port
                     ext-port)
  #:transparent)

(struct ctl-response (verb
                      name)
  #:transparent)

(define .ctlCmdNOOP #xFF)
(define .ctlCmdHOST #x00)
(define .ctlCmdSTOP #x01)

(define .ctlRespOKAY #xF0)
(define .ctlRespNOPE #xF1)

(define (msg-write msg out)
  (match msg
    [(ctl-greeting (ctl-version
                    major
                    minor
                    patch)
                   socks-port)
     (write-bytes (bytes #xCA #xCA #xCA #xCA) out)
     (for ([b (list major minor patch)])
       (write-byte b out))
     (write-bytes
      (integer->integer-bytes socks-port
                              2
                              #f
                              #t) out)]
    [(ctl-command verb
                  priv-key
                  int-port
                  ext-port)
     (unless (= 64 (bytes-length priv-key))
       (error 'msg-write "private key of the wrong length"))
     (write-byte verb out)
     (write-bytes priv-key out)
     (for ([i (list int-port ext-port)])
       (write-bytes
        (integer->integer-bytes i
                                2
                                #f
                                #t) out))]
    [(ctl-response verb
                   name)
     (write-byte verb out)
     (write-byte (string-length name) out)
     (write-string name out)]))

(define (ctl-greeting-read in)
  (let ([magic (read-bytes 4 in)]
        [major (read-byte in)]
        [minor (read-byte in)]
        [patch (read-byte in)]
        [socks-port (integer-bytes->integer
                     (read-bytes 2 in)
                     #f #t)])
    (unless (equal? (bytes #xCA #xCA #xCA #xCA)
                    magic)
      (error 'ctl-greeting-read "incorrect magic number from daemon"))
    (ctl-greeting (ctl-version major
                               minor
                               patch)
                  socks-port)))

(define (ctl-command-read in)
  (let ([verb (read-byte in)]
        [priv-key (read-bytes 64 in)]
        [int-port (integer-bytes->integer
                   (read-bytes 2 in) #f #t)]
        [ext-port (integer-bytes->integer
                   (read-bytes 2 in) #f #t)])
    (ctl-command verb
                 priv-key
                 int-port
                 ext-port)))

(define (ctl-response-read in)
  (let* ([verb (read-byte in)]
         [len (read-byte in)]
         [name (read-string len in)])
    (ctl-response verb name)))

(module+ test
  (define-values (in out) (make-pipe))
  (msg-write (ctl-greeting (ctl-version 1 0 0) 12345) out)
  (ctl-greeting-read in)
  (msg-write (ctl-response #x00 "lol") out)
  (ctl-response-read in))