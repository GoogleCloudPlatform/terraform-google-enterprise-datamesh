
FROM gcr.io/dataflow-templates-base/python311-template-launcher-base:latest

ARG ARG_PIP_INDEX_URL=https://us-central1-python.pkg.dev/project-id/python-modules/simple/
# ARG PIP_EXTRA_INDEX_URL=https://pypi.python.org/simple

ENV FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE="/template/requirements.txt"
ENV FLEX_TEMPLATE_PYTHON_PY_FILE="/template/reidentify-ncnf-to-cnf-bq.py"

COPY . /template

# We could get rid of installing libffi-dev and git, or we could leave them.
RUN apt-get update \
    && apt-get install -y \
    # apt-transport-https curl gnupg \
    libffi-dev git \ 
    && rm -rf /var/lib/apt/lists/* 

# Upgrade pip and install the requirements.
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir twine keyrings.google-artifactregistry-auth \
    && pip install --no-cache-dir -r $FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE \
    # Download the requirements to speed up launching the Dataflow job.
    && pip download --no-cache-dir --dest /tmp/dataflow-requirements-cache -r $FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE

# Since we already downloaded all the dependencies, there's no need to rebuild everything.
ENV PIP_NO_DEPS=True
ENV PIP_INDEX_URL=$ARG_PIP_INDEX_URL
# ENV PIP_EXTRA_INDEX_URL=$PIP_EXTRA_INDEX_URL