package main

import (
	"log"
	"net/http"
)

// LogRequest is a middleware that just logs a request
func LogRequest(next http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		pattern := `%s - "%s %s %s"`
		log.Printf(pattern, r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())

		next.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}
