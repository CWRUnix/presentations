package main

import (
	_ "embed"
	"fmt"
	"log"
	"net/http"
)

//go:embed index.html
var indexHTML []byte

func main() {
	// Setup WebSocket and SSE handlers
	StartWs()
	StartSSE()

	// Serve the embedded HTML page for testing
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		w.Write(indexHTML)
	})

	fmt.Println("Server starting on :8080")
	fmt.Println("WebSocket endpoint: /ws")
	fmt.Println("SSE endpoint: /sse")
	fmt.Println("Test page: /")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
