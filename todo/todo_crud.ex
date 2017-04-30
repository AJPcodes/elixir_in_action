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