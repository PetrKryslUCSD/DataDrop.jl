using Documenter, DataDrop

makedocs(
	modules = [DataDrop],
	doctest = false, clean = true,
	format = Documenter.HTML(prettyurls = false),
	authors = "Petr Krysl",
	sitename = "DataDrop.jl",
	pages = Any[
			"Home" => "index.md",
			"Reference" => "man/reference.md"	
		],
	)

deploydocs(
    repo = "github.com/PetrKryslUCSD/DataDrop.jl.git",
    devbranch = "main"
)
