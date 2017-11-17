defmodule FakeHackney do
  def stream(_url, _pid) do
    {:ok, :ref}
  end

  def stream_next(_ref) do
  end
end

defmodule TestConsumer do
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, {producer, self()})
  end

  def init({producer, owner}) do
    {:consumer, owner, subscribe_to: [producer]}
  end

  def handle_events(events, _from, owner) do
    send(owner, {:received, events})
    {:noreply, [], owner}
  end
end

defmodule Particle.StreamTest do
  use ExUnit.Case

  alias Particle.Stream.Event
  alias Particle.Stream

  describe "it emits events when a complete event is received" do
    {:ok, stage} = Stream.start_link('http://fake.com', FakeHackney)
    {:ok, _cons} = TestConsumer.start_link(stage)

    send(stage, {:hackney_response, :ref, "event: foo"})
    send(stage, {:hackney_response, :ref, ~s(data: {"data": {"foo": "bar"}})})

    assert_receive {:received, [%Event{coreid: nil, data: %{foo: "bar"}, event: "foo", published_at: nil, ttl: nil}]}
  end

  describe "it emits events when a complete event occurs on one line" do
    {:ok, stage} = Stream.start_link('http://fake.com', FakeHackney)
    {:ok, _cons} = TestConsumer.start_link(stage)

    send(stage, {:hackney_response, :ref, ~s(event: foo\ndata: {"data": {"foo": "bar"}})})

    assert_receive {:received, [%Event{coreid: nil, data: %{foo: "bar"}, event: "foo", published_at: nil, ttl: nil}]}
  end
end
