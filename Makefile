
.PHONY: all

all: clean build run

clean:
	MIX_ENV=prod mix deps.clean --all

build:
	MIX_ENV=prod mix deps.get && ./compile-pb.sh && mix compile

run:
	MIX_ENV=prod PROXY_DATABASE_TYPE=mysql SPAWN_STATESTORE_KEY=3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE= iex --name hatch@127.0.0.1 -S mix
