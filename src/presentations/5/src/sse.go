package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/fatih/color"
)

func StartSSE() {
	http.HandleFunc("/sse", sseHandler)
}

func sseHandler(w http.ResponseWriter, r *http.Request) {
	blue := color.New(color.FgBlue)

	blue.Println("Received SSE connection request:")
	blue.Println(r.Method, r.RequestURI, r.Proto)
	for name, values := range r.Header {
		for _, value := range values {
			blue.Printf("%s: %s\n", name, value)
		}
	}

	// SSE isn't an internet standard like WebSockets, but it's defined in the HTML spec:
	// - WebSocket: an IETF protocol (RFC 6455) (IETF=Internet Engineering Task Force)
	// - SSE: part of the HTML spec
	// (yes, it's literally part of the HTML spec)
	// https://html.spec.whatwg.org/multipage/server-sent-events.html

	// Set SSE headers
	w.Header().Set("Content-Type", "text/event-stream") // This is where the magic happens

	w.Header().Set("Cache-Control", "no-cache")        // Prevent caching of SSE responses (important for real-time updates)
	w.Header().Set("Connection", "keep-alive")         // Ensure the connection stays open (important for SSE)
	w.Header().Set("Access-Control-Allow-Origin", "*") // Allow CORS for testing purposes (so we could serve the HTML from a different origin)

	blue.Println("SSE connection established")
	blue.Println("---")

	// Send initial connection event
	blue.Println("Sending SSE message to client:")
	message := "data: hello from SSE server!\n\n"
	blue.Printf("Raw SSE message bytes: %v\n", []byte(message))
	blue.Printf("Message structure:\n")
	blue.Printf("  Field: data\n")
	blue.Printf("  Value: hello from SSE server!\n")
	blue.Printf("  Terminator: \\n\\n (marks end of event)\n")
	blue.Printf("Message content: %q\n", message)
	fmt.Fprint(w, message)

	// Here's the fun part! SSE is literally just an open HTTP connection where
	// the server keeps sending text data formatted in a specific way.
	//
	// Do you remember what we usually say to "finish" an HTTP response?
	//
	// We send a blank line (i.e., \r\n\r\n) to indicate the end of headers,
	// and then the body follows. Once the body is sent, at least with HTTP/1.1,
	// the server typically closes the connection to signal the end of the response.

	// Here, with SSE, we keep the connection open indefinitely!
	//
	// Each message is prefixed with "data: " and ends with two newlines.
	// The client (browser) knows to treat this as a stream of events.
	//
	// So we just keep writing to the response writer `w` whenever we want to send
	// a new event to the client!
	//
	// We send a message, followed by two newlines, and then we flush the response
	// to ensure it gets sent immediately.

	if flusher, ok := w.(http.Flusher); ok {
		flusher.Flush()
	}
	blue.Println("---")

	// Send periodic messages
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	// Make sure to stop the ticker when the client disconnects
	go func() {
		<-r.Context().Done()
		ticker.Stop()
	}()

	counter := 1
	for {
		select {
		case <-r.Context().Done():
			blue.Println("Client disconnected, stopping SSE")
			return
		case <-ticker.C:
			blue.Println("Sending SSE message to client:")

			// Create SSE message with event ID and data
			eventMessage := fmt.Sprintf("id: %d\ndata: Message #%d from SSE server\n\n", counter, counter)

			// Send the message - check for errors which indicate client disconnect
			fmt.Fprint(w, eventMessage) // you should usually do error checking here
			// (directly write it to the wire)

			if flusher, ok := w.(http.Flusher); ok {
				flusher.Flush() // make sure it pumps out immediately
			}

			blue.Printf("Sent message #%d\n", counter)
			blue.Println("---")
			counter++
		}
	}
}
