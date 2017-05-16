defmodule Mix.Tasks.Phx.Gen.Elm do
  use Mix.Task
  import Mix.Generator

  def run(argv) do
    copy_phoenix_files(argv)
    copy_elm_files()
    install_node_modules()
    post_install_instructions(argv)
  end

  def post_install_instructions(argv) do
    app_name = argv |> parse_app_name()
    instructions = """

    🎉 ✨  Your elm app is almost ready to go! ✨ 🎉

    1. add the following to the 'plugins' section of your brunch-config.js


        elmBrunch: {
          mainModules: ['./elm/Main.elm'],
          outputFile: 'elm.js',
          makeParameters: ['--debug'] // activates time travel debugger
        }

    2. add 'elm' to the 'watched' array in your brunch-config.js


    3. in your 'layout' template ('/lib/#{app_name}/web/templates/layout/app.html.eex')
    add the following to embed the elm-runtime (above 'app.js')


        <script src="<%= static_path(@conn, "/js/elm.js") %>"></script>


    4. in your app.js file add the following


        import elmEmbed from './elm-embed.js'

        elmEmbed.init()


    5. and finally in your 'router.ex' file add


        get "/", ElmController, :index


    """

    Mix.shell.info(instructions)
  end

  def parse_app_name([]), do: raise "Please enter your app name as an atom, eg: mix phx.gen.elm :your_app"
  def parse_app_name([argv]) do
    if String.starts_with?(argv, ":") do
      {_, app_name} = String.split_at(argv, 1)
      app_name
    else
      raise "Invalid app name, please enter your app name as an atom"
    end
  end

  def app_module_name(argv) do
    argv
    |> parse_app_name()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

  def copy_phoenix_files(argv) do
    app_name = argv |> parse_app_name()

    src = "./priv/templates/phx.gen.elm"
    destination = "./lib/#{app_name}/web"

    static_files = [
      "templates/elm/index.html.eex"
    ]

    templates = [
      "views/elm_view.ex",
      "controllers/elm_controller.ex",
    ]

    Mix.shell.info("adding phoenix files 🕊 🔥")
    copy_files(static_files, src, destination)
    copy_templates(templates, src, destination, argv)
  end

  def add_app_name(file, argv) do
    app = app_module_name(argv)
    EEx.eval_string(file, assigns: [app_name: app])
  end

  def copy_elm_files do
    src = "./priv/templates/phx.gen.elm/assets"
    destination = "./assets"

    files = [
      "elm/Main.elm",
      "elm/Update.elm",
      "elm/View.elm",
      "elm/Model.elm",
      "js/elm-embed.js",
      "elm-package.json"
    ]

    Mix.shell.info("adding elm files 🌳")
    copy_files(files, src, destination)
  end

  def copy_templates(template_paths, src_path, destination, argv) do
    template_paths
    |> Enum.map(fn(x) -> { Path.join(destination, x), File.read!(Path.join(src_path, x)) |> add_app_name(argv) } end)
    |> Enum.map(fn({ dest, file }) -> create_file(dest, file) end)
  end

  def copy_files(file_paths, src_path, destination) do
    file_paths
    |> Enum.map(fn(x) -> { Path.join(destination, x), File.read!(Path.join(src_path, x)) } end)
    |> Enum.map(fn({ dest, file }) -> create_file(dest, file) end)
  end

  def install_node_modules do
    deps = [
      "elm"
    ]

    dev_deps = [
      "elm-brunch",
      "elm-test"
    ]

    change_dir = "cd assets"
    node_install_deps = "npm install -S " <> Enum.join(deps, " ")
    node_install_dev_deps = "npm install -D " <> Enum.join(dev_deps, " ")
    elm_install = "elm-package install -y"

    all_cmds = [
      change_dir,
      node_install_deps,
      node_install_dev_deps,
      elm_install
    ]

    cmd = Enum.join(all_cmds, " && ")

    Mix.shell.info("installing node modules for elm-app ⬇️")
    Mix.shell.info(cmd)
    status = Mix.shell.cmd(cmd, stderr_to_stdout: true)
    case status do
      0 -> :ok
      _ -> raise "Error installing node modules: #{status}"
    end
  end
end
