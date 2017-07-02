defmodule TodoServer do
  
  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message -> 
        process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})
  
    receive do
      {todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

end

defmodule TodoList do
  defstruct auto_id: 1, entries: Map.new()
  
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn(entry, todo_list_acc) ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %TodoList{todo_list |
      entries: new_entries,
      auto_id: auto_id + 1
    }
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) -> 
      entry  
    end)
  end

  def update_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries} 
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
  end

  def delete_entry(todo_list, %{} = entry) do
    new_entries = Map.delete(todo_list.entries, entry.id)
    %TodoList{todo_list | entries: new_entries}
  end

  def delete_entry(todo_list,  id) when is_integer(id) do
    new_entries = Map.delete(todo_list.entries, id)
    %TodoList{todo_list | entries: new_entries}
  end


end

defmodule TodoList.CsvImporter do

  def import(file_path) do
    File.stream!(file_path) 
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(
      fn(line) ->
        format_line(line)
      end
    )
    |> TodoList.new
  end


  defp format_line([ date | [ title | []]]) do

    formatted_date = String.split(date, "/", [])
    |> Enum.map(&String.to_integer(&1))
    |> format_date
    
    %{date: formatted_date, title: title}
    
  end 

  defp format_date([day | [ month | [ year]]]), do: {year, month, day} 

end

# my_todo = TodoList.CsvImporter.import("entries.csv") |> TodoList.delete_entry(%{date: {19, 12, 2013}, id: 3, title: "Movies"})
# my_todo = TodoList.CsvImporter.import("entries.csv") |> TodoList.delete_entry(3)

# async_query = fn(query_def) -> spawn(fn -> IO.puts(run_query.(query_def)) end); end

# run_query = fn(query_def) -> :timer.sleep(2000); "#{query_def} result" end

myList = myList = TodoServer.start()
TodoServer.add_entry(myList, %{date: {2017, 7, 2}, title: "Pet Marzi"})
TodoServer.entries