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

  describe "invoices" do
    alias Mgp.Sales.Invoice

    @valid_attrs %{date: ~D[2010-04-17], detail1: "some detail1", detail2: "some detail2", detail3: "some detail3", from_stock: "some from_stock", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", payment_term: "some payment_term", price_level: "some price_level", value: "120.5"}
    @update_attrs %{date: ~D[2011-05-18], detail1: "some updated detail1", detail2: "some updated detail2", detail3: "some updated detail3", from_stock: "some updated from_stock", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", payment_term: "some updated payment_term", price_level: "some updated price_level", value: "456.7"}
    @invalid_attrs %{date: nil, detail1: nil, detail2: nil, detail3: nil, from_stock: nil, lmd: nil, lmt: nil, lmu: nil, payment_term: nil, price_level: nil, value: nil}

    def invoice_fixture(attrs \\ %{}) do
      {:ok, invoice} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_invoice()

      invoice
    end

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Sales.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Sales.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      assert {:ok, %Invoice{} = invoice} = Sales.create_invoice(@valid_attrs)
      assert invoice.date == ~D[2010-04-17]
      assert invoice.detail1 == "some detail1"
      assert invoice.detail2 == "some detail2"
      assert invoice.detail3 == "some detail3"
      assert invoice.from_stock == "some from_stock"
      assert invoice.lmd == ~D[2010-04-17]
      assert invoice.lmt == ~T[14:00:00.000000]
      assert invoice.lmu == "some lmu"
      assert invoice.payment_term == "some payment_term"
      assert invoice.price_level == "some price_level"
      assert invoice.value == Decimal.new("120.5")
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      assert {:ok, invoice} = Sales.update_invoice(invoice, @update_attrs)
      assert %Invoice{} = invoice
      assert invoice.date == ~D[2011-05-18]
      assert invoice.detail1 == "some updated detail1"
      assert invoice.detail2 == "some updated detail2"
      assert invoice.detail3 == "some updated detail3"
      assert invoice.from_stock == "some updated from_stock"
      assert invoice.lmd == ~D[2011-05-18]
      assert invoice.lmt == ~T[15:01:01.000000]
      assert invoice.lmu == "some updated lmu"
      assert invoice.payment_term == "some updated payment_term"
      assert invoice.price_level == "some updated price_level"
      assert invoice.value == Decimal.new("456.7")
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_invoice(invoice, @invalid_attrs)
      assert invoice == Sales.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Sales.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Sales.change_invoice(invoice)
    end
  end

  describe "invoice_details" do
    alias Mgp.Sales.InvoiceDetail

    @valid_attrs %{description: "some description", from_stock: "some from_stock", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", qty: 42, rate: "120.5", sr_no: 42, sub_qty: 42, tax_rate: "some tax_rate", total: "120.5"}
    @update_attrs %{description: "some updated description", from_stock: "some updated from_stock", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", qty: 43, rate: "456.7", sr_no: 43, sub_qty: 43, tax_rate: "some updated tax_rate", total: "456.7"}
    @invalid_attrs %{description: nil, from_stock: nil, lmd: nil, lmt: nil, lmu: nil, qty: nil, rate: nil, sr_no: nil, sub_qty: nil, tax_rate: nil, total: nil}

    def invoice_detail_fixture(attrs \\ %{}) do
      {:ok, invoice_detail} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_invoice_detail()

      invoice_detail
    end

    test "list_invoice_details/0 returns all invoice_details" do
      invoice_detail = invoice_detail_fixture()
      assert Sales.list_invoice_details() == [invoice_detail]
    end

    test "get_invoice_detail!/1 returns the invoice_detail with given id" do
      invoice_detail = invoice_detail_fixture()
      assert Sales.get_invoice_detail!(invoice_detail.id) == invoice_detail
    end

    test "create_invoice_detail/1 with valid data creates a invoice_detail" do
      assert {:ok, %InvoiceDetail{} = invoice_detail} = Sales.create_invoice_detail(@valid_attrs)
      assert invoice_detail.description == "some description"
      assert invoice_detail.from_stock == "some from_stock"
      assert invoice_detail.lmd == ~D[2010-04-17]
      assert invoice_detail.lmt == ~T[14:00:00.000000]
      assert invoice_detail.lmu == "some lmu"
      assert invoice_detail.qty == 42
      assert invoice_detail.rate == Decimal.new("120.5")
      assert invoice_detail.sr_no == 42
      assert invoice_detail.sub_qty == 42
      assert invoice_detail.tax_rate == "some tax_rate"
      assert invoice_detail.total == Decimal.new("120.5")
    end

    test "create_invoice_detail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_invoice_detail(@invalid_attrs)
    end

    test "update_invoice_detail/2 with valid data updates the invoice_detail" do
      invoice_detail = invoice_detail_fixture()
      assert {:ok, invoice_detail} = Sales.update_invoice_detail(invoice_detail, @update_attrs)
      assert %InvoiceDetail{} = invoice_detail
      assert invoice_detail.description == "some updated description"
      assert invoice_detail.from_stock == "some updated from_stock"
      assert invoice_detail.lmd == ~D[2011-05-18]
      assert invoice_detail.lmt == ~T[15:01:01.000000]
      assert invoice_detail.lmu == "some updated lmu"
      assert invoice_detail.qty == 43
      assert invoice_detail.rate == Decimal.new("456.7")
      assert invoice_detail.sr_no == 43
      assert invoice_detail.sub_qty == 43
      assert invoice_detail.tax_rate == "some updated tax_rate"
      assert invoice_detail.total == Decimal.new("456.7")
    end

    test "update_invoice_detail/2 with invalid data returns error changeset" do
      invoice_detail = invoice_detail_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_invoice_detail(invoice_detail, @invalid_attrs)
      assert invoice_detail == Sales.get_invoice_detail!(invoice_detail.id)
    end

    test "delete_invoice_detail/1 deletes the invoice_detail" do
      invoice_detail = invoice_detail_fixture()
      assert {:ok, %InvoiceDetail{}} = Sales.delete_invoice_detail(invoice_detail)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_invoice_detail!(invoice_detail.id) end
    end

    test "change_invoice_detail/1 returns a invoice_detail changeset" do
      invoice_detail = invoice_detail_fixture()
      assert %Ecto.Changeset{} = Sales.change_invoice_detail(invoice_detail)
    end
  end

  describe "stock_transfers" do
    alias Mgp.Sales.StockTransfer

    @valid_attrs %{date: ~D[2010-04-17], doc_id: "some doc_id", from_stock: "some from_stock", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", qty: 42, to_stock: "some to_stock"}
    @update_attrs %{date: ~D[2011-05-18], doc_id: "some updated doc_id", from_stock: "some updated from_stock", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", qty: 43, to_stock: "some updated to_stock"}
    @invalid_attrs %{date: nil, doc_id: nil, from_stock: nil, lmd: nil, lmt: nil, lmu: nil, qty: nil, to_stock: nil}

    def stock_transfer_fixture(attrs \\ %{}) do
      {:ok, stock_transfer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_stock_transfer()

      stock_transfer
    end

    test "list_stock_transfers/0 returns all stock_transfers" do
      stock_transfer = stock_transfer_fixture()
      assert Sales.list_stock_transfers() == [stock_transfer]
    end

    test "get_stock_transfer!/1 returns the stock_transfer with given id" do
      stock_transfer = stock_transfer_fixture()
      assert Sales.get_stock_transfer!(stock_transfer.id) == stock_transfer
    end

    test "create_stock_transfer/1 with valid data creates a stock_transfer" do
      assert {:ok, %StockTransfer{} = stock_transfer} = Sales.create_stock_transfer(@valid_attrs)
      assert stock_transfer.date == ~D[2010-04-17]
      assert stock_transfer.doc_id == "some doc_id"
      assert stock_transfer.from_stock == "some from_stock"
      assert stock_transfer.lmd == ~D[2010-04-17]
      assert stock_transfer.lmt == ~T[14:00:00.000000]
      assert stock_transfer.lmu == "some lmu"
      assert stock_transfer.qty == 42
      assert stock_transfer.to_stock == "some to_stock"
    end

    test "create_stock_transfer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_stock_transfer(@invalid_attrs)
    end

    test "update_stock_transfer/2 with valid data updates the stock_transfer" do
      stock_transfer = stock_transfer_fixture()
      assert {:ok, stock_transfer} = Sales.update_stock_transfer(stock_transfer, @update_attrs)
      assert %StockTransfer{} = stock_transfer
      assert stock_transfer.date == ~D[2011-05-18]
      assert stock_transfer.doc_id == "some updated doc_id"
      assert stock_transfer.from_stock == "some updated from_stock"
      assert stock_transfer.lmd == ~D[2011-05-18]
      assert stock_transfer.lmt == ~T[15:01:01.000000]
      assert stock_transfer.lmu == "some updated lmu"
      assert stock_transfer.qty == 43
      assert stock_transfer.to_stock == "some updated to_stock"
    end

    test "update_stock_transfer/2 with invalid data returns error changeset" do
      stock_transfer = stock_transfer_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_stock_transfer(stock_transfer, @invalid_attrs)
      assert stock_transfer == Sales.get_stock_transfer!(stock_transfer.id)
    end

    test "delete_stock_transfer/1 deletes the stock_transfer" do
      stock_transfer = stock_transfer_fixture()
      assert {:ok, %StockTransfer{}} = Sales.delete_stock_transfer(stock_transfer)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_stock_transfer!(stock_transfer.id) end
    end

    test "change_stock_transfer/1 returns a stock_transfer changeset" do
      stock_transfer = stock_transfer_fixture()
      assert %Ecto.Changeset{} = Sales.change_stock_transfer(stock_transfer)
    end
  end

  describe "stock_receipts" do
    alias Mgp.Sales.StockReceipt

    @valid_attrs %{batch: "some batch", date: ~D[2010-04-17], doc_id: "some doc_id", expiry: ~D[2010-04-17], lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", qty: 42, sr_no: 42}
    @update_attrs %{batch: "some updated batch", date: ~D[2011-05-18], doc_id: "some updated doc_id", expiry: ~D[2011-05-18], lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", qty: 43, sr_no: 43}
    @invalid_attrs %{batch: nil, date: nil, doc_id: nil, expiry: nil, lmd: nil, lmt: nil, lmu: nil, qty: nil, sr_no: nil}

    def stock_receipt_fixture(attrs \\ %{}) do
      {:ok, stock_receipt} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sales.create_stock_receipt()

      stock_receipt
    end

    test "list_stock_receipts/0 returns all stock_receipts" do
      stock_receipt = stock_receipt_fixture()
      assert Sales.list_stock_receipts() == [stock_receipt]
    end

    test "get_stock_receipt!/1 returns the stock_receipt with given id" do
      stock_receipt = stock_receipt_fixture()
      assert Sales.get_stock_receipt!(stock_receipt.id) == stock_receipt
    end

    test "create_stock_receipt/1 with valid data creates a stock_receipt" do
      assert {:ok, %StockReceipt{} = stock_receipt} = Sales.create_stock_receipt(@valid_attrs)
      assert stock_receipt.batch == "some batch"
      assert stock_receipt.date == ~D[2010-04-17]
      assert stock_receipt.doc_id == "some doc_id"
      assert stock_receipt.expiry == ~D[2010-04-17]
      assert stock_receipt.lmd == ~D[2010-04-17]
      assert stock_receipt.lmt == ~T[14:00:00.000000]
      assert stock_receipt.lmu == "some lmu"
      assert stock_receipt.qty == 42
      assert stock_receipt.sr_no == 42
    end

    test "create_stock_receipt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_stock_receipt(@invalid_attrs)
    end

    test "update_stock_receipt/2 with valid data updates the stock_receipt" do
      stock_receipt = stock_receipt_fixture()
      assert {:ok, stock_receipt} = Sales.update_stock_receipt(stock_receipt, @update_attrs)
      assert %StockReceipt{} = stock_receipt
      assert stock_receipt.batch == "some updated batch"
      assert stock_receipt.date == ~D[2011-05-18]
      assert stock_receipt.doc_id == "some updated doc_id"
      assert stock_receipt.expiry == ~D[2011-05-18]
      assert stock_receipt.lmd == ~D[2011-05-18]
      assert stock_receipt.lmt == ~T[15:01:01.000000]
      assert stock_receipt.lmu == "some updated lmu"
      assert stock_receipt.qty == 43
      assert stock_receipt.sr_no == 43
    end

    test "update_stock_receipt/2 with invalid data returns error changeset" do
      stock_receipt = stock_receipt_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_stock_receipt(stock_receipt, @invalid_attrs)
      assert stock_receipt == Sales.get_stock_receipt!(stock_receipt.id)
    end

    test "delete_stock_receipt/1 deletes the stock_receipt" do
      stock_receipt = stock_receipt_fixture()
      assert {:ok, %StockReceipt{}} = Sales.delete_stock_receipt(stock_receipt)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_stock_receipt!(stock_receipt.id) end
    end

    test "change_stock_receipt/1 returns a stock_receipt changeset" do
      stock_receipt = stock_receipt_fixture()
      assert %Ecto.Changeset{} = Sales.change_stock_receipt(stock_receipt)
    end
  end
end
