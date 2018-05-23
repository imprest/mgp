defmodule DevMode do
  defmacro dev(a, b) do
    if Mix.env() == :dev do
      a
    else
      b
    end
  end
end

defmodule MgpWeb.Router do
  use MgpWeb, :router
  require DevMode

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:assign_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:assign_current_user)
  end

  pipeline :api_auth do
    plug(:ensure_authenticated)
  end

  scope "/api", MgpWeb do
    pipe_through(:api)
    resources("/sessions", SessionController, only: [:delete], singleton: true)
  end

  # Other scopes may use custom stacks.
  scope "/api", MgpWeb do
    pipe_through([:api, :api_auth])

    resources("/products", ProductController, except: [:new, :edit])
    resources("/customers", CustomerController, except: [:new, :edit])
    resources("/prices", PriceController, except: [:new, :edit])
    resources("/invoices", InvoiceController, except: [:new, :edit])
    resources("/invoice_details", InvoiceDetailController, except: [:new, :edit])
    resources("/op_balances", OpBalanceController, except: [:new, :edit])
    resources("/postings", PostingController, except: [:new, :edit])
    resources("/pdcs", PdcController, except: [:new, :edit])
    resources("/users", UserController, except: [:new, :edit])
  end

  scope "/", MgpWeb do
    # Use the default browser stack
    pipe_through(:browser)

    # get("/logout", SessionController, only: [:logout])
    resources("/login", SessionController, only: [:index, :create])
  end

  scope "/", MgpWeb do
    # Use the default browser stack
    pipe_through([:browser, :api_auth])
    get("/", PageController, :index)
    get("/favicon.ico", PageController, :index)
    get("/*path", PageController, DevMode.dev(:js, :index))
  end

  # Plug function
  defp assign_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Mgp.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  defp ensure_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must login first!!")
      |> redirect(to: MgpWeb.Router.Helpers.session_path(conn, :index))
      |> halt()
    end
  end
end
