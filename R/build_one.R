local({
  # input/output filenames are passed as command-line arguments
  a = commandArgs(TRUE)
  if (length(a) < 2) stop(
    "The script build_one.R requires at least 2 command-line args"
  )
  unlink(a[2])

  # for external Rmd, '../../foo/bar/hi.Rmd' -> 'hi'; for internal,
  # content/foo/bar/hi.Rmd -> foo/bar/hi
  d = knitr:::sans_ext(
    if (a[4] == 'TRUE') basename(a[1]) else gsub('^content/', '', a[1])
  )
  knitr::opts_chunk$set(
    fig.path   = sprintf('figures/%s/', d),
    cache.path = sprintf('blogdown/cache/%s/', d),
    error = FALSE, fig.width = 6, fig.height = 5, dpi = 96, tidy = TRUE
  )
  knitr::opts_knit$set(
    base.dir = normalizePath('static/', mustWork = TRUE),
    base.url = if (a[3] == 'FALSE') 'https://assets.yihui.name/' else '/',
    width = 60
  )
  knitr::knit(a[1], a[2], quiet = TRUE, encoding = 'UTF-8', envir = .GlobalEnv)
  if (file.exists(a[2])) {
    x = blogdown:::append_yaml(
      blogdown:::readUTF8(a[2]), if (a[4] == 'FALSE') list(from_Rmd = TRUE)
    )
    blogdown:::writeUTF8(xaringan:::protect_math(x), a[2])
    Sys.chmod(a[2], '0444')  # read-only (should not edit)
  }
})
