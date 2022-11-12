defmodule ProfitryCliTest do
  use ExUnit.Case
  doctest ProfitryCli

  test "greets the world" do
    assert ProfitryCli.hello() == :world
  end
end
