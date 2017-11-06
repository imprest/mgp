defmodule MgpWeb.Router do
  use MgpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", MgpWeb do
    pipe_through :api

    resources "/products", ProductController, except: [:new, :edit]
    resources "/customers", CustomerController, except: [:new, :edit]
    resources "/op_product_stocks", OpProductStockController,
      except: [:new, :edit]
    resources "/prices", PriceController, except: [:new, :edit]
    resources "/invoices", InvoiceController, except: [:new, :edit]
    resources "/invoice_details", InvoiceDetailController, except: [:new, :edit]
    resources "/op_balances", OpBalanceController, except: [:new, :edit]
    resources "/postings", PostingController, except: [:new, :edit]
    resources "/pdcs", PdcController, except: [:new, :edit]
  end

  scope "/", MgpWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end

end
