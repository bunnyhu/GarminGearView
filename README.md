# Bunny's Gearview pro
![GitHub Release](https://img.shields.io/github/v/release/bunnyhu/...)
![GitHub Release Date](https://img.shields.io/github/release-date/bunnyhu/...)

This Garmin EDGE data field attempts to calculate the selected chainring and cassette gears on a bike equipped with a manual gear shift.

The application can handle up to 9 bikes and supports a number of different display modes in text or graphic style.
It is also allows you to record gear shift data in your activity FIT data for later analysis.

Please note: For its calculations the speed and cadence informations are required.

## Supported and tested devices
Edge Explore 2

## Using
The bicycles can be configured using a string with the following format from Garmin Express on desktop computer or IQ Store app on smartphone.

**NAME:WHEELSIZE:CHAINRINGS:CASSETTE**

All data is separated by a single colon (:) without space.
The gear cog numbers are listed separated by commas (,) with no spaces or other characters.

- NAME: A name up to 16 characters long, which will appear at the top of the field. Most character is valid except colon.
- WHEELSIZE: The circumference of the wheel in millimeters.
- CHAINRINGS: The front gear distribution (chainrings), with the cog numbers separated by commas.
- CASSETTE: The rear gear distribution (cassette), with the cog numbers separated by commas.

For the wheel size there is a few official size in the Tire_size_chart_ENG.pdf file. Also there is a calculated number in the Garmin's speed sensor info page!

With a wrong format string you can crash the datafield, so please take care of the correct syntax!

### Example bicycle configuration string ###
- Gravel 2x12:2151:30,46:11,12,13,14,15,17,19,21,24,27,30,34
- Trekking 3x8:2165:48,38,28:13,14,15,17,19,21,23,26
- MTB 1x12:2160:40:10,12,14,16,18,21,24,28,32,36,42,52

## Garmin IQ store

## Project home
https://github.com/bunnyhu/...
