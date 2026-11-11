## tabelline/chrome: a table as a PNG, JPEG, WebP or PDF, drawn by Chrome (an optional module, standard
## library only: Chrome itself is the one thing to install).
##
## The idea of posit-dev's nokap (the backend of Great Tables' `GT.gtsave()`), in Nim with the
## standard library only: start a headless Chrome with a DevTools port, talk to it over a
## WebSocket (the client is in this file), give it the table's page, measure the table and
## take a screenshot of just its box, or print it to PDF.
##
## ```nim
## import tabelline, tabelline/chrome
## let t = tabella(planets()): tabHeader "The planets"
## t.saveImage("planets.png")            # starts Chrome, draws, stops it
## let c = startChrome()                  # or keep one Chrome for many pictures
## c.saveImage(t, "planets@3x.png", scale = 3)
## c.saveImage(t, "planets.pdf")
## c.close()
## ```
##
## Chrome is found in `CHROME_PATH`, then by name on the PATH (google-chrome, chromium, ...),
## then in the usual places on macOS and Windows.
##
## Importing it makes `save` write `.pdf`, `.jpg`, `.jpeg` and `.webp` through Chrome, and `.png`
## too when `tabelline/pixie` is not imported (pixie's PNG is the same on every machine; Chrome
## draws with the machine's fonts). Each `save` starts a Chrome and stops it.

import std/[base64, json, net, os, osproc, random, strutils, times]
import std/math
import ./core, ./render_html, ./save

type
  ChromeError* = object of CatchableError

  WebSocket = object
    sock: Socket

  Chrome* = ref object
    process: Process
    profile: string            ## the temporary --user-data-dir, removed by `close`
    ws: WebSocket
    nextId: int
    events: seq[JsonNode]      ## events read while waiting for a reply
    session: string            ## the tab, attached with `flatten`
    target: string
    frame: string
    timeout*: float            ## seconds to wait for a reply (30)

# ---------------------------------------------------------------------------------------------
# A WebSocket client (RFC 6455): only what the DevTools protocol needs. The client masks every
# frame it sends; Chrome sends text frames, maybe in pieces, and pings.

proc wsConnect(host: string, port: Port, path: string): WebSocket =
  result.sock = newSocket()
  result.sock.connect(host, port)
  var key = newString(16)
  for c in key.mitems: c = char(rand(255))
  result.sock.send("GET " & path & " HTTP/1.1\r\nHost: " & host & ":" & $port & "\r\n" &
                   "Upgrade: websocket\r\nConnection: Upgrade\r\n" &
                   "Sec-WebSocket-Key: " & encode(key) & "\r\nSec-WebSocket-Version: 13\r\n\r\n")
  let status = result.sock.recvLine()
  if not status.contains(" 101 "):
    raise newException(ChromeError, "no WebSocket from Chrome: " & status)
  while true:                     # the rest of the headers, up to the empty line
    let line = result.sock.recvLine()
    if line == "\r\n" or line == "": break

proc recvExact(ws: WebSocket, n: int): string =
  result = newString(n)
  var got = 0
  while got < n:
    let r = ws.sock.recv(addr result[got], n - got)
    if r <= 0: raise newException(ChromeError, "Chrome closed the connection")
    got += r

proc sendFrame(ws: WebSocket, opcode: int, payload: string) =
  var head = newStringOfCap(14)
  head.add char(0x80 or opcode)                # FIN, one frame
  let n = payload.len
  if n < 126: head.add char(0x80 or n)         # 0x80: masked
  elif n < 65536:
    head.add char(0x80 or 126)
    head.add char(n shr 8 and 0xff); head.add char(n and 0xff)
  else:
    head.add char(0x80 or 127)
    for i in countdown(7, 0): head.add char(n shr (8 * i) and 0xff)
  var mask: array[4, char]
  for c in mask.mitems: c = char(rand(255))
  for c in mask: head.add c
  var body = payload
  for i in 0 ..< body.len: body[i] = char(ord(body[i]) xor ord(mask[i and 3]))
  ws.sock.send(head & body)

