#!/usr/bin/env python3
"""Regenerate the land mask the globe draws its continents from.

A 1-bit raster of where land is, at half-degree resolution: 720x360 cells
packed into 32,400 bytes. That is the whole of the Earth's coastlines in less
space than one small photograph, which is why the globe needs no imagery.

Source: Natural Earth 1:50m land polygons, public domain.
https://www.naturalearthdata.com/about/terms-of-use/

    python3 -m venv .venv && .venv/bin/pip install pyshp shapely
    curl -LO https://naciscdn.org/naturalearth/50m/physical/ne_50m_land.zip
    unzip ne_50m_land.zip -d ne50
    .venv/bin/python Tools/generate-land-mask.py ne50/ne_50m_land.shp \
        > Packages/Globe/Sources/Globe/Resources/land-mask.bin
"""
import sys

import shapefile
from shapely.geometry import Point, shape
from shapely.strtree import STRtree

WIDTH, HEIGHT = 720, 360


def main(path):
    reader = shapefile.Reader(path)
    polygons = [shape(record.shape.__geo_interface__) for record in reader.shapeRecords()]
    # An index, because testing 259,200 cells against 1,400 polygons one by one
    # is minutes of work and against their bounding boxes is seconds.
    index = STRtree(polygons)

    bits = bytearray(WIDTH * HEIGHT // 8)
    land = 0
    for row in range(HEIGHT):
        # Cell centres, so a cell is land when its middle is on land.
        latitude = 90.0 - (row + 0.5) * 180.0 / HEIGHT
        for column in range(WIDTH):
            longitude = -180.0 + (column + 0.5) * 360.0 / WIDTH
            point = Point(longitude, latitude)
            # The index returns everything whose bounding box could contain the
            # point; only those few need the real containment test.
            if any(polygons[i].contains(point) for i in index.query(point)):
                offset = row * WIDTH + column
                bits[offset >> 3] |= 1 << (7 - (offset & 7))
                land += 1

    sys.stderr.write(f"{land} land cells of {WIDTH * HEIGHT} ({land * 100 // (WIDTH * HEIGHT)}%)\n")
    sys.stdout.buffer.write(bytes(bits))


if __name__ == "__main__":
    main(sys.argv[1])
