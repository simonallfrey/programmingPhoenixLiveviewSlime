### Elixir quote and metaprogramming.
https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
- Ctrl-x Ctrl-q toggle read only
```elixir
iex> quote do: sum(1,2,3)
{:sum, [], [1, 2, 3]}
iex> #The first element is the function name, the second is a keyword list containing metadata and the third is the arguments list.
nil
iex> quote do: 1+2
{:+, [context: Elixir, imports: [{1, Kernel}, {2, Kernel}]], [1, 2]}
iex> quote do: %{:a => 2}
{:%{}, [], [a: 2]}
iex> quote do: %{a: 2}
{:%{}, [], [a: 2]}
iex> quote do: x
{:x, [], Elixir}
iex> # so for a variable the last element is an atom.
nil
iex> # When quoting more complex expressions, we can see that the code is represented in such tuples, which are often nested inside each other in a structure resembling a tree. Many languages would call such representations an Abstract Syntax Tree (AST). Elixir calls them quoted expressions:
nil
iex> quote do: sum(1, 2+3, 4)
{:sum, [], [1, {:+, [context: Elixir, imports: [{1, Kernel}, {2, Kernel}]], [2, 3]}, 4]}
iex> Sometimes when working with quoted expressions, it may be useful to get the textual code representation back. This can be done with
iex> Macro.to_string(quote do: sum(1, 2+3, 4))
"sum(1, 2 + 3, 4)"
iex> #Unquoting
nil
iex> # Quote is about retrieving the inner representation of some particular chunk of code. However, sometimes it may be necessary to inject some other particular chunk of code inside the representation we want to retrieve. 
nil
iex> number = 13
13
iex> Macro.to_string(quote do: 320 + number)
"320 + number"
iex> Macro.to_string(quote do: 320 + unquote(number))
"320 + 13"
iex> # so unquote inserts the value of the variable. 
nil
iex> # unquote must be used inside quote
nil
iex> # here's an example with a function name
nil
iex> fun = :hello
:hello
iex> Macro.to_string(quote do: unquote(fun)(:world)) 
"hello(:world)"
iex> # unquote won't work for a splice
nil
iex> l = [2,3,4]
[2, 3, 4]
iex> Macro.to_string(quote do: [1, unquote(l), 5])
"[1, [2, 3, 4], 5]"
iex> # but unquote_splicing will:
nil
iex> Macro.to_string(quote do: [1, unquote_splicing(l), 5])
"[1, 2, 3, 4, 5]"
```
 



