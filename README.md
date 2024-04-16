# ETagPlug

[![CircleCI](https://circleci.com/gh/alexocode/etag_plug.svg?style=svg)](https://circleci.com/gh/alexocode/etag_plug)
[![Coverage Status](https://coveralls.io/repos/github/alexocode/etag_plug/badge.svg?branch=master)](https://coveralls.io/github/alexocode/etag_plug?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/etag_plug.svg)](https://hex.pm/packages/etag_plug/)
[![License](https://img.shields.io/github/license/alexocode/etag_plug.svg)](https://github.com/alexocode/etag_plug/blob/master/LICENSE.md)

This plug generates shallow [ETags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag).

Shallow means that it uses the whole response to generate the ETag and does not care about the specific content of each response. It is not context sensitive. For a deep (speak context sensitive) generation of ETags you can take a look at [Phoenix ETag](https://github.com/michalmuskala/phoenix_etag).

**NOTE**:
While this plug may seem stale, it's just stable.
There is nothing else to do, it "just works".
As such don't be afraid to use it in production. 🙂

## Installation

The plug can be installed by adding `etag_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:etag_plug, "~> 1.0"}
  ]
end
```

Documentation can be found at: [https://hexdocs.pm/etag_plug](https://hexdocs.pm/etag_plug)

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

A full configuration equal to the defaults could look like this:

```elixir
config :etag_plug,
  generator: ETag.Generator.SHA1,
  methods: ["GET"],
  status_codes: [200]
```

Each of these options is explained in detail below.

### `generator`

Expects a module implementing the `ETag.Generator` behaviour. The plug ships with a number of "default" generators:

- `ETag.Generator.MD5`
- `ETag.Generator.SHA1`
- `ETag.Generator.SHA512`

__Default__: `Application.get_env(:etag_plug, :generator, ETag.Generator.SHA1)`

### `methods`

Expects a list of strings, describing the HTTP methods for which ETags should be generated and evaluated.

__Default__: `Application.get_env(:etag_plug, :methods, ["GET"])`

### `status_codes`

Expects an enumerable of integers (or status atoms) which define the statuses for which ETags should be handled and generated.

__Default__: `Application.get_env(:etag_plug, :status_codes, [200])`
