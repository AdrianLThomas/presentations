.PHONY: serve build build-slides build-index clean

SLIDES_DIR := ./slides
BUILD_DIR := ./build

serve:
	npx @marp-team/marp-cli@latest -s -w $(SLIDES_DIR)

build: build-slides build-index

build-slides:
	mkdir -p $(BUILD_DIR)
	find $(SLIDES_DIR) -name '*.md' -exec sh -c \
		'npx @marp-team/marp-cli@latest "$$1" --html -o "$(BUILD_DIR)/$$(basename "$$1" .md).html"' _ {} \;

build-index:
	@echo "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Slides</title></head><body>" > $(BUILD_DIR)/index.html
	@echo "<h1>Slides</h1><ul>" >> $(BUILD_DIR)/index.html
	@for f in $(BUILD_DIR)/*.html; do \
		name=$$(basename $$f); \
		if [ "$$name" != "index.html" ]; then \
			echo "<li><a href=\"$$name\">$$name</a></li>" >> $(BUILD_DIR)/index.html; \
		fi \
	done
	@echo "</ul></body></html>" >> $(BUILD_DIR)/index.html

clean:
	rm -rf $(BUILD_DIR)
