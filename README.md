# Magikoopa
[![v2](https://img.shields.io/endpoint?url=https%3A%2F%2Ftwbadges.glitch.me%2Fbadges%2Fv2)](https://developer.twitter.com/en/docs/twitter-api)
[![v1.1](https://img.shields.io/endpoint?url=https%3A%2F%2Ftwbadges.glitch.me%2Fbadges%2Fstandard)](https://developer.twitter.com/en/docs/twitter-api/v1)

## Dev
### using Docker
```shell
$ docker build -t magikoopa:latest .
$ docker run -it --rm magikoopa:latest julia
```

### using Poetry
```shell
$ poetry install
$ poetry shell
.venv> julia --project=@.
```