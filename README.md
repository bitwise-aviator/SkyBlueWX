# SkyBlueWX
![GitHub](https://img.shields.io/github/license/bitwise-aviator/SkyBlueWX)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/bitwise-aviator/SkyBlueWX)
[![macOS](https://svgshare.com/i/ZjP.svg)](https://svgshare.com/i/ZjP.svg)

A simple aviation weather app for iOS

### Project status
**Feature freeze is over!** More features are now being added.

### Eye candy, anyone?
Check out the **screenshots** folder to see how it's coming along :)

### What's done?
- WeatherView is functional, but can add more.
- ListView is functional.

### What's next?
- Study getting the AWC cached data: each CSV download's about 900kb in size for 2k+ records. Need to look at resulting struct size. Currently starting to notice latency issues when several airports are requested.
- FlightPlanView, allows users to look at origin, destination, and alternate weather in one screen.
- SettingsView, currently, most settings can be changed on taps on WeatherView or through iOS settings, want to have a dedicated one on app.
- MapView, tied to whether I decide to start using AWC's cached 5-minute data vs. per-airport API queries, and then we'll take it from there.