proc recvMessage(ws: WebSocket): string =
  ## The next whole text message: pieces joined, pings answered.
  while true:
    let h = ws.recvExact(2)
    let fin = (ord(h[0]) and 0x80) != 0
    let opcode = ord(h[0]) and 0x0f
    var n = ord(h[1]) and 0x7f
    if n == 126:
      let e = ws.recvExact(2); n = ord(e[0]) shl 8 or ord(e[1])
    elif n == 127:
      let e = ws.recvExact(8); n = 0
      for c in e: n = n shl 8 or ord(c)
    let payload = if n > 0: ws.recvExact(n) else: ""   # a server never masks
    case opcode
    of 0x9: ws.sendFrame(0xA, payload)                 # ping: pong
    of 0xA: discard
    of 0x8: raise newException(ChromeError, "Chrome closed the WebSocket")
    else:                                              # text, binary, continuation
      result.add payload
      if fin: return

# ---------------------------------------------------------------------------------------------
# The DevTools protocol: a JSON command with an id, a reply with the same id; events in between.

proc send*(c: Chrome, meth: string, params = newJObject(), toTab = true): JsonNode =
  ## Sends a DevTools command (to the tab, or to the browser with `toTab = false`) and returns
  ## its `result`; events that arrive first are kept in `c.events`.
  inc c.nextId
  var msg = %*{"id": c.nextId, "method": meth, "params": params}
  if toTab and c.session.len > 0: msg["sessionId"] = %c.session
  c.ws.sendFrame(0x1, $msg)
  let deadline = epochTime() + c.timeout
  while epochTime() < deadline:
    let reply = parseJson(c.ws.recvMessage())
    if reply{"id"}.getInt(-1) == c.nextId:
      if reply.hasKey("error"):
        raise newException(ChromeError, meth & ": " & reply["error"]{"message"}.getStr)
      return reply{"result"}
    c.events.add reply
  raise newException(ChromeError, meth & ": no reply in " & $c.timeout & " s")

proc evaluate*(c: Chrome, js: string): JsonNode =
  ## The value of a JavaScript expression in the tab; a promise is awaited.
  let r = c.send("Runtime.evaluate", %*{"expression": js, "returnByValue": true, "awaitPromise": true})
  if r.hasKey("exceptionDetails"):
    raise newException(ChromeError, "JavaScript: " & $r["exceptionDetails"])
  r{"result", "value"}

proc findChrome*(): string =
  ## `CHROME_PATH`, then Chrome, Chromium or Edge on the PATH, then their usual places.
  if existsEnv("CHROME_PATH") and fileExists(getEnv("CHROME_PATH")): return getEnv("CHROME_PATH")
  for name in ["google-chrome", "google-chrome-stable", "chromium", "chromium-browser",
               "chrome", "microsoft-edge", "msedge"]:
    let p = findExe(name)
    if p.len > 0: return p
  for p in ["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Chromium.app/Contents/MacOS/Chromium",
            getEnv("PROGRAMFILES") / r"Google\Chrome\Application\chrome.exe",
            getEnv("PROGRAMFILES(X86)") / r"Google\Chrome\Application\chrome.exe",
            getEnv("LOCALAPPDATA") / r"Google\Chrome\Application\chrome.exe",
            getEnv("PROGRAMFILES(X86)") / r"Microsoft\Edge\Application\msedge.exe"]:
    if fileExists(p): return p
  raise newException(ChromeError, "Chrome not found: install it or set CHROME_PATH")

proc drain(f: File) {.thread.} =
  ## Reads Chrome's own messages (stderr) and drops them, so its pipe never fills.
  var buf: array[4096, char]
  try:
    while f.readBuffer(addr buf[0], buf.len) > 0: discard
  except IOError: discard      # the pipe was closed with Chrome

