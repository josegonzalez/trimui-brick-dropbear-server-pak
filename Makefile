TAG ?= DROPBEAR_2024.86
BUILD_DATE := "$(shell date -u +%FT%TZ)"
PAK_NAME := $(shell jq -r .label config.json)

clean:
	rm -f bin/evtest || true
	rm -f bin/dropbear || true
	rm -f bin/sdl2imgshow || true
	rm -f res/fonts/BPreplayBold.otf || true

build: bin/evtest bin/dropbear bin/sdl2imgshow res/fonts/BPreplayBold.otf

bin/evtest:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.evtest --progress plain -t app/evtest:$(TAG) .
	docker container create --name extract app/evtest:$(TAG)
	docker container cp extract:/go/src/github.com/freedesktop/evtest/evtest bin/evtest
	docker container rm extract
	chmod +x bin/evtest

bin/dropbear:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbear bin/dropbear
	docker container rm extract
	chmod +x bin/dropbear

bin/dbclient:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dbclient bin/dbclient
	docker container rm extract
	chmod +x bin/dbclient

bin/dropbearkey:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearkey bin/dropbearkey
	docker container rm extract
	chmod +x bin/dropbearkey

bin/dropbearconvert:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearconvert bin/dropbearconvert
	docker container rm extract
	chmod +x bin/dropbearconvert

bin/scp:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/scp bin/scp
	docker container rm extract
	chmod +x bin/scp

bin/sdl2imgshow:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.sdl2imgshow --progress plain -t app/sdl2imgshow:$(TAG) .
	docker container create --name extract app/sdl2imgshow:$(TAG)
	docker container cp extract:/go/src/github.com/kloptops/sdl2imgshow/build/sdl2imgshow bin/sdl2imgshow
	docker container rm extract
	chmod +x bin/sdl2imgshow

res/fonts/BPreplayBold.otf:
	curl -sSL -o res/fonts/BPreplayBold.otf "https://raw.githubusercontent.com/shauninman/MinUI/refs/heads/main/skeleton/SYSTEM/res/BPreplayBold-unhinted.otf"

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist
