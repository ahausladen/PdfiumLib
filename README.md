# PdfiumLib
Example of a PDF VCL Control using PDFium

## Requirements
pdfium.dll (x86/x64) from the [pdfium-binaries](https://github.com/bblanchon/pdfium-binaries)

Binary release: [chromium/7920](https://github.com/bblanchon/pdfium-binaries/releases/tag/chromium%2F7920)

## Required pdfium.dll version
chromium/7920 / PDFium 151.0.7920.0

## Installing

### DPM

Using the dpm command line

`dpm install VSoft.PdfiumLib`

or using the dpm ide plugin, in the dpm manage packages window, search for VSoft.PdfiumLib, select it and click the + icon at the top right.

This package depends on VSoft.Pdfium.Binaries v151.0.7920 (dpm will install it automatically and copy the pdfium.dll to your project output folder).

### Manually

Clone this repository and add the Source folder to your Library Path or the project's Search Path.

Design time and Runtime packages are provided for Delphi XE2-13.x - open the relevant PdfiumLib.groupproj and build it, then right click on the PdfiumLibD project to install the component.

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
