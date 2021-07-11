# Makefile - Utilitários do projeto
# =================================
#
# Autodocumentação
# ----------------
#
# O arquivo usa uma formatação especial para tornar possível sua
# autodocumentação. Ele está separado em seções (linhas iniciadas com `##@ `) e
# cada comando tem sua descrição (linhas com `### ` a partir de um ponto após o
# nome do comando) que são comentários que serão aproveitados pelo comando
# `make help` para mostrar a documentação do arquivo.
#
#
# Regras de modificação
# ---------------------
#
# - Mantenha a consistência da separação de interesses em seções
# - O que não pertencer a nenhuma seção deve ficar no topo do documento
# - Ordem de declaração: variáveis -> funções -> .PHONY -> comandos
# - Comandos devem ser palavras de fácil memorização separadas por `-`
# - Mantenha a ordem alfabética
# - Declare o .PHONY na mesma ordem dos comandos
# - Sempre que possível aproxime comandos, variáveis, etc. contextualmente
#   próximos
# - Sempre documente, mas deixe a documentação visível externamente apenas
#   para comandos utilizados com frequência por usuários
# - Na dúvida, sempre use `@` para suprimir a impressão do comando


POD_NAME ?= pesquisa-diarios-covid

ELASTICSEARCH_CONTAINER_NAME ?= $(POD_NAME)-elasticsearch
ELASTICSEARCH_PORT ?= 9200


.DEFAULT_GOAL:=help


##@ Dependências

.PHONY: deps-install deps-update

deps-install: requirements.txt  ### Instala dependências de desenvolvimento
	pip install -r requirements.txt

deps-update: requirements.in  ### Atualiza dependências de desenvolvimento
	pip-compile requirements.in > requirements.txt


##@ Execução

.PHONY: create-pod destroy-pod run

create-pod: destroy-pod  ## Cria pod POD_NAME que agrupa containers
	podman pod create --publish $(ELASTICSEARCH_PORT):$(ELASTICSEARCH_PORT) --name $(POD_NAME)

destroy-pod:  ## Destrói pod POD_NAME que agrupa containers
	podman pod rm --force --ignore $(POD_NAME)

run: create-pod elasticsearch index  ### Executa passos necessários para indexação dos documentos e os indexa


##@ Indexação

.PHONY: elasticsearch index start-elasticsearch stop-elasticsearch wait-elasticsearch

elasticsearch: stop-elasticsearch start-elasticsearch wait-elasticsearch  ### Executa instância do elasticsearch

index: index_diarios.py  ### Indexa documentos em índice do elasticsearch
	python index_diarios.py

start-elasticsearch:  ## Inicia container do elasticsearch
	podman run -d --rm -ti \
		--name $(ELASTICSEARCH_CONTAINER_NAME) \
		--pod $(POD_NAME) \
		--env discovery.type=single-node \
		docker.io/elasticsearch:7.9.1

stop-elasticsearch:  ## Desliga container do elasticsearch
	podman rm --force --ignore $(ELASTICSEARCH_CONTAINER_NAME)

wait-elasticsearch:  ## Espera container do elasticsearch ficar disponível
	test -f scripts/wait-for || wget -qO scripts/wait-for https://raw.githubusercontent.com/eficode/wait-for/master/wait-for
	chmod +x ./scripts/wait-for
	./scripts/wait-for localhost:$(ELASTICSEARCH_PORT) --timeout=30 -- echo "Elasticsearch container is up"


##@ Diversos

.PHONY: help help-all

help:  ### Mostra uso de comandos utilitários mais frequentes
	@awk 'BEGIN {FS = ":.*##"; printf "Utilitários do projeto mais usados.\n\nComo usar: make [COMANDO]\n  Para ver todos os comandos diponíveis, execute `make help-all`.\n"} /^[a-zA-Z_-]+:.*?###/ { printf "  %-20s  %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

help-all:  ### Mostra uso de todos os comandos utilitários
	@awk 'BEGIN {FS = ":.*##"; printf "Utilitários do projeto.\n\nComo usar: make [COMANDO]\n  Para ver apenas os comandos mais usados, execute `make help`.\n"} /^[a-zA-Z_-]+:.*?#?##/ { printf "  %-20s  %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
