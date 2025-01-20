#!/bin/bash
export MIX_ENV=prod

echo "Fetch dependencies..."
mix deps.get --only prod > /dev/null

echo "Compiling..."
mix compile > /dev/null
mix assets.deploy > /dev/null

echo "Creating release..."
mix release --overwrite > /dev/null
mix assets.clean > /dev/null
tar zcvf _build/prod/profitry.tgz -C _build/prod/rel profitry > /dev/null
