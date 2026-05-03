library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

# save_ds -----------------------------------------------------------------------

test_that("save_ds returns the rds file path invisibly", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  result <- save_ds(out, file)
  expect_equal(result, file)
})

test_that("save_ds writes the rds file", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  expect_true(file.exists(file))
})

test_that("save_ds moves parquet files to rds directory", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  save_ds(out, file.path(dir, "out.rds"))
  expect_equal(dirname(out$files[[1]]), dir)
  expect_true(all(file.exists(out$files)))
})

test_that("save_ds stay_put: files stay in place, rds written there", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  move_ds(out, dir)
  # file arg points elsewhere; stay_put overrides to current location
  rds_path <- save_ds(out, file.path(tempdir(), "out.rds"), stay_put = TRUE)
  expect_equal(dirname(rds_path), dir)
  expect_equal(dirname(out$files[[1]]), dir)
})

test_that("save_ds warns when files end up in tempdir", {
  out <- mrgsim_ds(mod, gc = FALSE)
  file <- file.path(tempdir(), "out.rds")
  expect_warning(save_ds(out, file), "tempdir")
})

# read_ds -----------------------------------------------------------------------

test_that("read_ds errors if file does not exist", {
  expect_error(read_ds("no-such-file.rds"), "does not exist")
})

test_that("read_ds errors on an rds file not written by save_ds", {
  tmp <- tempfile(fileext = ".rds")
  saveRDS(list(a = 1), tmp)
  on.exit(unlink(tmp))
  expect_error(read_ds(tmp), "unrecognized")
})

test_that("read_ds errors when parquet files are missing", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  file.remove(out$files)
  expect_error(read_ds(file), "could not be located")
})

test_that("read_ds returns an mrgsimsds object", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  out2 <- read_ds(file)
  expect_is(out2, "mrgsimsds")
})

test_that("read_ds: gc is disabled on the restored object", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  out2 <- read_ds(file)
  expect_false(out2$gc)
})

test_that("read_ds: restored object owns its files", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  out2 <- read_ds(file)
  expect_true(check_ownership(out2))
})

test_that("read_ds: data is preserved through round-trip", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  out2 <- read_ds(file)
  expect_equal(dplyr::collect(out), dplyr::collect(out2))
})

test_that("read_ds: restored object has a valid Arrow Dataset pointer", {
  out <- mrgsim_ds(mod, gc = FALSE)
  dir <- withr::local_tempdir(tmpdir = getwd())
  file <- file.path(dir, "out.rds")
  save_ds(out, file)
  out2 <- read_ds(file)
  expect_is(dplyr::collect(out2), "tbl")
})

rm(mod)
mrgsim.ds:::teardown_ds()
