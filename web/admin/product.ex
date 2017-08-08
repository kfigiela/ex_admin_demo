defmodule ExAdminDemo.ExAdmin.Product do
  use ExAdmin.Register
  require Logger
  import Ecto.Query
  alias ExAdminDemo.Order
  alias ExAdminDemo.LineItem
  alias ExAdminDemo.Product
  alias ExAdminDemo.Repo

  register_resource ExAdminDemo.Product do
    menu priority: 2
    scope :all, default: true
    scope :available, [], fn(q) ->
      now = Ecto.Date.utc
      where(q, [p], p.available_on <= ^now)
    end
    scope :drafts, fn(q) ->
      now = Ecto.Date.utc
      where(q, [p], p.available_on > ^now)
    end
    scope :featured_products, [], fn(q) ->
      where(q, [p], p.featured == true)
    end

    index as: :grid, default: true, columns: 1 do
      import Kernel, except: [div: 2]
      cell fn(p) ->
        div ".box" do
          div ".box-body" do
            a href: admin_resource_path(p, :show) do
              img(src: ExAdminDemo.Image.url({p.image_file_name, p}, :thumb), height: 100)
            end
          end
          div ".box-footer" do
            a p.title, href: admin_resource_path(p, :show)
          end
        end
      end
    end

    show _product do
      attributes_table do
        row :title
        row :title_fun, fun: fn prod -> "<script>document.write('XSSed')</script>" end
        row :title_safe_raw, fun: fn prod -> Phoenix.HTML.raw("<script>document.write('XSSed')</script>") end
        row :title_safe_escaped, fun: fn prod -> Phoenix.HTML.html_escape("<script>document.write('XSSed')</script>") end
        row :image_url, image: true, dupa: ~s|'><script>document.write('XSSed by attrs')</script><img dupa='|,
                                     fun: fn _prod -> "data:image/gif;base64,R0lGODlhyAAiALMAAFONvX2pzbPN4p6/2tTi7mibxYiw0d/q86nG3r7U5l2UwZO31unx98nb6nOiyf///yH5BAUUAA8ALAAAAADIACIAAAT/8MlJq7046827/2AojmRpnmiqriwGvG/Qjklg28es73wHxz0P4gcgBI9IHVGWzAx/xqZ0KlpSLU9Y9MrtVqzeBwFBJjPCaC44zW4HD4TzZI0h2OUjON7EsMd1fXcrfnsfgYUSeoYLPwoLZ3QTDAgORAoGWxQHNzYSBAY/BQ0XNZw5mgMBRACOpxSpnLE3qKqWC64hk5WNmBebnA8MjC8KFAygMAUCErA2CZoKq6wHkQ8C0dIxhQRED8OrC1hEmQ+12QADFebnABTr0ukh1+wB20QMu0ASCdn16wgTDmCTNlDfhG/sFODi9iMLvAoOi6hj92LZhHfZ3FEEYNEDwnMK/ykwhDEATAN2C/5d3PiDiYSIrALkg6EAz0hiFDNFJKeqgIEyM1nhwShNo0+glhBhgKlA5qqaE25KY1KAYkGAYlYVSEAgQdU1DFbFe3DgKwysWcHZ+QjAAIWdFQaMgkjk2b4ySLtNkCvuh90NYYmMLUsErVRiC8o8OLmkAYF5hZkRKYCHgVmDAiJJLeZpVUdrq/DA7XB5rAV+gkn/MJ0hc8sKm6OuclDoo8tgBQFgffd335p3cykEjSK1gIXLEl+Oq9OgTIKZtymg/hHuAoHmZJ6/5gDcwvDOyysEDS7B9VkJoSsEhuEyN6KSPyxKrf4qsnIoFQ4syL0qum8i9AW0H/9F/l3gngXwwSAfEQ5csIoFUmH1oAVrTEhXQ+Cdd6GGD4z230b+TQdDgB8S6INeG76AlVSsoYeibBg+cOAX2z1g4Vv2sYggER15uFliZFwWnUAAQmhLGUKe+MMFEa1oH40/FMKYht1RMKVB7+AiwTvEMehdeB2CicwLlAlXI1m5kSjBmACUOQF0HWRpAZcZqngBbxWwqZtkZz4QlEsJvkDiejDIcRh5h4kG5pPBrEHkDw06GKMEhAJwGxx+uBIoAIOmlxaH9TWCh4h2fgqDAWcc019AqwTHwDtu1UmMRQnkdpuHRU6gZ3uWOOaHILmuScc6LlFDhKuwwgiqsjQNgAD/UWgFZaKuq/w0AHIAuHIYReR5+A4C12HkEksSfRvuqiuxR4GebSFw7SraMqoRuXvK2t+Z+JDb22bsxDqBh+YRVCO5RgT81JnEGiNtNvvKKwl/IzJKql8ORadqQuSZis7CANCWYnIScOyAiJHayFIUIpM8r0GUstsrbA4HhC2nJi9LwDuihKkuhEQpgAAiEQpjyc99aWHMppz2gSLBlCL9iFQrW2pdz0TDPCkGCRgQjU9GVPpZQAkgIICWHfQhABkNkM1svQxg9wcJfWSn1AlxI5DA3COYjbbaLJBKzhQRuiF4Cn8nMiMXgQ+uOAkBFDDA2wxABkPJiMe8+OUaECVNLMZUJI755xtoHmwXnoNuugUQp4bGLzf0dvrriy2wsAMD4A377YJjSgDfD0QAADs="
                                                      <> ~s|'><script>document.write('XSSed by img')</script><img src='| end
        row :description
        row :author
        row :price
        row :featured, toggle: true
        row :available_on
        row "Cover", &(img(src: ExAdminDemo.Image.url({&1.image_file_name, &1}), height: 250))
      end
    end

    form product do
      inputs do
        input product, :title
        input product, :description
        input product, :author
        input product, :price
        input product, :featured
        input product, :available_on
        input product, :image_file_name, type: :file
      end
    end

    sidebar "Product Stats", only: :show do
      attributes_table_for resource do
        row "Total Sold", fn(r) ->
          Order.find_with_product(r)
          |> Repo.all
          |> Enum.count
          |> Integer.to_string
          |> text
        end
        row "Dollar Value", fn(r) ->
          id = r.id
          LineItem
          |> where([l], l.product_id == ^id)
          |> Repo.all
          |> Enum.reduce(Decimal.new(0.0), fn(li, sum) ->
            Decimal.add sum, li.price
          end)
          |> decimal_to_currency
          |> text
        end
      end
    end

    sidebar "ExAdmin Demo", only: [:index, :show] do
      Phoenix.View.render ExAdminDemo.AdminView, "sidebar_links.html", [model: "product"]
    end

  end
end
