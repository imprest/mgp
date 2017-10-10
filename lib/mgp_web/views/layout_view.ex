defmodule MgpWeb.LayoutView do
  use MgpWeb, :view

  def js_script_tag do
    if Mix.env == :prod do
      "<script scr=\"/js/app/js\"></script>"
    else
      "<script src=\"http://localhost:8080/js/app.js\"></script>"
    end
  end

  def css_link_tag do
    if Mix.env == :prod do
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/app.css\" />"
    else
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://localhost:8080/css/app.css\" />"
    end
  end

end
