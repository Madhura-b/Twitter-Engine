defmodule TwitterwebappWeb.SimulationChannel do
  use TwitterwebappWeb, :channel
  alias TwitterwebappWeb.Router.Helpers, as: Routes


  def join("room:simulate",_params,socket) do
    {:ok,socket}
  end

  def join("room:" <> _username, _params, socket) do
  #  {:ok, %{channel: channel_name}, socket}
     {:ok,socket}
  end



  def handle_in("simulate", msg, socket) do
    IO.puts("ENTERINGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   SIMULATING CHANNEL")
    IO.puts("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    IO.inspect(msg)
   # TwitterEngine.start_link(1)
    ClientSupervisor.simulate(String.to_integer(Enum.at(msg,0)),  String.to_integer(Enum.at(msg,1)))
    {:noreply,socket}
  end


end
