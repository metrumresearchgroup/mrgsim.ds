library(testthat)
library(mrgsim.ds)

simlist_files_test <- function(x) unlist(lapply(x, files_ds), use.names = FALSE)

# resolving the output directory ------------------------------------------------

test_that("output directory defaults to tempdir", {
  mod <- house_ds(end = 1)
  expect_equal(get_ds_dir(mod), normalizePath(tempdir()))
})

test_that("output directory comes from the ds_dir argument", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1, ds_dir = dir)
  expect_equal(get_ds_dir(mod), normalizePath(dir))

  out <- mrgsim_ds(mod)
  expect_equal(out$dir, normalizePath(dir))
  expect_equal(normalizePath(dirname(out$files[[1]])), normalizePath(dir))
})

test_that("output directory comes from the mrgsim.ds.dir option", {
  dir <- withr::local_tempdir()
  withr::local_options(mrgsim.ds.dir = dir)
  mod <- house_ds(end = 1)
  expect_equal(get_ds_dir(mod), normalizePath(dir))

  out <- mrgsim_ds(mod)
  expect_equal(normalizePath(dirname(out$files[[1]])), normalizePath(dir))
})

test_that("the ds_dir argument takes precedence over the option", {
  opt_dir <- withr::local_tempdir()
  arg_dir <- withr::local_tempdir()
  withr::local_options(mrgsim.ds.dir = opt_dir)
  mod <- house_ds(end = 1, ds_dir = arg_dir)
  expect_equal(get_ds_dir(mod), normalizePath(arg_dir))
})

test_that("the mrgsim.ds.dir option must be a single string", {
  withr::local_options(mrgsim.ds.dir = c("a", "b"))
  expect_error(house_ds(end = 1), "must be a single string")
})

test_that("the output directory is created when it doesn't exist", {
  base <- withr::local_tempdir()
  dir <- file.path(base, "sims", "nested")
  expect_false(dir.exists(dir))
  mod <- house_ds(end = 1, ds_dir = dir)
  expect_true(dir.exists(dir))
  expect_equal(get_ds_dir(mod), normalizePath(dir))
})

test_that("simulating errors when the output directory is gone", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1, ds_dir = dir)
  unlink(dir, recursive = TRUE)
  expect_error(mrgsim_ds(mod), "output directory does not exist")
  expect_false(dir.exists(dir))
})

test_that("all five model loading wrappers accept ds_dir", {
  dir <- withr::local_tempdir()
  code <- "$param a = 1"
  file <- file.path(withr::local_tempdir(), "model.mod")
  cat(code, file = file, sep = "\n")

  mods <- list(
    house_ds(end = 1, ds_dir = dir),
    modlib_ds("pk1", compile = FALSE, ds_dir = dir),
    mcode_ds("test-dir-mcode", code, compile = FALSE, ds_dir = dir),
    mread_ds(file, compile = FALSE, ds_dir = dir),
    mread_cache_ds(file, compile = FALSE, ds_dir = dir)
  )
  for(mod in mods) {
    expect_equal(get_ds_dir(mod), normalizePath(dir))
  }
})

# set_ds_dir / get_ds_dir ------------------------------------------------------

test_that("set_ds_dir re-targets a model after it is loaded", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1)
  mod <- set_ds_dir(mod, dir)
  expect_equal(get_ds_dir(mod), normalizePath(dir))

  out <- mrgsim_ds(mod)
  expect_equal(normalizePath(dirname(out$files[[1]])), normalizePath(dir))
})

test_that("set_ds_dir creates the directory and leaves process info alone", {
  base <- withr::local_tempdir()
  dir <- file.path(base, "sims")
  mod <- house_ds(end = 1)
  pid <- mod@envir$mrgsim.ds.mread_pid
  mod <- set_ds_dir(mod, dir)
  expect_true(dir.exists(dir))
  expect_identical(mod@envir$mrgsim.ds.mread_pid, pid)
  expect_true(mod@envir$mrgsim.ds.mread_valid)
})

