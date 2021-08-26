using Documenter, DataValet

makedocs(
	modules = [DataValet],
	doctest = false, clean = true,
	format = Documenter.HTML(prettyurls = false),
	authors = "Petr Krysl",
	sitename = "DataValet.jl",
	pages = Any[
			"Home" => "index.md",
			"How to guide" => "guide/guide.md",
			"Reference" => "man/reference.md"	
		],
	)

deploydocs(
    repo = "github.com/PetrKryslUCSD/DataValet.jl.git",
    devbranch = "main"
)
