#does not work
defmodule TestDefp do
  defmacro __using__(_) do
    quote do
      import Kernel, except: [defp: 2]
    end
  end

  # Let's redefine `defp/2` so that if MIX_ENV is `test`, the function will be
  # defined with `def/2` instead of `defp/2`.
  defmacro defp(fun, body) do
    def_macro = if function_exported?(Mix, :env, 0) && apply(Mix, :env, [:test]), do: :def, else: :defp
    quote do
      Kernel.unquote(def_macro)(unquote(fun), unquote(body))
    end

  end
end

