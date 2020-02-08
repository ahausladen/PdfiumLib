# PdfiumLib
Example of a PDF VCL Control using PDFium

## Requirements
pdfium.dll (x86/x64) from the [pdfium-binaries](https://github.com/bblanchon/pdfium-binaries)

## Required pdfium.dll version
chromium/4047

## Features
- Multiple PDF load functions:
  - File (load into memory, memory mapped file, on demand load)
  - TBytes
  - TStream
  - Active buffer (buffer must not be released before the PDF document is closed)
  - Active TSteam (stream must not be released before the PDF document is closed)
  - Callback
- PDF rotation (normal, 90° counter clockwise, 180°, 90° clockwise)
- Highlighted text (e.g. for search results)
- WebLink click support
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
