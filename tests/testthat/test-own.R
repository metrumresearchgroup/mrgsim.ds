library(testthat)
library(mrgsim.ds)

test_that("hash files", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  
  expect_is(out$hash, "character")
  h <- digest::getVDigest(algo = mrgsim.ds:::digest_algo)
  expect_equal(out$hash, h(out$files))
})

test_that("ownership", {
  mrgsim.ds:::clear_ownership()
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  
  expect_true(check_ownership(out))
  
  x <- capture.output(ownership())
  expect_match(x, "Objects: 1")
  
  df <- list_ownership()
  expect_is(df, "data.frame")
  
  out <- mrgsim_ds(mod)
  expect_true(check_ownership(out))
  disown(out)
  expect_false(check_ownership(out))
})

test_that("copy ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod, gc = FALSE)
  
  x <- copy_ds(out)
  expect_true(check_ownership(x))
  expect_false(check_ownership(out))
  
  out <- mrgsim_ds(mod)
  y <- copy_ds(out, own = FALSE)
  expect_false(check_ownership(y))
  expect_true(check_ownership(out))
  
  z <- take_ownership(y)
  expect_true(check_ownership(y))
  expect_false(check_ownership(out))
})

mrgsim.ds:::teardown_ds()
