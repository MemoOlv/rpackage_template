all: check

.PHONY: \
    check \
    clean \
    format \
    green \
    init \
    install \
    red \
    refactor \
    setup \
    tests

check:
	R -e "library(styler)" \
      -e "resumen <- style_dir('R')" \
      -e "resumen <- rbind(resumen, style_dir('tests'))" \
      -e "resumen <- rbind(resumen, style_dir('tests/testthat'))" \
      -e "any(resumen[[2]])" \
      | grep FALSE

clean:
	rm --force *.tar.gz
	rm --force --recursive tests/testthat/_snaps
	rm --force NAMESPACE
	rm --force --recursive *.Rcheck

format:
	R -e "library(styler)" \
      -e "style_dir('R')" \
      -e "style_dir('tests')" \
      -e "style_dir('tests/testthat')"

init: setup tests

setup: clean install

red: format
	Rscript -e "devtools::test(stop_on_failure = TRUE)" \
	&& git restore . \
	|| (git add tests/testthat/*.R && git commit -m "🛑🧪 Fail tests")
	chmod g+w -R .

green: format
	Rscript -e "devtools::test(stop_on_failure = TRUE)" \
	&& (git add R/*.R && git commit -m "✅ Pass tests") \
	|| git restore .
	chmod g+w -R .

refactor: format
	Rscript -e "devtools::test(stop_on_failure = TRUE)" \
	&& (git add R/*.R tests/testthat/*.R && git commit -m "♻️  Refactor") \
	|| git restore .
	chmod g+w -R .

setup: clean install

install:
	R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check rpackage.template_0.1.0.tar.gz && \
    R CMD INSTALL rpackage.template_0.1.0.tar.gz

install_dependencies:
	R -e "devtools::install()" && \
    R -e "devtools::document()" && \
    R -e "devtools::build()" && \
    R -e "devtools::check()"

tests:
	Rscript -e "devtools::test(stop_on_failure = TRUE)"