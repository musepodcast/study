"""Generate the app's geometric courthouse mark with standard-library PNG encoding."""
import json
import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def icon(size):
    pixels = bytearray()
    for y in range(size):
        pixels.append(0)
        for x in range(size):
            a,b = (x+.5)/size,(y+.5)/size
            color = (32,60,96,255)
            # Pediment, lintel, columns, steps: all geometry, no external artwork.
            roof = .25 <= b <= .43 and abs(a-.5) <= (b-.25)*1.7
            lintel = .22 <= a <= .78 and .42 <= b <= .47
            columns = .47 <= b <= .7 and any(abs(a-c) <= .035 for c in [.3,.433,.567,.7])
            steps = (.21 <= a <= .79 and .71 <= b <= .75) or (.17 <= a <= .83 and .77 <= b <= .81)
            if roof or lintel or columns or steps:
                color = (250,248,244,255)
            if .47 <= a <= .53 and .30 <= b <= .34:
                color = (166,75,71,255)
            pixels.extend(color)
    def chunk(kind,data):
        return struct.pack('!I',len(data))+kind+data+struct.pack('!I',zlib.crc32(kind+data)&0xffffffff)
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!2I5B',size,size,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(pixels))+chunk(b'IEND',b'')


def write(path,size):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_bytes(icon(size))


for size in [192,512]:
    for prefix in ['Icon','Icon-maskable']:
        write(ROOT/f'app/web/icons/{prefix}-{size}.png',size)
write(ROOT/'app/web/favicon.png',32)
for folder,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    write(ROOT/f'app/android/app/src/main/res/mipmap-{folder}/ic_launcher.png',size)
ios = ROOT/'app/ios/Runner/Assets.xcassets/AppIcon.appiconset'
for entry in json.loads((ios/'Contents.json').read_text())['images']:
    if 'filename' in entry:
        size = math.ceil(float(entry['size'].split('x')[0])*float(entry['scale'].removesuffix('x')))
        write(ios/entry['filename'],size)
