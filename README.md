# Resources monitor - Plasma 6 widget

Plasmoid for monitoring CPU, memory, network traffic, GPUs and disks IO.

> ⚠️ This branch is for unreleased Plasma 6 version.
>
> For the Plasma 5 version please check at [Plasma/5.27](https://github.com/orblazer/plasma-applet-resources-monitor/tree/Plasma/5.27) branch

## Why this project ?

This project was originally developed by [@kotelnik](https://github.com/kotelnik) ([Resources Monitor - Pling](https://www.pling.com/p/998908)) and the objective was to only porting the support through KDE versions.
But with the time this widget have gain a lot configurations and metrics can be tracked, so that evolution led the project to the detachment of the original one.

## Installation

1. Install the **dependencies** :

   **required dependencies**:

   - `libksysguard` (normally include by default)

   **optional dependencies**:

   - `plasma-addons` (or similar name) : This is only required if you want select an application to run

2. Install the widget :

   - **From GUI**:

     1. Add Widgets...
     2. Get new widgets
     3. Search `Resources Monitor`
     4. Install the last version

   - **Manually**: find this applet and install through the first item with `.plasmoid` extension

## You love this project ?

Think to [sponsor me on Paypal](https://www.paypal.me/orblazer) for help me to maintain that project !

## Contribute/Debug

1. Clone this repo
2. Run the app
   - _With NPM_: `npm run dev`
   - _With Yarn_: `yarn dev`
   - _Shell_: `./scripts/test.sh`
