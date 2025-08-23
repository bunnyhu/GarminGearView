# Bunny's Gearview
![GitHub Release](https://img.shields.io/github/v/release/bunnyhu/GarminGearView)
![GitHub Release Date](https://img.shields.io/github/release-date/bunnyhu/GarminGearView)

This Garmin EDGE data field attempts to calculate the selected chainring and cassette gears on a bike equipped with manual gear shift.
There is already "gear view" apps in IQ store, why use this?
My application can handle up to 9 bikes, supports different display modes in text and graphic style and allows to record information in your activity.

Please note: For calculation the speed and cadence informations are required.

## Supported and tested devices
Edge Explore 2

## Supported devices but tested only in simulator
Edge 1050, Edge 1040 &Solar, Edge 540 &Solar, Edge 840 &Solar, Edge MTB

## Using
The app setup and the bicycle configuration is avaiable from Garmin Express on desktop computer or IQ Store app on smartphone.
The bicycles can be configured using a string with the following format:

**NAME:WHEELSIZE:CHAINRINGS:CASSETTE**

All data is separated by a single colon (:) without space.

- NAME: A name up to 16 characters long, which will appear at the top of the field. Most character is valid except colon.
- WHEELSIZE: The circumference of the wheel in millimeters. Only numbers.
- CHAINRINGS: The distribution of the front gear (chainrings), with the cog numbers separated by commas.
- CASSETTE: The distribution of the rear gear (cassette), with the cog numbers separated by commas.

**Example bicycle configuration strings:**
- Gravel 2x12:2140:30,46:11,12,13,14,15,17,19,21,24,27,30,34
- Trekking 3x8:2165:48,38,28:13,14,15,17,19,21,23,26
- MTB 1x12:2160:40:10,12,14,16,18,21,24,28,32,36,42,52

With a wrong format string you can crash the datafield, so please take care of the correct syntax!
It is recommended that you continuously fill the bicycle data and do not leave any text fields blank.

## Bike configurator page
There is a bike configurator website that help you to make this string with some standard wheel and tire size.
Also there is a calculated number in the Garmin's speed sensor info page!
http://github.io/bunnyhu/GarminGearView

## Garmin IQ store

## Project home
https://github.com/bunnyhu/GarminGearView
