defmodule PolylineTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Polyline

  @example [[-120.2, 38.5], [-120.95, 40.7], [-126.453, 43.252]]

  test "decode an empty List" do
    assert Polyline.decode("") == []
  end

  test "decode a single location" do
    assert Polyline.decode("_p~iF~ps|U") == [[-120.2, 38.5]]
  end

  test "decode a String into a List of lon/lat pairs" do
    assert Polyline.decode("_p~iF~ps|U_ulLnnqC_mqNvxq`@") == @example
  end

  test "decode a String into a List of lon/lat pairs with custom precision" do
    assert Polyline.decode("_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI", 6) == @example
  end

  test "discard leftover elements when decoding" do
    string =
      "i|~wAeo{aVw@i@SI]EkN^c@@KfXGNULcCo@}HgByEkAcFcAsCk@oAYeAYgZuGiBu@wCi@iGo@eKBiHx@aGzAeMpEgJ`Dy@wC~@kK|D_A`@yLlEkAXuJhDuAj@yAp@mKzD{h@bRu@NcIpCmIbDmGxBk@RkD`AgBj@wAf@a@mBe@sCiCiNkCcMgCkMeBZWE}@BmKsAkCWwE]{BGyC?iBD}BJwCVgDb@mByNu@wSGaC{DL"

    assert string |> Polyline.decode() |> Enum.count() == 64
  end
end
