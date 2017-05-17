defmodule Mix.Tasks.Phx.Gen.Elm do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates an elm app with all the necessary scaffolding"

  def run(_argv) do
    copy_phoenix_files()
    copy_elm_files()
    copy_elm_test_files()
    install_node_modules()
    post_install_instructions()
  end

  def post_install_instructions() do
    instructions = """

    🎉 ✨  Your elm app is almost ready to go! ✨ 🎉

    1. add the following to the 'plugins' section of your brunch-config.js


        elmBrunch: {
          mainModules: ['elm/Main.elm'],
          outputFile: 'elm.js',
          outputFolder: '../assets/js',
          makeParameters: ['--debug']
        }

    2. add 'elm' to the 'watched' array in your brunch-config.js


    3. in your app.js file add the following


        import ElmApp from './elm.js'
        import elmEmbed from './elm-embed.js'

        elmEmbed.init(ElmApp)


    4. and finally in your 'router.ex' file add


        get "/", ElmController, :index


    """

    Mix.shell.info(instructions)
  end


  def copy_phoenix_files do
    src = "./priv/templates/phx.gen.elm"
    destination = Mix.Phoenix.web_prefix()

    static_files = [
      "templates/elm/index.html.eex"
    ]

    templates = [
      "views/elm_view.ex",
      "controllers/elm_controller.ex",
    ]

    Mix.shell.info("adding phoenix files 🕊 🔥")
    copy_files(static_files, src, destination)
    copy_templates(templates, src, destination)
  end

  def add_app_name(file) do
    app = app_module_name()
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

  def copy_elm_test_files do
    src = "./priv/templates/phx.gen.elm/test"
    destination = "./test"

    files = [
      "elm/Main.elm",
      "elm/Sample.elm",
      "elm/elm-package.json"
    ]

    copy_files(files, src, destination)
  end

  def copy_templates(template_paths, src_path, destination) do
    template_paths
    |> Enum.map(fn(x) -> { Path.join(destination, x), File.read!(Path.join(src_path, x)) |> add_app_name() } end)
    |> Enum.map(&create_template/1)
  end

  defp create_template({ dest, file }) do
    create_file(dest, file)
    File.touch!(dest, :calendar.local_time())
  end

  def copy_files(file_paths, src_path, destination) do
    file_paths
    |> Enum.map(fn(x) -> { Path.join(destination, x), File.read!(Path.join(src_path, x)) } end)
    |> Enum.map(fn({ dest, file }) -> create_file(dest, file) end)
  end

  def app_module_name do
    Mix.Phoenix.otp_app()
    |> Atom.to_string
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
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
