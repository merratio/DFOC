import http.server
import json
import os
import shutil
import subprocess
import tempfile

PORT = 8000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DFAC_PATH = os.path.join(BASE_DIR, 'scanner')
TIMEOUT_SECONDS = 5

# Output files dfac may write (first match wins). The fallback names cover
# the original dfa.dot / dfa.svg names in case the .y file isn't updated yet.
DOT_CANDIDATES = ['dfa_output.dot', 'dfa.dot']
JSON_CANDIDATES = ['dfa_output.json', 'dfa.json']
SVG_CANDIDATES = ['dfa_output.svg', 'dfa.svg']


def read_first(directory, names):
    """Return the contents of the first file in `names` that exists, else ''."""
    for name in names:
        path = os.path.join(directory, name)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                return f.read()
    return ''


class DFARequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Serve static files (index.html, js, css) from the script's folder,
        # regardless of where the server is launched from.
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def do_GET(self):
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        return super().do_GET()

    def send_json(self, status, payload):
        body = json.dumps(payload).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def fail(self, status, message):
        self.send_json(status, {
            'success': False,
            'output': '',
            'errors': message,
            'dot': '',
            'json': '',
            'svg': ''
        })

    def do_POST(self):
        if self.path != '/compile':
            self.send_error(404, "Endpoint not found")
            return

        # Parse the request body
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            data = json.loads(body.decode('utf-8'))
            code = data.get('code', '')
            if not isinstance(code, str):
                raise ValueError("'code' must be a string")
        except (ValueError, UnicodeDecodeError) as e:
            self.fail(400, f"Bad request: {e}")
            return

        if not os.path.exists(DFAC_PATH):
            self.fail(500, "dfac binary not found. Compile it first, e.g. "
                           "'yacc -d mysyn.y && lex <lexer>.l && gcc y.tab.c lex.yy.c -o scanner'")
            return

        # Run dfac in its own temporary directory so that:
        #  - simultaneous requests can't overwrite each other's files
        #  - stale output from earlier runs can never be read back
        workdir = tempfile.mkdtemp(prefix='dfa_')
        try:
            try:
                process = subprocess.run(
                    [DFAC_PATH],
                    input=code,          # dfac reads the DFA description from stdin
                    capture_output=True,
                    text=True,
                    timeout=TIMEOUT_SECONDS,
                    cwd=workdir
                )
            except subprocess.TimeoutExpired:
                self.fail(500, f"dfac timed out after {TIMEOUT_SECONDS} seconds")
                return
            except Exception as e:
                self.fail(500, f"Execution failed: {e}")
                return

            success = process.returncode == 0
            stdout = process.stdout
            stderr = process.stderr

            # dfac prints some validation errors to stdout, so on failure
            # include stdout in the errors shown to the user.
            errors = stderr
            if not success and stdout.strip():
                errors = (stdout + stderr) if stderr else stdout

            dot_content = ''
            json_content = ''
            svg_content = ''
            if success:
                dot_content = read_first(workdir, DOT_CANDIDATES)
                json_content = read_first(workdir, JSON_CANDIDATES)
                svg_content = read_first(workdir, SVG_CANDIDATES)

            self.send_json(200, {
                'success': success,
                'output': stdout,
                'errors': errors,
                'dot': dot_content,
                'json': json_content,
                'svg': svg_content
            })
        finally:
            shutil.rmtree(workdir, ignore_errors=True)


if __name__ == '__main__':
    server_address = ('', PORT)
    httpd = http.server.ThreadingHTTPServer(server_address, DFARequestHandler)
    print(f"DFA Web Visualizer running at http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        httpd.server_close()
