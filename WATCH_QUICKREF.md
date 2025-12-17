# Quick Reference - Watch Mode

## 🎯 Quick Start

```bash
# Native development (rebuilds and runs)
make watch

# Web development (rebuilds + serves)
make watch-web
```

Press **Ctrl+C** to stop.

## 📦 Optional Install (for instant detection)

```bash
# macOS
brew install fswatch

# Linux
sudo apt-get install inotify-tools
```

Without these: Polling mode (checks every 1-2 seconds) - still works great!

## 🎨 Typical Workflow

### Native Development
```
Terminal: make watch
Editor:   Edit main.c → Save
Result:   Auto-rebuilds → Runs game
```

### Web Development
```
Terminal: make watch-web
Browser:  Open http://localhost:8000/game.html
Editor:   Edit main.c → Save
Browser:  Refresh to see changes
```

## 📋 All Commands

```bash
make           # Build native once
make run       # Build and run once
make web       # Build web once
make serve     # Serve web (no auto-rebuild)
make watch     # Watch + auto-rebuild native
make watch-web # Watch + auto-rebuild + serve web
make clean     # Clean build files
```

## 💡 Pro Tips

1. **Split screen:** Editor left, Browser/Game right
2. **Install fswatch:** Instant detection vs 1-2 sec polling
3. **Hard refresh:** Cmd+Shift+R (Mac) or Ctrl+Shift+R
4. **Check terminal:** Shows build status and errors

## 🔥 What's Watched

- `main.c` - Your game code
- `resources/` - All assets
- `shell.html` - Web page template

Any change → Auto rebuild!

---

**Full documentation:** See [WATCH_MODE.md](WATCH_MODE.md)