proc startChrome*(path = "", args: openArray[string] = [], timeout = 30.0): Chrome =
  ## Starts a headless Chrome with its own empty profile, and opens one tab to draw in.
  ## `args` are added to the command line (`--no-sandbox` where Chrome runs as root in a
  ## container is added for you).
  randomize()
  let exe = if path.len > 0: path else: findChrome()
  let profile = getTempDir() / "tabelline-chrome-" & $getCurrentProcessId() & "-" & $rand(1_000_000)
  createDir(profile)
  var cmd = @["--headless", "--remote-debugging-port=0", "--user-data-dir=" & profile,
              "--no-first-run", "--no-default-browser-check", "--disable-gpu",
              "--disable-background-networking", "--disable-component-update", "--disable-sync",
              "--disable-default-apps", "--disable-extensions", "--hide-scrollbars",
              "--mute-audio", "--log-level=3", "about:blank"]
  when defined(posix):
    if getEnv("USER") == "root" or getEnv("HOME") == "/root": cmd.insert("--no-sandbox", 0)
  cmd = @args & cmd
  let p = startProcess(exe, args = cmd, options = {poStdErrToStdOut})
  var th: Thread[File]
  var f: File
  discard f.open(p.outputHandle, fmRead)
  createThread(th, drain, f)
  # Chrome writes the port it chose, and the browser's address, in DevToolsActivePort
  let portFile = profile / "DevToolsActivePort"
  let deadline = epochTime() + timeout
  while not fileExists(portFile) or readFile(portFile).splitLines.len < 2:
    if epochTime() > deadline or not p.running:
      p.terminate()
      raise newException(ChromeError, "Chrome did not start: " & exe)
    sleep 20
  let lines = readFile(portFile).splitLines
  result = Chrome(process: p, profile: profile, timeout: timeout)
  result.ws = wsConnect("127.0.0.1", Port(parseInt(lines[0])), lines[1])
  result.target = result.send("Target.createTarget", %*{"url": "about:blank"}, false)["targetId"].getStr
  result.session = result.send("Target.attachToTarget",
                               %*{"targetId": result.target, "flatten": true}, false)["sessionId"].getStr
  discard result.send("Page.enable")
  discard result.send("Runtime.enable")
  result.frame = result.send("Page.getFrameTree")["frameTree"]["frame"]["id"].getStr

proc close*(c: Chrome) =
  ## Stops Chrome and removes its temporary profile.
  if c.process == nil: return
  try: discard c.send("Browser.close", toTab = false)
  except CatchableError: discard
  try: c.ws.sock.close() except CatchableError: discard
  if c.process.running:
    sleep 100
    if c.process.running: c.process.terminate()
  discard c.process.waitForExit(5000)
  c.process.close()
  c.process = nil
  try: removeDir(c.profile) except CatchableError: discard

# ---------------------------------------------------------------------------------------------
# Pictures

type Box* = tuple[x, y, width, height: float]

proc viewport*(c: Chrome, width, height: int, zoom = 1.0) =
  ## The size of the page in CSS pixels; `zoom` is the device scale factor (2: twice the pixels).
  discard c.send("Emulation.setDeviceMetricsOverride",
                 %*{"width": width, "height": height, "deviceScaleFactor": zoom, "mobile": false})

proc show*(c: Chrome, html: string) =
  ## Puts a whole page in the tab, then waits for its fonts and images.
  discard c.send("Page.setDocumentContent", %*{"frameId": c.frame, "html": html})
  discard c.evaluate("""Promise.all([document.fonts.ready,
    ...Array.from(document.images).map(i => i.complete ? 0 :
      new Promise(r => { i.onload = i.onerror = r }))]).then(() => true)""")

proc box*(c: Chrome, selector: string): Box =
  ## The box of the first element `selector` finds, in CSS pixels.
  let r = c.evaluate("""(() => { const e = document.querySelector(""" & $(%selector) & """);
    if (!e) return null; const b = e.getBoundingClientRect();
    return [b.x + scrollX, b.y + scrollY, b.width, b.height] })()""")
  if r.kind != JArray: raise newException(ChromeError, "nothing matches " & selector)
  (r[0].getFloat, r[1].getFloat, r[2].getFloat, r[3].getFloat)

