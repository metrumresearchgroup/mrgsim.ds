library(testthat)
library(mrgsim.ds)

test_that("mrgsim_ds", {
  mod <- house_ds(end = 2, delta = 1)
  out <- mrgsim_ds(mod, idata = expand.idata(1:10),, events = ev(amt=100))
  expect_is(out, "mrgsimsds")
  expect_all_true(file.exists(out$files))
  expect_false(mrgsim.ds:::invalid_ds(out))
  
  sims <- as_tibble(out)
  expect_identical(dim(sims), out$dim)
  expect_identical(dim(sims), dim(out))
  expect_identical(names(sims), out$names)
  expect_identical(names(sims), names(out))
  expect_identical(head(out), sims[1:6,])
  expect_identical(tail(out), tail(sims))
  
  x <- plot(out, nid = 3)
  expect_is(x, "trellis")
  d <- mrgsim.ds:::get_nid_from_ds(out, nid = 4)
  expect_equal(length(unique(d$ID)), 4)
  d <- mrgsim.ds:::get_nid_from_ds(out, nid = 11)
  expect_equal(length(unique(d$ID)), 10)
})

test_that("as_mrgsim_ds", {
  mod <- house_ds(end = 3, delta = 1)
  x <- mrgsim(mod)
  out <- as_mrgsim_ds(x)
  expect_is(out, "mrgsimsds")
  expect_all_true(file.exists(out$files))
  expect_false(mrgsim.ds:::invalid_ds(out))
})

test_that("tag output data", {
  mod <- house_ds(end = 3, delta = 1)
  tg <- list(a = 1, b = 2)
  out <- mrgsim_ds(mod, tags = tg)
  out <- as_tibble(out)
  expect_true("a" %in% names(out))
  expect_true("b" %in% names(out))
  expect_all_true(out$a==1)
  expect_all_true(out$b==2)
  
  expect_error(mrgsim_ds(mod, tags = list(1)), "must be a named list")
})

test_that("copy an object", {
  mod <- house_ds(end = 24, delta = 1)
  out1 <- mrgsim_ds(mod, events = ev(amt = 100))
  out2 <- copy_ds(out1)
  o1 <- as.list(out1)
  o2 <- as.list(out2)
  # guaranteed to be different; just set to be equal
  o1$address <- o2$address
  expect_identical(names(o1), names(o2))
  o1$ds <- collect(out1)
  o2$ds <- collect(out2)
  expect_identical(o1, o2)
})
