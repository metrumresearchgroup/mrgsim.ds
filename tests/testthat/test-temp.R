test_that("in_tempdir", {
  dir_in_rtmp <- withr::local_tempdir()

  file_a <- file.path(dir_in_rtmp, "a")
  cat("", file = file_a)

  expect_true(in_tempdir(file_a))
})
