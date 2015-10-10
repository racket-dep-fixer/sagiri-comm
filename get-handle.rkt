#lang racket/base
(require "structs.rkt"
         racket/tcp)

(provide get-handle)

(define (get-handle)
  (define-values (in out) (tcp-connect "127.0.0.1" 12377))
  (dynamic-wind
   void
   (lambda()
     (define toret (ctl-greeting-read in))
     (msg-write (ctl-command .ctlCmdNOOP (make-bytes 64) 0 0) out)
     (flush-output out)
     toret)
   (lambda()
     (close-input-port in)
     (close-output-port out))))