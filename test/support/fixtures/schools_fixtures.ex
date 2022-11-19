defmodule Feriendaten.SchoolsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feriendaten.Schools` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    {:ok, address} =
      attrs
      |> Enum.into(%{
        city: "some city",
        email: "some email",
        fax: "some fax",
        lat: 120.5,
        legacy_id: 42,
        line1: "some line1",
        lon: 120.5,
        phone: "some phone",
        school_type: "some school_type",
        street: "some street",
        url: "some url",
        zip_code: "some zip_code"
      })
      |> Feriendaten.Schools.create_address()

    address
  end
end
