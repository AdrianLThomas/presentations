.PHONY: serve build

serve:
	npx @marp-team/marp-cli@latest -s -w ./slides

build:
	npx @marp-team/marp-cli@latest -o bin/index.html ./slides

clean:
	rm -rf ./build