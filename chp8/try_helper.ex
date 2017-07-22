defmodule TryFunction do

  def try_this(fun) do
     try do
       fun.()
       IO.puts "No error"
 
     catch type, value -> 
       IO.puts "Error\n #{inspect type}\n #{inspect value}"
     end
  end

end
