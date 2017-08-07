defmodule Mgp.SalesTest do
  use Mgp.DataCase

  alias Mgp.Sales

  describe "products" do
    alias Mgp.Sales.Product

    @valid_attrs %{cash_price: "120.5", credit_price: "120.5", description: "some description", group: "some group", tax_tat: "some tax_tat", tax_type: "some tax_type", trek_price: "120.5"}
    @update_attrs %{cash_price: "456.7", credit_price: "456.7", description: "some updated description", group: "some updated group", tax_tat: "some updated tax_tat", tax_type: "some updated tax_type", trek_price: "456.7"}
    @invalid_attrs %{cash_price: nil, credit_price: nil, description: nil, group: nil, tax_tat: nil, tax_type: nil, trek_price: nil}

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Sales.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Sales.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Sales.create_product(@valid_attrs)
      assert product.cash_price == Decimal.new("120.5")
      assert product.credit_price == Decimal.new("120.5")
      assert product.description == "some description"
      assert product.group == "some group"
      assert product.tax_tat == "some tax_tat"
      assert product.tax_type == "some tax_type"
      assert product.trek_price == Decimal.new("120.5")
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, product} = Sales.update_product(product, @update_attrs)
      assert %Product{} = product
      assert product.cash_price == Decimal.new("456.7")
      assert product.credit_price == Decimal.new("456.7")
      assert product.description == "some updated description"
      assert product.group == "some updated group"
      assert product.tax_tat == "some updated tax_tat"
      assert product.tax_type == "some updated tax_type"
      assert product.trek_price == Decimal.new("456.7")
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_product(product, @invalid_attrs)
      assert product == Sales.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Sales.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Sales.change_product(product)
    end
  end

  describe "op_product_stocks" do
    alias Mgp.Sales.OpProductStock

    @valid_attrs %{date: ~D[2010-04-17], location: "some location", qty: 42}
    @update_attrs %{date: ~D[2011-05-18], location: "some updated location", qty: 43}
    @invalid_attrs %{date: nil, location: nil, qty: nil}

    def op_product_stock_fixture(attrs \\ %{}) do
      {:ok, op_product_stock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_op_product_stock()

      op_product_stock
    end

    test "list_op_product_stocks/0 returns all op_product_stocks" do
      op_product_stock = op_product_stock_fixture()
      assert Sales.list_op_product_stocks() == [op_product_stock]
    end

    test "get_op_product_stock!/1 returns the op_product_stock with given id" do
      op_product_stock = op_product_stock_fixture()
      assert Sales.get_op_product_stock!(op_product_stock.id) == op_product_stock
    end

    test "create_op_product_stock/1 with valid data creates a op_product_stock" do
      assert {:ok, %OpProductStock{} = op_product_stock} = Sales.create_op_product_stock(@valid_attrs)
      assert op_product_stock.date == ~D[2010-04-17]
      assert op_product_stock.location == "some location"
      assert op_product_stock.qty == 42
    end

    test "create_op_product_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_op_product_stock(@invalid_attrs)
    end

    test "update_op_product_stock/2 with valid data updates the op_product_stock" do
      op_product_stock = op_product_stock_fixture()
      assert {:ok, op_product_stock} = Sales.update_op_product_stock(op_product_stock, @update_attrs)
      assert %OpProductStock{} = op_product_stock
      assert op_product_stock.date == ~D[2011-05-18]
      assert op_product_stock.location == "some updated location"
      assert op_product_stock.qty == 43
    end

    test "update_op_product_stock/2 with invalid data returns error changeset" do
      op_product_stock = op_product_stock_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_op_product_stock(op_product_stock, @invalid_attrs)
      assert op_product_stock == Sales.get_op_product_stock!(op_product_stock.id)
    end

    test "delete_op_product_stock/1 deletes the op_product_stock" do
      op_product_stock = op_product_stock_fixture()
      assert {:ok, %OpProductStock{}} = Sales.delete_op_product_stock(op_product_stock)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_op_product_stock!(op_product_stock.id) end
    end

    test "change_op_product_stock/1 returns a op_product_stock changeset" do
      op_product_stock = op_product_stock_fixture()
      assert %Ecto.Changeset{} = Sales.change_op_product_stock(op_product_stock)
    end
  end

  describe "prices" do
    alias Mgp.Sales.Price

    @valid_attrs %{cash: "120.5", credit: "120.5", date: ~D[2010-04-17], lmd: ~D[2010-04-17], lmt: ~N[2010-04-17 14:00:00.000000], lmu: "some lmu", trek: "120.5"}
    @update_attrs %{cash: "456.7", credit: "456.7", date: ~D[2011-05-18], lmd: ~D[2011-05-18], lmt: ~N[2011-05-18 15:01:01.000000], lmu: "some updated lmu", trek: "456.7"}
    @invalid_attrs %{cash: nil, credit: nil, date: nil, lmd: nil, lmt: nil, lmu: nil, trek: nil}

    def price_fixture(attrs \\ %{}) do
      {:ok, price} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_price()

      price
    end

    test "list_prices/0 returns all prices" do
      price = price_fixture()
      assert Sales.list_prices() == [price]
    end

    test "get_price!/1 returns the price with given id" do
      price = price_fixture()
      assert Sales.get_price!(price.id) == price
    end

    test "create_price/1 with valid data creates a price" do
      assert {:ok, %Price{} = price} = Sales.create_price(@valid_attrs)
      assert price.cash == Decimal.new("120.5")
      assert price.credit == Decimal.new("120.5")
      assert price.date == ~D[2010-04-17]
      assert price.lmd == ~D[2010-04-17]
      assert price.lmt == ~N[2010-04-17 14:00:00.000000]
      assert price.lmu == "some lmu"
      assert price.trek == Decimal.new("120.5")
    end

    test "create_price/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_price(@invalid_attrs)
    end

    test "update_price/2 with valid data updates the price" do
      price = price_fixture()
      assert {:ok, price} = Sales.update_price(price, @update_attrs)
      assert %Price{} = price
      assert price.cash == Decimal.new("456.7")
      assert price.credit == Decimal.new("456.7")
      assert price.date == ~D[2011-05-18]
      assert price.lmd == ~D[2011-05-18]
      assert price.lmt == ~N[2011-05-18 15:01:01.000000]
      assert price.lmu == "some updated lmu"
      assert price.trek == Decimal.new("456.7")
    end

    test "update_price/2 with invalid data returns error changeset" do
      price = price_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_price(price, @invalid_attrs)
      assert price == Sales.get_price!(price.id)
    end

    test "delete_price/1 deletes the price" do
      price = price_fixture()
      assert {:ok, %Price{}} = Sales.delete_price(price)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_price!(price.id) end
    end

    test "change_price/1 returns a price changeset" do
      price = price_fixture()
      assert %Ecto.Changeset{} = Sales.change_price(price)
    end
  end

  describe "customers" do
    alias Mgp.Sales.Customer

    @valid_attrs %{add1: "some add1", add2: "some add2", add3: "some add3", attn: "some attn", description: "some description", email: "some email", is_gov: "some is_gov", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", phone: "some phone", region: "some region", resp: "some resp"}
    @update_attrs %{add1: "some updated add1", add2: "some updated add2", add3: "some updated add3", attn: "some updated attn", description: "some updated description", email: "some updated email", is_gov: "some updated is_gov", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", phone: "some updated phone", region: "some updated region", resp: "some updated resp"}
    @invalid_attrs %{add1: nil, add2: nil, add3: nil, attn: nil, description: nil, email: nil, is_gov: nil, lmd: nil, lmt: nil, lmu: nil, phone: nil, region: nil, resp: nil}

    def customer_fixture(attrs \\ %{}) do
      {:ok, customer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_customer()

      customer
    end

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Sales.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Sales.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      assert {:ok, %Customer{} = customer} = Sales.create_customer(@valid_attrs)
      assert customer.add1 == "some add1"
      assert customer.add2 == "some add2"
      assert customer.add3 == "some add3"
      assert customer.attn == "some attn"
      assert customer.description == "some description"
      assert customer.email == "some email"
      assert customer.is_gov == "some is_gov"
      assert customer.lmd == ~D[2010-04-17]
      assert customer.lmt == ~T[14:00:00.000000]
      assert customer.lmu == "some lmu"
      assert customer.phone == "some phone"
      assert customer.region == "some region"
      assert customer.resp == "some resp"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, customer} = Sales.update_customer(customer, @update_attrs)
      assert %Customer{} = customer
      assert customer.add1 == "some updated add1"
      assert customer.add2 == "some updated add2"
      assert customer.add3 == "some updated add3"
      assert customer.attn == "some updated attn"
      assert customer.description == "some updated description"
      assert customer.email == "some updated email"
      assert customer.is_gov == "some updated is_gov"
      assert customer.lmd == ~D[2011-05-18]
      assert customer.lmt == ~T[15:01:01.000000]
      assert customer.lmu == "some updated lmu"
      assert customer.phone == "some updated phone"
      assert customer.region == "some updated region"
      assert customer.resp == "some updated resp"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_customer(customer, @invalid_attrs)
      assert customer == Sales.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Sales.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Sales.change_customer(customer)
    end
  end
end
