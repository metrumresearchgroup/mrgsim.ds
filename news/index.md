# Changelog

## mrgsim.ds 0.2.0

- The new
  [`set_tempdir_base()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/set_tempdir_base.md)
  function can be used to tell `mrgsim.ds` to store its temporary files
  in a directory outside of
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)
  ([\#18](https://github.com/metrumresearchgroup/mrgsim.ds/issues/18)).

## mrgsim.ds 0.1.1

- Minor fixes: corrected the package description in `DESCRIPTION`
  ([\#11](https://github.com/metrumresearchgroup/mrgsim.ds/issues/11))
  and  
  removed the r-universe links from the README
  ([\#13](https://github.com/metrumresearchgroup/mrgsim.ds/issues/13)).

### Bugs fixed

- Fixed a bug where garbage collection of an `mrgsimsds` object left
  stale entries in the internal `addresses` map; `clean_up_ds()` now
  disowns the files it removes
  ([\#10](https://github.com/metrumresearchgroup/mrgsim.ds/issues/10)).

## mrgsim.ds 0.1.0

- Initial release
