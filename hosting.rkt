#lang racket/base
(require "structs.rkt"
         "get-handle.rkt"
         racket/tcp
         racket/match
         racket/function)

(provide sagiri-start-forward
         sagiri-stop-forward)

(define (sagiri-start-forward
         #:private-key priv-key
         #:external-port ext-port
         #:internal-port int-port)
  (define-values (in out) (tcp-connect "127.0.0.1" 12377))
  (dynamic-wind
   void
   (lambda()
     (ctl-greeting-read in) ; ignore result since we don't use it
     (msg-write
      (ctl-command .ctlCmdHOST
                   priv-key
                   int-port
                   ext-port) out)
     (flush-output out)
     (match (ctl-response-read in)
       [(ctl-response (? (curry = .ctlRespOKAY))
                      name)
        name]
       [(ctl-response _ message)
        (error 'sagiri-start-forward message)]))
   (lambda()
     (close-input-port in)
     (close-output-port out))))

(define (sagiri-stop-forward
         #:private-key priv-key
         #:external-port ext-port)
  (define-values (in out) (tcp-connect "127.0.0.1" 12377))
  (dynamic-wind
   void
   (lambda()
     (ctl-greeting-read in)
     (msg-write
      (ctl-command .ctlCmdSTOP
                   priv-key
                   0
                   ext-port) out)
     (flush-output out)
     (match (ctl-response-read in)
       [(ctl-response (? (curry = .ctlRespOKAY))
                      name)
        #t]
       [(ctl-response _ message)
        (error 'sagiri-start-forward message)]))
   (lambda()
     (close-input-port in)
     (close-output-port out))))