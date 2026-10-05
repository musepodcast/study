"""Serve the release beneath its production /study/ base path on localhost."""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

WEB = Path(__file__).resolve().parents[1]/'app/build/web'


class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*args,**kwargs):
        super().__init__(*args,directory=str(WEB),**kwargs)

    def do_GET(self):
        path = urlsplit(self.path).path
        if path in ('/', '/study'):
            self.send_response(302)
            self.send_header('Location','/study/')
            self.end_headers()
            return
        if not path.startswith('/study/'):
            self.send_error(404)
            return
        self.path = self.path[len('/study'):]
        super().do_GET()


if __name__ == '__main__':
    print('Preview: http://127.0.0.1:8088/study/',flush=True)
    ThreadingHTTPServer(('127.0.0.1',8088),Handler).serve_forever()