test_that("set_ds_dir modifies the model object in place", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1)
  mod2 <- set_ds_dir(mod, dir)
  # the model environment is shared between copies of the model object
  expect_equal(get_ds_dir(mod), normalizePath(dir))
  expect_equal(get_ds_dir(mod2), normalizePath(dir))
})

test_that("set_ds_dir and get_ds_dir require a model object", {
  expect_error(set_ds_dir(list(), tempdir()), "must be an mrgmod object")
  expect_error(get_ds_dir(list()), "must be an mrgmod object")
})

test_that("set_ds_dir requires a model loaded with mread_ds", {
  mod <- mrgsolve::house()
  expect_error(set_ds_dir(mod, tempdir()), "was not loaded with")
})

test_that("get_ds_dir errors when the model has no output directory", {
  mod <- mrgsolve::house()
  expect_error(get_ds_dir(mod), "does not have an output directory")
})

test_that("the output directory falls back to the legacy stamp", {
  mod <- house_ds(end = 1)
  mod@envir$mrgsim.ds.output_dir <- NULL
  mod@envir$mrgsim.ds.mread_tempdir <- tempdir()
  expect_equal(get_ds_dir(mod), tempdir())

  out <- mrgsim_ds(mod)
  expect_true(mrgsim.ds:::in_tempdir(out$files))
})

# validating the directory -----------------------------------------------------

test_that("the output directory cannot contain spaces", {
  dir <- file.path(tempdir(), "with space")
  expect_error(house_ds(end = 1, ds_dir = dir), "cannot contain spaces")
})

test_that("the output directory must be a single string", {
  expect_error(house_ds(end = 1, ds_dir = 5), "must be a single string")
  expect_error(house_ds(end = 1, ds_dir = c("a", "b")), "must be a single string")
  expect_error(house_ds(end = 1, ds_dir = NA_character_), "must be a single string")
})

# gc behavior ------------------------------------------------------------------

test_that("gc is on for output written outside of tempdir", {
  dir <- withr::local_tempdir(tmpdir = getwd())
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod)
  expect_false(mrgsim.ds:::in_tempdir(out$files))
  expect_true(out$gc)
})

test_that("gc switches off when files leave the output directory", {
  dir <- withr::local_tempdir(tmpdir = getwd())
  other <- withr::local_tempdir(tmpdir = getwd())
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod)
  expect_true(out$gc)

  move_ds(out, other, quietly = TRUE)
  expect_false(out$gc)

  # ... and back on when they return home
  move_ds(out, dir, quietly = TRUE)
  expect_true(out$gc)
})

test_that("gc warns when locked to TRUE and files leave the output directory", {
  dir <- withr::local_tempdir(tmpdir = getwd())
  other <- withr::local_tempdir(tmpdir = getwd())
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod)
  out <- gc_ds(out, value = TRUE)
  expect_warning(
    move_ds(out, other, quietly = TRUE), 
    "outside the output directory"
  )
  expect_true(out$gc)
})

test_that("reduce_ds turns gc off when outputs come from different directories", {
  dir1 <- withr::local_tempdir(tmpdir = getwd())
  dir2 <- withr::local_tempdir(tmpdir = getwd())
  mod1 <- house_ds(end = 1, ds_dir = dir1)
  mod2 <- house_ds(end = 1, ds_dir = dir2)
  out <- list(mrgsim_ds(mod1), mrgsim_ds(mod2))
  sims <- reduce_ds(out)
  expect_length(sims$files, 2)
  expect_false(sims$gc)
})

# list_temp() / purge_temp() ---------------------------------------------------

