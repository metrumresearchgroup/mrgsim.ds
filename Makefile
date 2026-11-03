SHELL := /bin/bash
PACKAGE=mrgsim.ds
VERSION=$(shell grep Version DESCRIPTION |awk '{print $$2}')
TARBALL=${PACKAGE}_${VERSION}.tar.gz
PKGDIR=.
CHKDIR=.

travis:
	make build
	R CMD check ${TARBALL} --as-cran

test:
	Rscript -e 'library(testthat)' -e 'test_file("tests/testthat.R")'

rhub:
	Rscript -e 'rhub::check_for_cran()'

cran:
	rm -rf mrgsim.ds.Rcheck
	make doc
	make build-vignettes
	R CMD check ${TARBALL} --as-cran

ec:
	echo ${VERSION}

all:
	make doc
	make build
	make install

.PHONY: doc
doc:
	Rscript -e 'library(devtools); document()'
.PHONY: build
build:
	R CMD build --md5  --no-build-vignettes $(PKGDIR)

build-vignettes:
	R CMD build --md5 $(PKGDIR)

package:
	make doc
	make build-vignettes
	make install

install:
	R CMD install --install-tests ${TARBALL}

install-build:
	R CMD install --build --install-tests ${TARBALL}

check:
	rm -rf mrgsim.ds.Rcheck
	make doc
	make build
	R CMD check  --ignore-vignettes --no-manual ${TARBALL} -o ${CHKDIR}

unit-csv:
	Rscript inst/script/unit.R

readme:
	Rscript -e 'rmarkdown::render("README.Rmd")'

pkgdown:
	Rscript -e 'pkgdown::build_site()'

spelling:
	Rscript inst/script/_spelling.R

check-win:
	Rscript -e 'devtools::check_win_devel()'

bump-dev:
	Rscript -e 'usethis::use_version("dev")'

tag-version:
	git tag $(VERSION)
	git push origin $(VERSION)

covr:
	Rscript inst/script/covr.R

clean: 	
	rm -rf mrgsim\.ds\.Rcheck
	rm -f mrgsim\.ds*\.tar\.gz
	rm -f README.html
