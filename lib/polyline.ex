defmodule Polyline do
  @moduledoc ~S"""
  Encode and decode Polylines to and from List of `{lon, lat}` tuples.

  The encode functions accept a `precision` parameter that defines the
  number of significant digits to retain when encoding.  The same precision
  must be supplied to the decode or the resulting linestring will be incorrect.
  The default is `5`, which correlates to approximately 1 meter of precision.

  ## Examples
      iex> Polyline.decode("_p~iF~ps|U_ulLnnqC_mqNvxq`@")
      [[-120.2, 38.5], [-120.95, 40.7], [-126.453, 43.252]]
  """

  import Bitwise

  @default_precision 5

  @doc ~S"""
  Decode a polyline String into a List of `[lon, lat]` lists.

  ## Examples
      iex> Polyline.decode("_p~iF~ps|U_ulLnnqC_mqNvxq`@")
      [[-120.2, 38.5], [-120.95, 40.7], [-126.453, 43.252]]

      iex> Polyline.decode("_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI", 6)
      [[-120.2, 38.5], [-120.95, 40.7], [-126.453, 43.252]]
  """
  def decode(str, precision \\ @default_precision)
  def decode(str, _) when str == "", do: []

  def decode(str, precision) do
    factor = :math.pow(10, precision)

    str
    |> String.to_charlist()
    |> decode_list([{0, 0}], nil)
    |> Enum.reduce([], fn {x, y}, acc -> [[x / factor, y / factor] | acc] end)
    |> tl()
  end

  defp decode_list(remain, values, y)
  defp decode_list(~c"", values, _y), do: values

  defp decode_list(remain, values, nil) do
    {next_one, remain} = decode_next(remain, 0)
    y = sign(next_one)
    decode_list(remain, values, y)
  end

  defp decode_list(remain, values, y) do
    {next_one, remain} = decode_next(remain, 0)
    x = sign(next_one)
    {px, py} = hd(values)
    decode_list(remain, [{x + px, y + py} | values], nil)
  end

  defp decode_next([head | []], shift), do: {decode_char(head, shift), ~c""}
  defp decode_next([head | tail], shift) when head < 95, do: {decode_char(head, shift), tail}

  defp decode_next([head | tail], shift) do
    {next, remain} = decode_next(tail, shift + 5)
    {decode_char(head, shift) ||| next, remain}
  end

  defp decode_char(char, shift), do: (char - 63 &&& 0x1F) <<< shift

  defp sign(result) when (result &&& 1) === 1, do: -((result >>> 1) + 1)
  defp sign(result), do: result >>> 1
end
