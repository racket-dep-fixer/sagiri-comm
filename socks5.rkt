#lang racket/base
(require racket/tcp
         racket/match)
(provide socks5-connect)

(define (socks5-connect #:proxy-host px-host
                        #:proxy-port px-port
                        #:remote-host rm-host
                        #:remote-port rm-port)
  (define-values (in out) (tcp-connect px-host px-port))
  (with-handlers ([exn:fail? (λ(ex)
                               (close-input-port in)
                               (close-output-port out)
                               (raise ex))])
    (write-bytes (bytes #x05 ; SOCKS 5 
                        #x01 ; 1 supported auth method
                        #x00 ; No authentication
                        ) out)
    (flush-output out)
    (match (bytes->list (read-bytes 2 in))
      [(list #x05 #x00) (void)]
      [else (error 'socks5-connect "server refused initial handshake")])
    (write-bytes (bytes #x05
                        #x01 ; establish stream connection
                        #x00 ; reserved
                        #x03 ; domain name
                        ) out)
    (write-byte (string-length rm-host) out)
    (write-string rm-host out)
    (write-bytes (integer->integer-bytes rm-port
                                         2 #f #t) out)
    (flush-output out)
    (match (bytes->list (read-bytes 2 in))
      [(list #x05 #x00) (void)]
      [else (error 'socks5-connect "server failed to forward connection")])
    (read-byte in)
    (read-byte in)
    (define len (read-byte in))
    (read-bytes len in)
    (read-bytes 2 in)
    in out))