test_that("list_temp and purge_temp honor the dir argument", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- lapply(1:3, function(i) mrgsim_ds(mod, gc = FALSE))
  expect_length(list_temp(dir, quietly = TRUE), 3)
  # ... and the files aren't in the session default directory
  in_temp <- basename(list_temp(quietly = TRUE))
  expect_false(any(basename(simlist_files_test(out)) %in% in_temp))

  expect_message(purge_temp(dir), "Discarding 3 files.")
  expect_length(list_temp(dir, quietly = TRUE), 0)
})

test_that("list_temp and purge_temp default to the mrgsim.ds.dir option", {
  dir <- withr::local_tempdir()
  withr::local_options(mrgsim.ds.dir = dir)
  mod <- house_ds(end = 1)
  out <- mrgsim_ds(mod, gc = FALSE)
  expect_length(list_temp(quietly = TRUE), 1)
  purge_temp(quietly = TRUE)
  expect_length(list_temp(quietly = TRUE), 0)
})

test_that("purge_temp refuses to delete outside tempdir without force", {
  dir <- withr::local_tempdir(tmpdir = getwd())
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod, gc = FALSE)
  expect_error(purge_temp(dir), "refusing to purge")
  expect_length(list_temp(dir, quietly = TRUE), 1)

  purge_temp(dir, quietly = TRUE, force = TRUE)
  expect_length(list_temp(dir, quietly = TRUE), 0)
})

# save_ds() / read_ds() --------------------------------------------------------

test_that("save_ds and read_ds detach the output directory", {
  dir <- withr::local_tempdir()
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod, gc = FALSE)
  save_dir <- withr::local_tempdir(tmpdir = getwd())
  file <- save_ds(out, file.path(save_dir, "out.rds"), quietly = TRUE)
  expect_true(is.na(out$dir))
  expect_true(is.na(readRDS(file)$dir))
  out2 <- read_ds(file)
  expect_true(is.na(out2$dir))
})

test_that("read_ds detaches objects saved with an output directory", {
  mod <- house_ds(end = 1)
  out <- mrgsim_ds(mod, gc = FALSE)
  save_dir <- withr::local_tempdir(tmpdir = getwd())
  file <- save_ds(out, file.path(save_dir, "out.rds"), quietly = TRUE)

  # rds files written by earlier versions carry the simulation directory
  obj <- readRDS(file)
  obj$dir <- normalizePath(save_dir)
  saveRDS(obj, file)

  out2 <- read_ds(file)
  expect_true(is.na(out2$dir))
  expect_false(out2$gc)
})

test_that("read_ds works on an object saved without an output directory", {
  mod <- house_ds(end = 1)
  out <- mrgsim_ds(mod, gc = FALSE)
  save_dir <- withr::local_tempdir(tmpdir = getwd())
  file <- save_ds(out, file.path(save_dir, "out.rds"), quietly = TRUE)

  obj <- readRDS(file)
  obj$dir <- NULL
  saveRDS(obj, file)

  out2 <- read_ds(file)
  expect_true(is.na(out2$dir))
  expect_false(out2$gc)
})

test_that("reduce_ds keeps gc off for restored objects", {
  mod <- house_ds(end = 1)
  out <- mrgsim_ds(mod, gc = FALSE)
  save_dir <- withr::local_tempdir(tmpdir = getwd())
  file <- save_ds(out, file.path(save_dir, "out.rds"), quietly = TRUE)
  out2 <- reduce_ds(list(read_ds(file)))
  expect_false(out2$gc)
})

test_that("moving a saved object back to the output directory keeps gc off", {
  dir <- withr::local_tempdir(tmpdir = getwd())
  mod <- house_ds(end = 1, ds_dir = dir)
  out <- mrgsim_ds(mod)
  save_dir <- withr::local_tempdir(tmpdir = getwd())
  save_ds(out, file.path(save_dir, "out.rds"), quietly = TRUE)
  out <- move_ds(out, dir, quietly = TRUE)
  expect_false(out$gc)
})

mrgsim.ds:::teardown_ds()
