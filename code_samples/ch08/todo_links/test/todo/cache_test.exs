defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    Todo.System.start_link()
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    Todo.System.start_link()
    jane = Todo.Cache.server_process("jane")
    Todo.Server.add_entry(jane, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(jane, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end

  test "persistence" do
    {:ok, supervisor} = Todo.System.start_link()

    john = Todo.Cache.server_process("john")
    Todo.Server.add_entry(john, %{date: ~D[2018-12-20], title: "Shopping"})
    assert 1 == length(Todo.Server.entries(john, ~D[2018-12-20]))

    Supervisor.stop(supervisor)
    Todo.System.start_link()

    entries =
      "john"
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(~D[2018-12-20])

    assert [%{date: ~D[2018-12-20], title: "Shopping"}] = entries
  end
end
