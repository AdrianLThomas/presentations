.PHONY: serve build build-slides build-index clean

SLIDES_DIR := ./slides
BUILD_DIR := ./build

serve:
	npx @marp-team/marp-cli@latest -s -w $(SLIDES_DIR)

build: build-slides build-index

build-slides:
	mkdir -p $(BUILD_DIR)
	find $(SLIDES_DIR) -name '*.md' -exec sh -c '\
		slide_name=$$(basename "$$1" .md); \
		slide_dir="$(BUILD_DIR)/$$slide_name"; \
		mkdir -p "$$slide_dir"; \
		cp -r "$$(dirname "$$1")"/* "$$slide_dir/"; \
		npx @marp-team/marp-cli@latest "$$1" --html -o "$$slide_dir/index.html"' _ {} \;

build-index:
	@echo "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Slides</title></head><body>" > $(BUILD_DIR)/index.html
	@echo "<h1>Slides</h1><ul>" >> $(BUILD_DIR)/index.html
	@find $(BUILD_DIR) -type f -name "index.html" -exec sh -c '\
		dir=$$(dirname "$$1"); \
		name=$$(basename "$$dir"); \
		if [ "$$name" != "build" ]; then \
			echo "<li><a href=\"$$name/index.html\">$$name</a></li>" >> $(BUILD_DIR)/index.html; \
		fi' _ {} \;
	@echo "</ul></body></html>" >> $(BUILD_DIR)/index.html

clean:
	rm -rf $(BUILD_DIR)