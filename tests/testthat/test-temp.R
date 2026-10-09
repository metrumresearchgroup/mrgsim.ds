test_that("in_tempdir", {
  dir_in_rtmp <- withr::local_tempdir()

  file_a <- file.path(dir_in_rtmp, "a")
  cat("", file = file_a)

  expect_true(in_tempdir(file_a))
})

test_that("in_tempdir: errors", {
  expect_error(in_tempdir(NULL), "at least one file")
  expect_error(in_tempdir(c()), "at least one file")
  expect_error(in_tempdir(c("foo/a", "bar/b")), "same directory")
})
