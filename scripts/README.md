# Local Dev Scripts

## Setup

Copy `config.example.bat` to `config.bat` and set your WoW AddOns path:

```
copy config.example.bat config.bat
```

Then edit `config.bat` with your actual path.

## Auto-deploy watcher

Watches the addon folder for changes and deploys automatically.

Run from the VS Code terminal (from project root):

```
.\scripts\watch.bat
```

Or navigate to the `scripts/` folder and run:

```
.\watch.bat
```

## Manual deploy

To deploy once without the watcher:

```
.\scripts\deploy2.bat
```
