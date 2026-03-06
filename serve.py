#!/usr/bin/env python3
"""Simple SPA server for Flutter web builds."""
import http.server
import os

PORT = 8090
DIR = os.path.join(os.path.dirname(__file__), 'build', 'web')

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def do_GET(self):
        # Serve index.html for SPA routes (not static files)
        path = os.path.join(DIR, self.path.lstrip('/'))
        if not os.path.exists(path) or os.path.isdir(path):
            self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    with http.server.HTTPServer(('', PORT), SPAHandler) as s:
        print(f'Serving Flutter web on http://localhost:{PORT}')
        s.serve_forever()
