#!/bin/sh

mv README README.bak
dzil clean
dzil build
mv README.bak README
