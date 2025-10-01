FROM nginx:1.27-alpine
WORKDIR /usr/share/nginx/html

ARG API_URI=http://api:8080
ENV API_URI ${API_URI}

COPY <<EOF index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>System Information Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.1.3/dist/css/bootstrap.min.css">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
            background-color: #f4f4f4;
        }
        .system-info {
            background-color: white;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .json-row {
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }
        .loading {
            color: #666;
            text-align: center;
        }
    </style>
</head>
<body>
  <main>
    <h1>🖥️ System Information Dashboard</h1>
    <div id="systemInfo" class="system-info">
        <p class="loading">Fetching system information...</p>
    </div>
  </main>
  <script src="sysinfo.js"></script>
</body>
</html>
EOF

COPY <<EOF sysinfo.js
function continuousFetch(url) {
    setInterval(() => {
        fetch(url)
            .then(response => response.json())
            .then(data => {
                // Create an HTML representation of key-value pairs
                const htmlContent = Object.entries(data)
                .map(([key, value]) => `
                    <div class="json-row"><strong>\${key}:</strong> \${JSON.stringify(value)}</div>
                `).join('');
                document.querySelector("#systemInfo").innerHTML = htmlContent;
                console.log(data);
            })
            .catch(error => {
                const infoDiv = document.getElementById('systemInfo');
                infoDiv.innerHTML = `<p style="color: red;">Error loading system information: \${error.message}</p>`;
                console.error('Fetch error:', error);
            });
    }, 5000); // Fetch every 5 seconds
}
continuousFetch('/api');
EOF

# Configure Nginx to serve the static file
RUN <<EOF cat > /etc/nginx/conf.d/default.conf 
server {
    listen 80;
    server_name ${NGINX_SERVER_NAME:-localhost};

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    # Enable CORS for API calls
    location /api {
        proxy_pass ${API_URI};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
    }
}
EOF

RUN apk add --no-cache curl

HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -sf http://localhost/ || exit 1
