defmodule Format do


  def name(string) do
    string
      |> String.strip
      |> String.split(" ")
      |> Enum.map( &String.capitalize/1 )
      |> Enum.join(" ")
  end

  def email(string) do
    string
    |> String.strip
    |> String.downcase
    |> String.split(" ")
    |> Enum.join
  end

end
