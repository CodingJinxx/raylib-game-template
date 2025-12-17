#!/bin/bash

# Quick Start Script for Raylib Game Template
# This script helps you get started quickly

echo "🎮 Raylib Game Template - Quick Start"
echo "======================================"
echo ""

# Check if raylib is installed
if ! pkg-config --exists raylib 2>/dev/null; then
    echo "⚠️  Warning: raylib not found!"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Install raylib with: brew install raylib"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Install raylib with: sudo apt-get install libraylib-dev"
    fi
    echo ""
fi

# Check if emscripten is available for web builds
if ! command -v emcc &> /dev/null; then
    echo "ℹ️  Note: Emscripten not found (only needed for web builds)"
    echo "   Install from: https://emscripten.org/docs/getting_started/downloads.html"
    echo ""
fi

echo "Available commands:"
echo "  make        - Build native executable"
echo "  make run    - Build and run the game"
echo "  make web    - Build for web (requires Emscripten)"
echo "  make serve  - Build and serve web version"
echo "  make clean  - Clean all build files"
echo ""

read -p "Would you like to build and run the game now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Building..."
    make
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Build successful! Starting game..."
        make run
    else
        echo ""
        echo "❌ Build failed. Please install raylib first."
    fi
fi
