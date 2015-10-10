#lang scribble/manual
@(require scribble/extract
          (for-label racket
                     "../main.rkt"))
@title{SAGIRI Racket bindings}
@defmodule[sagiri-comm]

@para{@racket[sagiri-comm] provides a convenient Racket interface to SAGIRI. It works by
 talking with a running SAGIRI instance on the local machine, so make sure that
 SAGIRI is running before calling the procedures exported by this module.}

@para{One thing to note is the URL format: URLs that are passed to
 @racket{sagiri-connect} and returned from the other two functions
 are of the following format:}

@verbatim{
 [   IP address   ] [               EdDSA Public key (32 bytes)                    ]
 (###-###-###-###--)aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.edge.sagiri}

@para{When returning a hostname, this library will always include the IP address. It's up to
 the application to strip the IP portion out if it wishes to before handing out the address
 to anybody.}

@margin-note{@bold{Note}: In practice, until SAGIRI's onion-routing and DHT functionality is completed,
 the IP address will @italic{always} be needed.}

@include-extracted["../main.rkt"]