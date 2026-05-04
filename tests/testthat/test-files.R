library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("total size", {
  out1 <- mrgsim_ds(mod, gc = FALSE)
  tot <- mrgsim.ds:::total_size(out1$files)
  expect_is(tot, "character")
  expect_match(tot, "Kb")
  
  out2 <- mrgsim_ds(mod, gc = FALSE)
  out3 <- mrgsim_ds(mod, gc = FALSE)
  
  out <- reduce_ds(list(out1, out2, out3))
  
  status <- file.remove(out$files[2])
  
  expect_equal(mrgsim.ds:::total_size(out$files), "5.5 Kb")
})

test_that("files exist", {
  out <- mrgsim_ds(mod, gc = FALSE)
  expect_silent(mrgsim.ds:::check_files_fatal(out))
  out$files <- "b"
  expect_error(mrgsim.ds:::check_files_fatal(out), "do not exist")
})

test_that("clean up", {
  out <- mrgsim_ds(mod, gc = TRUE)
  expect_true(file.exists(out$files))
  files <- out$files
  rm(out)
  gc()
  expect_false(file.exists(files))
})

test_that("file_ds", {
  set.seed(123)
  x <- mrgsim.ds:::file_ds()
  expect_is(x, "character")
  expect_match(x, "mrgsims-ds-", fixed = TRUE)
  expect_match(x, ".parquet", fixed = TRUE)
  
  x <- mrgsim.ds:::file_ds("fizz")
  expect_equal(x, "mrgsims-ds-fizz.parquet")
})

test_that("rename_ds", {
  out <- mrgsim_ds(mod)
  a <- basename(out$files)
  rename_ds(out, "zip")
  b <- basename(out$files)
  expect_equal(b, "mrgsims-ds-zip-1.parquet")
})

test_that("move_ds issues a message when quietly = FALSE", {
  out <- mrgsim_ds(mod)
  nw <- file.path(tempdir(), "newdir")
  expect_message(move_ds(out, path = nw), "files are now located in")
})

test_that("move_ds", {
  out <- mrgsim_ds(mod)
  nw <- file.path(tempdir(), "newdir")
  move_ds(out, path = nw, quietly = TRUE)
  tst <- basename(dirname(out$files))
  expect_equal(tst, "newdir")
  expect_true(out$gc)

  tmp_path <- withr::local_tempdir(tmpdir = getwd())
  test_dir <- file.path(tmp_path, "simulated-output")
  move_ds(out, test_dir, quietly = TRUE)
  expect_false(out$gc)  
})

test_that("temp file helpers", {
  purge_temp(quietly = TRUE)
  out <- mrgsim_ds(mod, gc = FALSE)
  out <- mrgsim_ds(mod, gc = FALSE)
  out <- mrgsim_ds(mod, gc = FALSE)
  x <- capture.output(list_temp())
  expect_length(x, 4)
  expect_message(x <- purge_temp(), "Discarding 3 files.")
  expect_null(x)
  
  expect_silent(purge_temp(quietly = TRUE))
  out1 <- mrgsim_ds(mod, gc = FALSE)
  out2 <- mrgsim_ds(mod, gc = FALSE)
  out3 <- mrgsim_ds(mod, gc = FALSE)
  f <- c(out1$files, out3$files)  
  expect_message(retain_temp(out1, out3), "Discarding 1 files.")

  purge_temp(quietly = TRUE)
  out <- lapply(1:7, \(x) mrgsim_ds(mod))
  devnull <- capture.output(x <- list_temp())
  expect_length(x, 7)
  
  expect_message(purge_temp())
  
  out1 <- mrgsim_ds(mod)
  out2 <- mrgsim_ds(mod)
  out3 <- mrgsim_ds(mod)
  
  expect_length(x <- capture.output(list_temp()), 4)
  expect_silent(list_temp(quietly = TRUE))
  
  expect_message(retain_temp(out1))
  expect_silent(retain_temp(out2, quietly = TRUE))
})

rm(mod)
mrgsim.ds:::teardown_ds()
