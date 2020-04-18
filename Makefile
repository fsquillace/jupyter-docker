
CONDA_ENV ?= base
WORK_DIR ?= $(PWD)

DOCKER_IMAGE ?= feel/ganimede


###########################
# General targets
###########################
test:
	bash ./tests/test_ganimede.sh


###########################
# Conda related targets
###########################
conda-setup-libraries:
	conda run -n $(CONDA_ENV) ./bin/setup-libraries.sh

conda-setup-tools:
	conda run -n $(CONDA_ENV) ./bin/setup-tools.sh


###########################
# Docker related targets
###########################
# `--pull` attempts to pull latest version of base image:
docker-build:
	docker image build --pull -t ganimede -f Dockerfile .

docker-push:
	docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
	docker push feel/ganimede

docker-pull:
	docker pull $(DOCKER_IMAGE)

docker-run:
	docker run --rm -p 8888:8888 \
        -v "$(WORK_DIR)":/home/jovyan/work \
        -e JUPYTER_ENABLE_LAB="1" \
        --name ganimede $(DOCKER_IMAGE) start-notebook.sh --LabApp.token=''

docker-background-run:
	docker run --rm -p 8888:8888 \
        -d \
        -v "$(WORK_DIR)":/home/jovyan/work \
        -e JUPYTER_ENABLE_LAB="1" \
        --name ganimede $(DOCKER_IMAGE) start-notebook.sh --LabApp.token=''

docker-boot-run:
	docker run -d --restart unless-stopped -p 8888:8888 \
        -v "$(WORK_DIR)":/home/jovyan/work \
        -e JUPYTER_ENABLE_LAB="1" \
        name notebook $(DOCKER_IMAGE) start-notebook.sh --LabApp.token=''

docker-shell:
	docker exec -it ganimede /bin/bash


###########################
# Systemd related targets
###########################
setup-systemd-service:
	mkdir -p ${HOME}/.config/systemd/user/
	cp ganimede.service ${HOME}/.config/systemd/user/
	systemctl --user daemon-reload
	systemctl --user enable ganimede.service

start-systemd-service: setup-systemd-service
	systemctl --user start ganimede.service


