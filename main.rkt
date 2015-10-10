#lang at-exp racket/base

(require "hosting.rkt"
         "connect.rkt"
         scribble/srcdoc
         racket/contract
         (for-doc racket/base scribble/base scribble/manual))

(provide
 (proc-doc/names sagiri-connect
                 (-> string? exact-integer? (values input-port?
                                                    output-port?))
                 (host port)
                 @{Connects to the SAGIRI address at @racket[host] and on port @racket[port].})
 (proc-doc/names sagiri-start-forward
                 (->* (#:private-key
                       bytes?
                       #:internal-port exact-integer?
                       #:external-port exact-integer?)
                      ()
                      (values string? port?))
                 ((priv-key int-port ext-port)())
                 @{Instructs SAGIRI to forward incoming requests on @racket[ext-port] to @racket[int-port].
 The globally addressable hostname (including the IP!) will be returned.})
 (proc-doc/names sagiri-stop-forward
                 (->* (#:private-key
                       bytes?
                       #:external-port exact-integer?)
                      ()
                      (values string? port?))
                 ((priv-key ext-port)())
                 @{Instructs SAGIRI to stop forward incoming requests on @racket[ext-port].}))