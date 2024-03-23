# Resources monitor (fork) - Plasma widget

Plasmoid for monitoring CPU, memory and network traffic

## Why this project ?

This project was originally developed by @kotelnik ([Resources Monitor - Pling](https://www.pling.com/p/998908)) and mostly only for porting the maintenance through KDE versions.
But now this widget have a lot more configurations and metrics can be tracked.

The evolution of this project led it to a new name and the detachment of the fork.

## Installation

1. Install the **required dependencies** :

   - `libksysguard` (normally include by default)

2. Install the widget :

   - **From GUI**:

     1. Add Widgets...
     2. Get new widgets
     3. Search `Resources Monitor - fork`
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