proc screenshot*(c: Chrome, clip: Box, format = "png", quality = -1): string =
  ## The bytes of a picture of `clip` ("png", "jpeg" or "webp"), at the zoom of `viewport`.
  var p = %*{"format": format, "captureBeyondViewport": true, "fromSurface": true,
             "clip": {"x": clip.x, "y": clip.y, "width": clip.width, "height": clip.height, "scale": 1}}
  if quality >= 0 and format != "png": p["quality"] = %quality
  decode(c.send("Page.captureScreenshot", p)["data"].getStr)

proc pdf*(c: Chrome, size: Box): string =
  ## The bytes of a PDF of the page with one page as big as `size` (CSS pixels, 96 to the inch),
  ## drawn with the screen's styles, as the PNG.
  discard c.send("Emulation.setEmulatedMedia", %*{"media": "screen"})
  decode(c.send("Page.printToPDF", %*{
    "paperWidth": size.width / 96, "paperHeight": size.height / 96 + 0.01,
    "marginTop": 0, "marginBottom": 0, "marginLeft": 0, "marginRight": 0,
    "printBackground": true, "pageRanges": "1"})["data"].getStr)

const pictureCss = "<style>html,body{margin:0;padding:0;background:#fff}" &
  "body>.tabella{display:inline-block}</style>"

proc picturePage*(t: Tabella, css = ""): string =
  ## The page Chrome draws: the table alone, at its own width, on white. `css` is added to it
  ## (a font, or a page's colours for a table with `optCssTheme`).
  "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">" & pictureCss & css &
    "</head><body>" & t.toHtml & "</body></html>"

proc saveImage*(c: Chrome, t: Tabella, path: string, scale = 2.0, expand = 0,
                quality = -1, css = "", width = 992) =
  ## Saves the table as a picture, the kind chosen by the extension: ".png", ".jpg", ".webp",
  ## ".pdf" (as gt's `gtsave()`). `scale` makes it sharper (2: two pixels for each CSS pixel),
  ## `expand` adds a white margin in CSS pixels, `width` is the page's width (a wider table
  ## widens it). `css` is added to the page (a font, or a page's colours for `optCssTheme`).
  c.viewport(width, 600, scale)
  c.show(t.picturePage(css))
  var b = c.box(".tabella > table")
  if b.width > width.float:        # a wide table: give it the room it wants
    c.viewport(int(b.width) + 1, 600, scale)
    b = c.box(".tabella > table")
  b = (max(0.0, b.x - expand.float), max(0.0, b.y - expand.float),
       b.width + 2 * expand.float, b.height + 2 * expand.float)
  let ext = path.splitFile.ext.toLowerAscii
  let bytes = case ext
    of ".pdf":
      # the page's top-left corner is the table's: move it there, then print
      discard c.evaluate("document.body.style.margin = '" & $(-b.y) & "px 0 0 " & $(-b.x) & "px'")
      c.pdf(b)
    of ".jpg", ".jpeg": c.screenshot(b, "jpeg", quality)
    of ".webp": c.screenshot(b, "webp", quality)
    of ".png": c.screenshot(b, "png")
    else: raise newException(ValueError, "saveImage: no picture for " & ext)
  writeFile(path, bytes)

proc saveImage*(t: Tabella, path: string, scale = 2.0, expand = 0, quality = -1, css = "",
                width = 992) =
  ## As `saveImage` above, with a Chrome started for this picture and stopped after it.
  let c = startChrome()
  try: c.saveImage(t, path, scale, expand, quality, css, width)
  finally: c.close()

proc chromeWriter(t: Tabella, path: string, scale, width: float) =
  t.saveImage(path, scale, width = int(ceil(width)))

for ext in [".pdf", ".jpg", ".jpeg", ".webp"]: addWriter(ext, chromeWriter, priority = 10)
addWriter(".png", chromeWriter, priority = 0)
