defmodule Mgp.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo

  alias Mgp.Sales.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{source: %Product{}}

  """
  def change_product(%Product{} = product) do
    Product.changeset(product, %{})
  end

  alias Mgp.Sales.OpProductStock

  @doc """
  Returns the list of op_product_stocks.

  ## Examples

      iex> list_op_product_stocks()
      [%OpProductStock{}, ...]

  """
  def list_op_product_stocks do
    Repo.all(OpProductStock)
  end

  @doc """
  Gets a single op_product_stock.

  Raises `Ecto.NoResultsError` if the Op product stock does not exist.

  ## Examples

      iex> get_op_product_stock!(123)
      %OpProductStock{}

      iex> get_op_product_stock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_op_product_stock!(id), do: Repo.get!(OpProductStock, id)

  @doc """
  Creates a op_product_stock.

  ## Examples

      iex> create_op_product_stock(%{field: value})
      {:ok, %OpProductStock{}}

      iex> create_op_product_stock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_op_product_stock(attrs \\ %{}) do
    %OpProductStock{}
    |> OpProductStock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a op_product_stock.

  ## Examples

      iex> update_op_product_stock(op_product_stock, %{field: new_value})
      {:ok, %OpProductStock{}}

      iex> update_op_product_stock(op_product_stock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_op_product_stock(%OpProductStock{} = op_product_stock, attrs) do
    op_product_stock
    |> OpProductStock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OpProductStock.

  ## Examples

      iex> delete_op_product_stock(op_product_stock)
      {:ok, %OpProductStock{}}

      iex> delete_op_product_stock(op_product_stock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_op_product_stock(%OpProductStock{} = op_product_stock) do
    Repo.delete(op_product_stock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking op_product_stock changes.

  ## Examples

      iex> change_op_product_stock(op_product_stock)
      %Ecto.Changeset{source: %OpProductStock{}}

  """
  def change_op_product_stock(%OpProductStock{} = op_product_stock) do
    OpProductStock.changeset(op_product_stock, %{})
  end

  alias Mgp.Sales.Price

  @doc """
  Returns the list of prices.

  ## Examples

      iex> list_prices()
      [%Price{}, ...]

  """
  def list_prices do
    Repo.all(Price)
  end

  @doc """
  Gets a single price.

  Raises `Ecto.NoResultsError` if the Price does not exist.

  ## Examples

      iex> get_price!(123)
      %Price{}

      iex> get_price!(456)
      ** (Ecto.NoResultsError)

  """
  def get_price!(id), do: Repo.get!(Price, id)

  @doc """
  Creates a price.

  ## Examples

      iex> create_price(%{field: value})
      {:ok, %Price{}}

      iex> create_price(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_price(attrs \\ %{}) do
    %Price{}
    |> Price.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a price.

  ## Examples

      iex> update_price(price, %{field: new_value})
      {:ok, %Price{}}

      iex> update_price(price, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_price(%Price{} = price, attrs) do
    price
    |> Price.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Price.

  ## Examples

      iex> delete_price(price)
      {:ok, %Price{}}

      iex> delete_price(price)
      {:error, %Ecto.Changeset{}}

  """
  def delete_price(%Price{} = price) do
    Repo.delete(price)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking price changes.

  ## Examples

      iex> change_price(price)
      %Ecto.Changeset{source: %Price{}}

  """
  def change_price(%Price{} = price) do
    Price.changeset(price, %{})
  end

  alias Mgp.Sales.Customer

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{source: %Customer{}}

  """
  def change_customer(%Customer{} = customer) do
    Customer.changeset(customer, %{})
  end
end
