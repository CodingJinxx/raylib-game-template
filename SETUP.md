# Setup Guide

This guide will help you set up the Raylib Game Template and create your first game.

## ✅ What's Included

Your template includes:
- ✨ Complete Makefile build system
- 🎮 Sample game with bouncing ball
- 🌐 Web build support (Emscripten)
- 🎨 Modern HTML5 shell for web deployment
- 🔧 GitHub Actions CI/CD workflow
- 📦 Automatic raylib dependency management for web

## 🚀 Quick Start (3 Steps)

### 1. Install Dependencies

**macOS:**
```bash
brew install raylib
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install libraylib-dev
```

**For Web Builds (Optional):**
```bash
# Install Emscripten
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

### 2. Build and Run

```bash
# Build native version
make

# Run the game
make run

# Or do both at once
./quickstart.sh
```

### 3. Build for Web

```bash
# Build web version (automatically downloads and compiles raylib for web)
make web

# Start local server and open in browser
make serve
```

That's it! 🎉

## 📝 Creating Your Game

### Edit the Main File

Open `main.c` and modify the game loop:

```c
// Update section - your game logic
if (IsKeyPressed(KEY_SPACE)) {
    // Handle player input
}

// Draw section - render your game
BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Hello Game!", 10, 10, 20, BLACK);
EndDrawing();
```

### Add Assets

1. Place assets in the `resources/` folder
2. Load them in your code:

```c
Font font = LoadFont("resources/myfont.ttf");
Texture2D texture = LoadTexture("resources/sprite.png");
Sound sound = LoadSound("resources/beep.wav");
```

### Customize Window

Change window settings in `main.c`:

```c
#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720

InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "My Awesome Game");
```

## 🌐 Deploying to GitHub Pages

### Option 1: Automatic (GitHub Actions)

1. Push your code to GitHub
2. Enable GitHub Pages in repository settings
3. Set source to `gh-pages` branch
4. Every push to `main` will automatically build and deploy

### Option 2: Manual

```bash
# Build for web
make web

# Create gh-pages branch
git checkout -b gh-pages

# Add web files
git add game.html game.js game.wasm game.data
git commit -m "Deploy web build"
git push origin gh-pages

# Go back to main branch
git checkout main
```

Your game will be available at: `https://yourusername.github.io/your-repo-name/game.html`

## 🛠️ Makefile Commands

| Command | Description |
|---------|-------------|
| `make` | Build native executable |
| `make run` | Build and run native version |
| `make web` | Build for web (creates .html, .js, .wasm files) |
| `make serve` | Start local server and open in browser |
| `make clean` | Remove all build files |

## 📚 Learning Resources

- **Raylib Cheatsheet**: https://www.raylib.com/cheatsheet/cheatsheet.html
- **Raylib Examples**: https://www.raylib.com/examples.html
- **API Reference**: https://www.raylib.com/
- **Community**: https://discord.gg/raylib

## 🐛 Troubleshooting

### "raylib not found"

**macOS:**
```bash
brew install raylib
```

**Linux:**
```bash
sudo apt-get install libraylib-dev
```

### Web build fails

Make sure Emscripten is installed and activated:
```bash
source /path/to/emsdk/emsdk_env.sh
```

### Game doesn't run on web

- Check browser console for errors
- Make sure all assets are in `resources/` folder
- Assets paths must be relative: `"resources/file.png"`

## 🎯 Next Steps

1. ✏️ Edit `main.c` to create your game logic
2. 🎨 Add assets to `resources/` folder
3. 🧪 Test with `make run`
4. 🌐 Build for web with `make web`
5. 🚀 Deploy to GitHub Pages

## 💡 Tips

- Start small - get something working first, then expand
- Test frequently with `make run`
- Use raylib examples for inspiration
- The template handles all the build complexity for you
- Web builds work the same as native - just use `make web`

## 🤝 Need Help?

- Open an issue in this repository
- Check the [raylib Discord](https://discord.gg/raylib)
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

Happy game development! 🎮✨
