VENV_NAME?=venv
PYTHON?=python3.7

venv: $(VENV_NAME)/bin/activate

$(VENV_NAME)/bin/activate:
	virtualenv --python "$(which $(PYTHON))" --clear $(VENV_NAME)
	$(VENV_NAME)/bin/pip install pip==22.1.1
	$(VENV_NAME)/bin/pip install -r requirements.txt

clean:
	rm -rf $(VENV_NAME) dist/


.PHONY: venv clean
