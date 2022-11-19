defmodule FeriendatenWeb.Admin.AddressController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Schools
  alias Feriendaten.Schools.Address

  def index(conn, _params) do
    addresses = Schools.list_addresses()
    render(conn, :index, addresses: addresses)
  end

  def new(conn, _params) do
    changeset = Schools.change_address(%Address{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"address" => address_params}) do
    case Schools.create_address(address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address created successfully.")
        |> redirect(to: ~p"/admin/addresses/#{address}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    address = Schools.get_address!(id)
    render(conn, :show, address: address)
  end

  def edit(conn, %{"id" => id}) do
    address = Schools.get_address!(id)
    changeset = Schools.change_address(address)
    render(conn, :edit, address: address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    address = Schools.get_address!(id)

    case Schools.update_address(address, address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address updated successfully.")
        |> redirect(to: ~p"/admin/addresses/#{address}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, address: address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Schools.get_address!(id)
    {:ok, _address} = Schools.delete_address(address)

    conn
    |> put_flash(:info, "Address deleted successfully.")
    |> redirect(to: ~p"/admin/addresses")
  end
end
