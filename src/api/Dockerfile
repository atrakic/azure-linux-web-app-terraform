# Example web app
FROM golang:1.23-alpine AS builder
WORKDIR /app

# Use heredoc to create a simple system info webserver
RUN <<EOF cat > main.go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "runtime"
    "os"
    "time"
)

type SystemInfo struct {
    Hostname        string    \`json:"hostname"\`
    GoVersion       string    \`json:"go_version"\`
    OS              string    \`json:"os"\`
    Arch            string    \`json:"arch"\`
    CPUCores        int       \`json:"cpu_cores"\`
    MemoryAllocated float64   \`json:"memory_mb"\`
    Timestamp       time.Time \`json:"timestamp"\`
}

func getSystemInfo() SystemInfo {
    hostname, _ := os.Hostname()
    
    var m runtime.MemStats
    runtime.ReadMemStats(&m)
    
    return SystemInfo{
        Hostname:        hostname,
        GoVersion:       runtime.Version(),
        OS:              runtime.GOOS,
        Arch:            runtime.GOARCH,
        CPUCores:        runtime.NumCPU(),
        MemoryAllocated: float64(m.Alloc) / 1024 / 1024,
        Timestamp:       time.Now(),
    }
}

func systemInfoHandler(w http.ResponseWriter, r *http.Request) {
    sysInfo := getSystemInfo()
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(sysInfo)
}

func main() {
    http.HandleFunc("/", systemInfoHandler)
    
    log.Println("System Info Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

RUN CGO_ENABLED=0 GOOS=linux go build \
    -a -installsuffix cgo \
    -o sysinfo main.go

FROM scratch AS final
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /app/sysinfo /sysinfo
USER nobody
EXPOSE 8080
ENTRYPOINT ["/sysinfo"]
