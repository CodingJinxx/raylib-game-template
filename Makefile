# Project
NAME    := game
SRC     := main.c
CC      := gcc

# Detect OS
UNAME_S := $(shell uname -s)

# Flags
CFLAGS  := -std=c11 -Wall -Wextra -O2

# macOS-specific settings
ifeq ($(UNAME_S),Darwin)
    CFLAGS  += $(shell pkg-config --cflags raylib 2>/dev/null || echo "-I/opt/homebrew/include -I/usr/local/include")
    LDFLAGS := $(shell pkg-config --libs raylib 2>/dev/null || echo "-L/opt/homebrew/lib -L/usr/local/lib -lraylib")
    LDFLAGS += -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL
else
    # Linux/other settings
    CFLAGS  += $(shell pkg-config --cflags raylib)
    LDFLAGS := $(shell pkg-config --libs raylib)
endif

# Targets
all: $(NAME)

$(NAME): $(SRC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(NAME) $(NAME).wasm $(NAME).js $(NAME).html $(NAME).data
	rm -rf raylib-web raylib-src

run: $(NAME)
	./$(NAME)

# WebAssembly target
RAYLIB_WEB := raylib-web
RAYLIB_WEB_INCLUDE := $(RAYLIB_WEB)/include
RAYLIB_WEB_LIB := $(RAYLIB_WEB)/lib/libraylib.a

web: $(NAME).html
	@echo "WebAssembly build complete!"
	@echo "Run 'make serve' to start a local web server"

$(RAYLIB_WEB_LIB):
	@echo "Downloading raylib for web..."
	@mkdir -p $(RAYLIB_WEB)
	@if [ ! -d "raylib-src" ]; then \
		git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git raylib-src; \
	fi
	@echo "Building raylib for web..."
	@cd raylib-src/src && emmake make PLATFORM=PLATFORM_WEB -B
	@mkdir -p $(RAYLIB_WEB_INCLUDE) $(dir $(RAYLIB_WEB_LIB))
	@cp raylib-src/src/libraylib.a $(RAYLIB_WEB_LIB)
	@cp raylib-src/src/raylib.h $(RAYLIB_WEB_INCLUDE)/
	@cp raylib-src/src/raymath.h $(RAYLIB_WEB_INCLUDE)/
	@cp raylib-src/src/rlgl.h $(RAYLIB_WEB_INCLUDE)/
	@echo "raylib for web is ready!"

$(NAME).html: $(SRC) $(RAYLIB_WEB_LIB)
	emcc $(SRC) -o $(NAME).html \
		-std=c11 -Wall -Wextra -O2 \
		-s USE_GLFW=3 \
		-s ASYNCIFY \
		-s TOTAL_MEMORY=67108864 \
		-s FORCE_FILESYSTEM=1 \
		--preload-file resources \
		--shell-file shell.html \
		-DPLATFORM_WEB \
		-I$(RAYLIB_WEB_INCLUDE) \
		$(RAYLIB_WEB_LIB)

# Simple HTTP server for testing
serve:
	@echo "Starting web server at http://localhost:8000"
	@echo "Opening http://localhost:8000/$(NAME).html in your browser"
	@echo "Press Ctrl+C to stop the server"
	@open http://localhost:8000/$(NAME).html || xdg-open http://localhost:8000/$(NAME).html || true &
	@python3 -m http.server 8000

# Watch for changes and rebuild
watch:
	@echo "👀 Watching for changes... (Press Ctrl+C to stop)"
	@echo "Will rebuild and run on file changes"
	@echo ""
	@if command -v fswatch >/dev/null 2>&1; then \
		echo "Using fswatch for file monitoring"; \
		fswatch -o $(SRC) resources/ shell.html 2>/dev/null | while read num; do \
			clear; \
			echo "🔨 Change detected, rebuilding..."; \
			$(MAKE) run && echo "✅ Build complete!"; \
		done; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		echo "Using inotifywait for file monitoring"; \
		while true; do \
			inotifywait -qre modify,create,delete $(SRC) resources/ shell.html 2>/dev/null; \
			clear; \
			echo "🔨 Change detected, rebuilding..."; \
			$(MAKE) run && echo "✅ Build complete!"; \
		done; \
	else \
		echo "Using polling (install fswatch for better performance: brew install fswatch)"; \
		LAST_HASH=$$(find $(SRC) resources/ shell.html -type f -exec md5 {} \; 2>/dev/null | md5 | cut -d' ' -f1); \
		while true; do \
			sleep 1; \
			CURRENT_HASH=$$(find $(SRC) resources/ shell.html -type f -exec md5 {} \; 2>/dev/null | md5 | cut -d' ' -f1); \
			if [ "$$CURRENT_HASH" != "$$LAST_HASH" ]; then \
				clear; \
				echo "🔨 Change detected, rebuilding..."; \
				$(MAKE) run && echo "✅ Build complete!"; \
				LAST_HASH=$$CURRENT_HASH; \
			fi; \
		done; \
	fi

# Watch for changes and rebuild web version
watch-web:
	@echo "👀 Watching for web changes... (Press Ctrl+C to stop)"
	@echo "Will rebuild web version on file changes"
	@echo "Starting web server at http://localhost:8000"
	@echo "Open http://localhost:8000/$(NAME).html in your browser"
	@echo ""
	@# Start the web server in the background
	@python3 -m http.server 8000 > /dev/null 2>&1 & \
	SERVER_PID=$$!; \
	echo "Server started (PID: $$SERVER_PID)"; \
	echo ""; \
	trap "kill $$SERVER_PID 2>/dev/null; echo 'Server stopped'" EXIT; \
	if command -v fswatch >/dev/null 2>&1; then \
		echo "Using fswatch for file monitoring"; \
		fswatch -o $(SRC) resources/ shell.html 2>/dev/null | while read num; do \
			echo ""; \
			echo "🔨 Change detected, rebuilding web..."; \
			$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
		done; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		echo "Using inotifywait for file monitoring"; \
		while true; do \
			inotifywait -qre modify,create,delete $(SRC) resources/ shell.html 2>/dev/null; \
			echo ""; \
			echo "🔨 Change detected, rebuilding web..."; \
			$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
		done; \
	else \
		echo "Using polling (install fswatch for better performance: brew install fswatch)"; \
		LAST_HASH=$$(find $(SRC) resources/ shell.html -type f -exec md5 {} \; 2>/dev/null | md5 | cut -d' ' -f1); \
		while true; do \
			sleep 2; \
			CURRENT_HASH=$$(find $(SRC) resources/ shell.html -type f -exec md5 {} \; 2>/dev/null | md5 | cut -d' ' -f1); \
			if [ "$$CURRENT_HASH" != "$$LAST_HASH" ]; then \
				echo ""; \
				echo "🔨 Change detected, rebuilding web..."; \
				$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
				LAST_HASH=$$CURRENT_HASH; \
			fi; \
		done; \
	fi

.PHONY: all clean run web serve watch watch-web
