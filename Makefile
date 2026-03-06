BUILD_PATH = stacks/degrades_reporting/terraform/lambda/build
DEGRADES_LAMBDA_PATH = lambdas/degrades_reporting
LAMBDA_TEST_PATH = lambdas/tests
UTILS = degrade_utils
REQUIREMENTS_PATH=lambdas/requirements
SHARED_REQUIREMENTS=$(REQUIREMENTS_PATH)/shared_requirements.txt
TEST_REQUIREMENTS=$(REQUIREMENTS_PATH)/test_requirements.txt

env:
	@echo "Removing old venv."
	@rm -rf lambdas/venv || true
	@echo "Building new venv and installing requirements."
	@python3.13 -m venv ./lambdas/venv
	@./lambdas/venv/bin/pip3 install --upgrade pip
	@./lambdas/venv/bin/pip3 install -r $(SHARED_REQUIREMENTS) --no-cache-dir
	@./lambdas/venv/bin/pip3 install -r $(TEST_REQUIREMENTS) --no-cache-dir
	./lambdas/venv/bin/pip install pytest pytest-cov pytest-mock
	@echo "Now activate your venv."

test-degrades:
	rm -rf tmp/reports || true
	mkdir -p tmp/reports
	cd $(DEGRADES_LAMBDA_PATH)  && venv/bin/python3 -m pytest tests/

setup-test-env:
	rm -rf tmp/reports || true
	mkdir -p tmp/reports
	rm -rf $(LAMBDA_TEST_PATH)/.venv
	python 3.12 -m venv $(LAMBDA_TEST_PATH)/.venv
	$(LAMBDA_TEST_PATH)/.venv/bin/pip install -r lambdas/test_requirements.txt pytest pytest-cov

test-without-coverage:
	cd ./lambdas && PYTHONPATH=.:./tests ./venv/bin/python3 -m pytest tests

test-with-coverage:
	cd ./lambdas && PYTHONPATH=.:./tests ./venv/bin/python3 -m pytest tests \
		--cov=. \
		--cov-report=xml:../tmp/reports/coverage.xml

format-degrades:
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/ruff format
	cd stacks/degrades_reporting/terraform && terraform fmt -recursive


