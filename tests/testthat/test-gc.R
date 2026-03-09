library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("set gc status - single object", {
  out <- mrgsim_ds(mod)
  expect_true(out$gc)
  
  out <- gc_ds(out, FALSE)
  expect_false(out$gc)
  
  out <- gc_ds(out, TRUE)
  expect_true(out$gc)
})

test_that("set gc status - list", {
  out <- list(mrgsim_ds(mod), mrgsim_ds(mod))
  
  expect_true(out[[1]]$gc)
  expect_true(out[[2]]$gc)  
  
  out <- gc_ds(out, FALSE)
  
  expect_false(out[[1]]$gc)
  expect_false(out[[2]]$gc)   
  
})

test_that("set gc notify status", {
  out <- mrgsim_ds(mod)
  expect_false(out$gc_notify)
  out <- gc_ds(out, notify = TRUE)
  expect_true(out$gc_notify)
})

test_that("send to trash", {
  glo <- mrgsim.ds:::.global
  out <- list(mrgsim_ds(mod), mrgsim_ds(mod))
  out <- reduce_ds(out)
  
  f <- list.files(glo$trashcan)
  unlink(f, recursive = TRUE)
  mrgsim.ds:::clean_up_ds(out)
  
  expect_setequal(out$hash, list.files(glo$trashcan)) 
  
  l <- list.files(glo$trashcan, full.names = TRUE)
  f <- unname(sapply(l, readLines))
  
  f <- sort(basename(f))
  files <- sort(basename(out$files))
  
  expect_setequal(basename(f), basename(out$files))
  
  out <- mrgsim_ds(mod)
  out <- gc_ds(out, notify = TRUE)
  expect_message(
    mrgsim.ds:::clean_up_ds(out), 
    "cleaning up 1 file"
  )
})


rm(mod)
