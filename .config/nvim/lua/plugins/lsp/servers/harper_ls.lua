return {
  filetypes = { "gitcommit", "markdown" },
  settings = {
    ["harper-ls"] = {
      userDictPath = vim.fs.joinpath(vim.fn.stdpath("config"), "dictionary.txt"),
    },
  },
}
