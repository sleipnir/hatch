#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

protoc --elixir_out=gen_descriptors=true:./lib/hatch --proto_path=priv/protos/hatch priv/protos/hatch/permitting.proto