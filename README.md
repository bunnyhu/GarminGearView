# Bunny's Gearview pro
![GitHub Release](https://img.shields.io/github/v/release/bunnyhu/GarminGearView)
![GitHub Release Date](https://img.shields.io/github/release-date/bunnyhu/GarminGearView)

This Garmin EDGE data field attempts to calculate the selected chainring and cassette gears on a bike equipped with manual gear shift.

👀 *"There is already gearview apps in IQ store, why use this?"*
My application can handle up to 9 bikes, supports different display modes in text and graphic style and allows to record information in your activity.

![App Screenshot](https://github.com/bunnyhu/GarminGearView/blob/main/IQ-store/images1.png)
![App Screenshot](https://github.com/bunnyhu/GarminGearView/blob/main/IQ-store/images2.png)
![App Screenshot](https://github.com/bunnyhu/GarminGearView/blob/main/IQ-store/images4.png)

## Supported devices
**Fully tested:** Edge Explore 2  
**Tested only in simulator:** Edge 1050, Edge 1040, Edge 540, Edge 840, Edge MTB  
💡*Please note: For calculation the speed (sensor or GPS) and cadence informations are required.*

## How to setting the app
The app setup and the bicycle configuration is avaiable from Garmin Express on desktop computer or IQ Store app on smartphone.

- **Record speed gear:** Save gear informations into the activity .FIT file. You can see as graph in Connect.
- **Event if tapping:** If your device have touch screen, you can set an event for tapping on the datafield.  
It can rotate the bikes or the display styles or just disabled.
- **Display style:** Choice one of the text and graphics display styles.
- **Active bicycle:** You can save bike up to 9 but only one can active.

### The bicycles data can be configured using a string with the following format:
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

💡*It is recommended that you continuously fill the bicycle data and do not leave any text fields blank.*

## Bike configurator page
With a wrong format string you may crash the datafield. 
If you are not sure, I made a bike configurator that help to make this string - with some standard wheel and tire size.  
https://bunnyhu.github.io/GarminGearView  
*Also there is a calculated number in the Garmin's speed sensor info page on your Edge!*

## Garmin IQ store
https://apps.garmin.com/hu-HU/developer/26b73905-52ae-4a66-ad58-32a801bc51d5/apps

## Project home
https://github.com/bunnyhu/GarminGearView
