# Cli app sample
FROM golang:1.21-alpine AS builder
WORKDIR /app

# Use heredoc to create the Go source code
RUN <<EOF cat > main.go
package main

import (
    "fmt"
    "math/rand"
    "time"
)

func main() {
    rand.Seed(time.Now().UnixNano())
    stopChan := make(chan bool)
    go printRandomSymbols(stopChan)
    time.Sleep(10 * time.Second)
    stopChan <- true
}

func printRandomSymbols(stop <-chan bool) {
    ticker := time.NewTicker(250 * time.Millisecond)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            printRandomSymbol()
        case <-stop:
            fmt.Println("\nSymbol printing stopped")
            return
        }
    }
}

func printRandomSymbol() {
    symbols := []string{".", "|", "+", "*", "-"}
    fmt.Print(symbols[rand.Intn(len(symbols))])
}
EOF
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp main.go

FROM scratch AS final
COPY --from=builder /app/myapp /cliapp
ENTRYPOINT ["/cliapp"]
