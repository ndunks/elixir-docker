# Docker Compose Elixir Example

- Using local directory as GIT Repo
- building index at startup

## Elixir Docker Compose

``` docker-compose.yml
version: '3'

services:
  elixir:
    build:
      context: ./elixir-docker
      #dockerfile: ./elixir-docker/Dockerfile
      args:
        PROJECT: esp8266-rtos-sdk
    restart: unless-stopped
    container_name: elixir
    ports:
      - '1080:80'
    volumes:
      - /mobile/elixir-data:/srv/elixir-data
      - /home/rifin/app/ESP8266_RTOS_SDK/.git:/srv/elixir-data/esp8266-rtos-sdk/repo

```
