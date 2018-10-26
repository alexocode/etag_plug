# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :etag_plug,
  generator: ETag.Generator.SHA1,
  methods: ["GET"],
  status_codes: [200]
