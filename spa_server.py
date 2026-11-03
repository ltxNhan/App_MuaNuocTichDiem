import http.server
import socketserver
import os
import sys

PORT = 8080
DIRECTORY = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), 'build', 'web')

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Resolve target file path
        path = self.translate_path(self.path)
        # If file doesn't exist and has no extension, fallback to /index.html
        if not os.path.exists(path) or os.path.isdir(path):
            index_path = os.path.join(path, 'index.html') if os.path.isdir(path) else None
            if not index_path or not os.path.exists(index_path):
                self.path = '/index.html'
        return super().do_GET()

# Use ThreadingTCPServer for non-blocking concurrent request handling
class ThreadedTCPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

if __name__ == '__main__':
    with ThreadedTCPServer(("", PORT), SPAHandler) as httpd:
        print(f"Serving SPA at http://localhost:{PORT} from {DIRECTORY}")
        httpd.serve_forever()
