library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)
data <- ev_expand(amt = 100, ID = 1:3)
out <- mrgsim_ds(mod, data = data, gc = FALSE)

test_that("test verbs", {
  a <- dplyr::group_by(out)
  sims <- dplyr::collect(a)
  expect_is(a, "arrow_dplyr_query")
  expect_is(sims, "tbl")

  b <- dplyr::mutate(out, z = 1)  
  sims <- dplyr::collect(b)
  expect_is(b, "arrow_dplyr_query")
  expect_is(sims, "tbl")
  expect_all_true(sims$z==1)

  c <- dplyr::select(out, time, DV)
  sims <- dplyr::collect(c)
  expect_is(b, "arrow_dplyr_query")
  expect_is(sims, "tbl")
  expect_equal(names(sims), c("time", "DV"))
  
  d <- dplyr::filter(out, time < 3, ID==1)
  sims <- dplyr::collect(d)
  expect_equal(sims$time, c(0,0,1,2))

  e <- dplyr::group_by(out, ID) |> dplyr::summarise(M = mean(DV))
  sims <- dplyr::collect(e)
  expect_equal(sort(sims$ID), c(1,2,3))
  
  f <- dplyr::arrange(out, DV)
  sims <- dplyr::collect(f)
  expect_equal(sims$DV, sort(sims$DV))

  g <- dplyr::rename(out, subject = ID)
  sims <- dplyr::collect(g)
  expect_equal(names(sims)[1], "subject")

})

test_that("distinct works on mrgsimsds", {
  h <- dplyr::distinct(out, ID)
  sims <- dplyr::collect(h)
  expect_is(h, "arrow_dplyr_query")
  expect_equal(nrow(sims), 3)
  expect_equal(names(sims), "ID")

  h2 <- dplyr::distinct(out, ID, .keep_all = TRUE)
  sims2 <- dplyr::collect(h2)
  expect_true(ncol(sims2) > 1)
  expect_equal(nrow(sims2), 3)
})

test_that("relocate works on mrgsimsds", {
  h <- dplyr::relocate(out, DV, .before = ID)
  sims <- dplyr::collect(h)
  expect_is(h, "arrow_dplyr_query")
  expect_equal(names(sims)[1], "DV")
})

test_that("count works on mrgsimsds", {
  h <- dplyr::count(out, ID)
  sims <- dplyr::collect(h)
  expect_is(h, "arrow_dplyr_query")
  expect_equal(nrow(sims), 3)
  expect_true("n" %in% names(sims))
  expect_true(all(sims$n == 5))
})

test_that("pull works on mrgsimsds", {
  ids <- dplyr::pull(out, ID)
  expect_true(is.numeric(ids))
  expect_equal(sort(unique(ids)), c(1, 2, 3))
})

rm(out, mod, data)
