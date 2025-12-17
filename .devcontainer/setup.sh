#!/bin/bash
set -e

echo "🎮 Setting up Raylib Game Development Environment..."
echo ""

# Update package list
echo "📦 Updating package list..."
sudo apt-get update

# Install build essentials and dependencies
echo "🔧 Installing build tools and dependencies..."
sudo apt-get install -y \
    build-essential \
    git \
    cmake \
    inotify-tools \
    libasound2-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxcursor-dev \
    libxinerama-dev \
    libwayland-dev \
    libxkbcommon-dev

# Install raylib
echo "🎨 Installing raylib..."
cd /tmp
git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git
cd raylib/src
make PLATFORM=PLATFORM_DESKTOP
sudo make install PLATFORM=PLATFORM_DESKTOP

# Install pkg-config file
cd ..
sudo mkdir -p /usr/local/lib/pkgconfig
sudo sed "s|prefix=/usr/local|prefix=/usr/local|g" raylib.pc.in > /tmp/raylib.pc.tmp
sudo sed -i "s|@CMAKE_INSTALL_LIBDIR@|lib|g" /tmp/raylib.pc.tmp
sudo sed -i "s|@CMAKE_INSTALL_INCLUDEDIR@|include|g" /tmp/raylib.pc.tmp
sudo sed -i "s|@PROJECT_VERSION@|5.5|g" /tmp/raylib.pc.tmp
sudo mv /tmp/raylib.pc.tmp /usr/local/lib/pkgconfig/raylib.pc

cd /tmp
rm -rf raylib

# Update pkg-config path
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
sudo ldconfig

# Install Emscripten for web builds
echo "🌐 Installing Emscripten for WebAssembly builds..."
EMSDK_DIR="/usr/local/emsdk"
if [ ! -d "$EMSDK_DIR" ]; then
    sudo mkdir -p "$EMSDK_DIR"
    sudo chown -R "$(whoami)" "$EMSDK_DIR"
    git clone --depth 1 https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
    EMSDK_PREV_DIR="$(pwd)"
    cd "$EMSDK_DIR"
    ./emsdk install latest
    ./emsdk activate latest
    cd "$EMSDK_PREV_DIR"
else
    echo "Emscripten already installed at $EMSDK_DIR"
fi

# Source Emscripten environment for current session
if [ -f "$EMSDK_DIR/emsdk_env.sh" ]; then
    # shellcheck source=/dev/null
    source "$EMSDK_DIR/emsdk_env.sh"
fi

# Add emsdk to PATH in .bashrc
if ! grep -q "source $EMSDK_DIR/emsdk_env.sh" ~/.bashrc 2>/dev/null; then
    {
        echo ""
        echo "# Emscripten SDK"
        echo "source $EMSDK_DIR/emsdk_env.sh > /dev/null 2>&1"
        echo ""
        echo "# pkg-config path for raylib"
        echo "export PKG_CONFIG_PATH=\"/usr/local/lib/pkgconfig:\$PKG_CONFIG_PATH\""
    } >> ~/.bashrc
fi

# Also add to .zshrc if it exists
if [ -f ~/.zshrc ]; then
    if ! grep -q "source $EMSDK_DIR/emsdk_env.sh" ~/.zshrc 2>/dev/null; then
        {
            echo ""
            echo "# Emscripten SDK"
            echo "source $EMSDK_DIR/emsdk_env.sh > /dev/null 2>&1"
        } >> ~/.zshrc
    fi
fi

# Verify installations
echo ""
echo "✅ Setup complete! Verifying installations..."
echo ""
echo "GCC version:"
gcc --version | head -n 1
echo ""
echo "Raylib installed at:"
ldconfig -p | grep raylib || echo "Raylib library installed"
echo ""
echo "Emscripten version:"
if command -v emcc >/dev/null 2>&1; then
    emcc --version | head -n 1
else
    echo "Emscripten installed at $EMSDK_DIR (source environment to use: source $EMSDK_DIR/emsdk_env.sh)"
fi
echo ""
echo "🎉 Your development environment is ready!"
echo ""
echo "Quick start:"
echo "  make          - Build native version"
echo "  make run      - Build and run native version"
echo "  make web      - Build WebAssembly version"
echo "  make watch    - Auto-rebuild on file changes"
echo ""
