# PdfiumLib
Example of a PDF VCL Control using PDFium

## Requirements
pdfium.dll (x86/x64) from the [pdfium-binaries](https://github.com/bblanchon/pdfium-binaries)

Binary release: [chromium/6611](https://github.com/bblanchon/pdfium-binaries/releases/tag/chromium%2F6611)

## Required pdfium.dll version
chromium/6611

## Features
- Multiple PDF load functions:
  - File (load into memory, memory mapped file, on demand load)
  - TBytes
  - TStream
  - Active buffer (buffer must not be released before the PDF document is closed)
  - Active TStream (stream must not be released before the PDF document is closed)
  - Callback
- File Attachments
- Import pages into other PDF documents
- Forms
- PDF rotation (normal, 90° counter clockwise, 180°, 90° clockwise)
- Highlighted text (e.g. for search results)
- WebLink/URI-Annotation-Link click event
- Optional automatic Goto/RemoteGoto/EmbeddedGoto/Launch/URL Annotation-Link handling
- Flicker-free and optimized painting (only changed parts are painted)
- Optional buffered page rendering (improves repainting of complex PDF pages)
- Optional text selection by the user (mouse and Ctrl+A)
- Optional clipboard support (Ctrl+C, Ctrl+Insert)
- Keyboard scrolling (Cursor, PgUp/PgDn, Home/End)
- Optional selection scroll timer
- Optional smooth scrolling
- Multiple scaling options
  - Fit to width or height
  - Fit to width
  - Fit to height
  - Zoom (1%-10000%)
