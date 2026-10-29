#!/usr/bin/python3
import ctypes
import fcntl
import os
import sys
import time
import subprocess

x11 = ctypes.CDLL('libX11.so.6')
x11.XOpenDisplay.argtypes = [ctypes.c_char_p]
x11.XOpenDisplay.restype = ctypes.c_void_p
x11.XkbKeycodeToKeysym.argtypes = [ctypes.c_void_p, ctypes.c_ubyte, ctypes.c_int, ctypes.c_int]
x11.XkbKeycodeToKeysym.restype = ctypes.c_ulong
x11.XChangeKeyboardMapping.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_ulong), ctypes.c_int]
x11.XkbLockGroup.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_uint]
x11.XSync.argtypes = [ctypes.c_void_p, ctypes.c_int]
x11.XCloseDisplay.argtypes = [ctypes.c_void_p]
x11.XStringToKeysym.argtypes = [ctypes.c_char_p]
x11.XStringToKeysym.restype = ctypes.c_ulong
x11.XQueryKeymap.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
display = x11.XOpenDisplay(None)
if not display:
    sys.exit('Cannot connect to the X11 session')
if any(flag in sys.argv for flag in ['--lock', '--restore', '--prepare-only']):
    x11.XCloseDisplay(display)
    import runpy
    runpy.run_path(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lock.py'), run_name='__main__')
    sys.exit(0)

allowed = {191: 'XF86Tools', 192: 'XF86Launch5', 193: 'XF86Launch6'}
while True:
    recovery = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sources-before-lock.json')
    if os.path.exists(recovery):
        subprocess.run(['/usr/bin/python3', __file__, '--restore'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for code, symbol in [(191, 0xffca), (192, 0xffcb), (193, 0xffcc)]:
        if '--recover-only' in sys.argv:
            continue
        current = x11.XkbKeycodeToKeysym(display, code, 0, 0)
        if current not in (symbol, x11.XStringToKeysym(allowed[code].encode())):
            continue
        if current != symbol:
            mapping = (ctypes.c_ulong * 2)(symbol, symbol)
            x11.XChangeKeyboardMapping(display, code, 2, mapping, 1)
    x11.XSync(display, False)
    if '--once' in sys.argv:
        break
    time.sleep(3)
x11.XCloseDisplay(display)
