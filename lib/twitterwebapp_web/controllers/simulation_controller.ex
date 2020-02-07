defmodule TwitterwebappWeb.SimulationController do
  use TwitterwebappWeb, :controller

  def simulate(conn,_params) do
    render(conn,"simulate.html")
  end

end
