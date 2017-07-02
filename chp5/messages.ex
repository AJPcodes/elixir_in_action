defmodule Messages do
  
  def run_query(query) do
    :timer.sleep(2000)
    IO.puts(query)
  end

  def async_query(query_def) do
    caller = self()
        
    # spawn(fn -> 
    #   query 
    #   |> run_query
    #   |> IO.puts
    #   |> send(caller, {}) 
    # end)
   spawn(fn ->
     send(caller, {:query_result, run_query(query_def)})
   end)  

  end

end 