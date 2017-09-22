defmodule Mgp.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo

  alias Mgp.Sales.Product
  alias Mgp.Sales.Price
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.OpProductStock
  alias Mgp.Sales.Customer
  alias Mgp.Sales.InvoiceDetail

  def suggest_invoice_ids(query) do
    q = from Invoice,
      where: fragment("similarity(id, ?) > 0.2", ^query),
      limit: 12,
      select: [:id, :customer_id, :date]
    Repo.all(q)
  end

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
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([prices: (from p in Price, order_by: p.date)])
  end

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

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{source: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice) do
    Invoice.changeset(invoice, %{})
  end

  @doc """
  Returns the list of invoice_details.

  ## Examples

      iex> list_invoice_details()
      [%InvoiceDetail{}, ...]

  """
  def list_invoice_details do
    Repo.all(InvoiceDetail)
  end

  @doc """
  Gets a single invoice_detail.

  Raises `Ecto.NoResultsError` if the Invoice detail does not exist.

  ## Examples

      iex> get_invoice_detail!(123)
      %InvoiceDetail{}

      iex> get_invoice_detail!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice_detail!(id), do: Repo.get!(InvoiceDetail, id)

  @doc """
  Creates a invoice_detail.

  ## Examples

      iex> create_invoice_detail(%{field: value})
      {:ok, %InvoiceDetail{}}

      iex> create_invoice_detail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice_detail(attrs \\ %{}) do
    %InvoiceDetail{}
    |> InvoiceDetail.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice_detail.

  ## Examples

      iex> update_invoice_detail(invoice_detail, %{field: new_value})
      {:ok, %InvoiceDetail{}}

      iex> update_invoice_detail(invoice_detail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice_detail(%InvoiceDetail{} = invoice_detail, attrs) do
    invoice_detail
    |> InvoiceDetail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a InvoiceDetail.

  ## Examples

      iex> delete_invoice_detail(invoice_detail)
      {:ok, %InvoiceDetail{}}

      iex> delete_invoice_detail(invoice_detail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice_detail(%InvoiceDetail{} = invoice_detail) do
    Repo.delete(invoice_detail)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice_detail changes.

  ## Examples

      iex> change_invoice_detail(invoice_detail)
      %Ecto.Changeset{source: %InvoiceDetail{}}

  """
  def change_invoice_detail(%InvoiceDetail{} = invoice_detail) do
    InvoiceDetail.changeset(invoice_detail, %{})
  end
end
