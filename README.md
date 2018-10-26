# ETagPlug

[![CircleCI](https://circleci.com/gh/Zeeker/etag_plug.svg?style=svg)](https://circleci.com/gh/Zeeker/etag_plug)
[![Coverage Status](https://coveralls.io/repos/github/Zeeker/etag_plug/badge.svg?branch=master)](https://coveralls.io/github/Zeeker/etag_plug?branch=master)

This plug generates shallow [ETags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag).

Shallow means that it uses the whole response to generate the ETag and does not care about the specific content of each response. It is not context sensitive. For a deep (speak context sensitive) generation of ETags you can take a look at [Phoenix ETag](https://github.com/michalmuskala/phoenix_etag).

## Installation

The plug can be installed by adding `etag_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:etag_plug, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at [https://hexdocs.pm/etag_plug](https://hexdocs.pm/etag_plug).

# Usage

You can simply use the plug without any configuration, it then defaults to the configuration as specified in the "Configuration" section.

```elixir
plug ETag.Plug
```

You can also provide a number of options, see the "Configuration" section for details.

```elixir
plug ETag.Plug,
  generator: MyCustomGenerator,
  methods: ["GET", "HEAD"],
  status_codes: [:ok, 201, :not_modified]
```

## Configuration

### `generator`

Expects a module implementing the `ETag.Generator` behaviour. The plug ships with a number of "default" generators:

- `ETag.Generator.MD5`
- `ETag.Generator.SHA1`
- `ETag.Generator.SHA512`

__Default__: `Application.fetch_env!(:etag_plug, :generator)`

### `methods`

Expects a list of strings, describing the HTTP methods for which ETags should be generated and evaluated.

__Default__: `Application.fetch_env!(:etag_plug, :methods)`

### `status_codes`

Expects an enumerable of integers (or status atoms) which define the statuses for which ETags should be handled and generated.

__Default__: `Application.fetch_env!(:etag_plug, :status_codes)`