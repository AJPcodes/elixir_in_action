defmodule ServerProcess do

  def start(callback_module) do
    spawn(fn -> 
      initial_state = callback_module.init
      loop(callback_module, initial_state)  
    end)
  end

  defp loop(callback_module, current_state) do
    reveive do
      {request, caller} -> 
        {response, new_state} = callback_module.handle_call(
          request,
          current_state
        )

        send (caller, {:response, response})

        loop(callback_module, new_state)

    end
  end

  def call(server_pid, request) do
    send(server_pid, {request, self})

    receive do
      {:response, repsonse} -> 
        response
    end
  end

end

defmodule KeyValueStore do 
  def init do
    Map.new
  end

  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
  
end

my_store = ServerProcess.start(KeyValueStore)
ServerProcess.call(my_store, {:put, :some_key, :some_value})
ServerProcess.call(my_store, {:get, :some_key})