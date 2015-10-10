#lang racket/base
(require "structs.rkt"
         "socks5.rkt"
         "get-handle.rkt"
         racket/match)

(provide sagiri-connect)

(define (sagiri-connect host port)
  (match (get-handle)
    [(ctl-greeting vers skprt)
     (socks5-connect #:proxy-host "127.0.0.1"
                     #:proxy-port skprt
                     #:remote-host host
                     #:remote-port port)]))