local_unset_tempdir <- function() {
  key_t <- "tempdir"
  key_tb <- "tempdir_base"

  orig_t <- .global[[key_t]]
  orig_tb <- .global[[key_tb]]

  withr::defer_parent({
    .global[[key_t]] <- orig_t
    .global[[key_tb]] <- orig_tb
  })

  .global[[key_t]] <- NULL
  .global[[key_tb]] <- NULL
}

test_that("set_tempdir_base", {
  local_unset_tempdir()

  tdir <- withr::local_tempdir()
  res <- set_tempdir_base(tdir)

  expect_identical(res, our_tempdir())

  mod <- house_ds(end = 3, delta = 1)

  expect_match(list.files(tdir), "^mrgsim\\.ds-")
  expect_identical(
    normalizePath(
      dirname(mod@envir[["mrgsim.ds.mread_tempdir"]]),
      mustWork = TRUE
    ),
    normalizePath(tdir, mustWork = TRUE)
  )
})

test_that("set_tempdir_base: already in use", {
  local_unset_tempdir()

  tdir <- withr::local_tempdir()
  mod <- house_ds(end = 3, delta = 1)
  expect_error(set_tempdir_base(tdir), "already in use")
})

test_that("set_tempdir_base: non-existent", {
  local_unset_tempdir()

  tdir <- withr::local_tempdir()
  expect_error(
    set_tempdir_base(file.path(tdir, "doesntexist")),
    "not an existing directory"
  )
})

test_that("mrgsim_ds errors if temporary directory does not exist", {
  local_unset_tempdir()

  tdir <- withr::local_tempdir()
  set_tempdir_base(tdir)
  mod <- house_ds(end = 3, delta = 1)
  unlink(tdir, recursive = TRUE)

  expect_error(mrgsim_ds(mod), "temporary directory does not exist")
})

test_that("in_tempdir", {
  local_unset_tempdir()

  dir_in_rtmp <- withr::local_tempdir()
  dir_in_cwd <- withr::local_tempdir(tmpdir = getwd())
  dir_in_settmp <- set_tempdir_base(dir_in_cwd)

  file_a <- file.path(dir_in_rtmp, "a")
  file_b1 <- file.path(dir_in_cwd, "b1")
  file_b2 <- file.path(dir_in_cwd, "b2")
  file_c1 <- file.path(dir_in_settmp, "c1")
  file_c2 <- file.path(dir_in_settmp, "c2")

  cat("", file = file_a)
  cat("", file = file_b1)
  cat("", file = file_b2)
  cat("", file = file_c1)
  cat("", file = file_c2)

  expect_true(in_tempdir(file_a))

  expect_false(in_tempdir(file_b1))
  expect_false(in_tempdir(c(file_b1, file_b2)))

  expect_true(in_tempdir(file_c1))
  expect_true(in_tempdir(c(file_c1, file_c2)))
})

test_that("in_tempdir: errors", {
  expect_error(in_tempdir(NULL), "at least one file")
  expect_error(in_tempdir(c()), "at least one file")
  expect_error(in_tempdir(c("foo/a", "bar/b")), "same directory")
})
