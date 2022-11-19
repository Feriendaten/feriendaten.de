defmodule Feriendaten.SchoolsTest do
  use Feriendaten.DataCase

  alias Feriendaten.Schools

  describe "addresses" do
    alias Feriendaten.Schools.Address

    import Feriendaten.SchoolsFixtures

    @invalid_attrs %{
      city: nil,
      email: nil,
      fax: nil,
      lat: nil,
      legacy_id: nil,
      line1: nil,
      lon: nil,
      phone: nil,
      school_type: nil,
      street: nil,
      url: nil,
      zip_code: nil
    }

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Schools.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Schools.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      valid_attrs = %{
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
      }

      assert {:ok, %Address{} = address} = Schools.create_address(valid_attrs)
      assert address.city == "some city"
      assert address.email == "some email"
      assert address.fax == "some fax"
      assert address.lat == 120.5
      assert address.legacy_id == 42
      assert address.line1 == "some line1"
      assert address.lon == 120.5
      assert address.phone == "some phone"
      assert address.school_type == "some school_type"
      assert address.street == "some street"
      assert address.url == "some url"
      assert address.zip_code == "some zip_code"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schools.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()

      update_attrs = %{
        city: "some updated city",
        email: "some updated email",
        fax: "some updated fax",
        lat: 456.7,
        legacy_id: 43,
        line1: "some updated line1",
        lon: 456.7,
        phone: "some updated phone",
        school_type: "some updated school_type",
        street: "some updated street",
        url: "some updated url",
        zip_code: "some updated zip_code"
      }

      assert {:ok, %Address{} = address} = Schools.update_address(address, update_attrs)
      assert address.city == "some updated city"
      assert address.email == "some updated email"
      assert address.fax == "some updated fax"
      assert address.lat == 456.7
      assert address.legacy_id == 43
      assert address.line1 == "some updated line1"
      assert address.lon == 456.7
      assert address.phone == "some updated phone"
      assert address.school_type == "some updated school_type"
      assert address.street == "some updated street"
      assert address.url == "some updated url"
      assert address.zip_code == "some updated zip_code"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Schools.update_address(address, @invalid_attrs)
      assert address == Schools.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Schools.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Schools.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Schools.change_address(address)
    end
  end
end
