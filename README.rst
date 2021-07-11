Pesquisa Diários Municipais COVID-19
====================================

Com este projeto, pretendo investigar como as prefeituras enfrentaram a pandemia da COVID-19 através da análise dos atos nos diários oficiais municipais.

Como executar o projeto
-----------------------

O projeto atualmente é um índice de arquivos, para executá-lo realize os passos a seguir:

1. Descompacte o arquivo ``dump_serra_recorte_vacina_processed.7z`` na raíz do projeto;

2. (Opcional) Crie um ambiente virtual Python;

3. Execute ``make deps-install``, para instalar as dependências;

4. Execute ``make run``, para criar o índice;

   4.1. O projeto utiliza o `podman <https://podman.io/>`_ para criação de containers, caso não o tenha, siga o `seu guia de instalação <https://podman.io/getting-started/installation>`_;

5. Consulte no índice ``diarios`` na porta padrão do elasticsearch local (localhost:9200), se mantiver a configuração padrão;

   5.1. Uma extensão para navegador como `elasticvue <https://elasticvue.com/>`_ é recomendada se preferir uma interface gráfica para consulta;

   5.2. Exemplo de consulta exata (full text)::

      {
        "query": {
          "match_phrase": {
            "text": "ATA DE REGISTRO DE PREÇOS"
          }
        },
        "size": 10,
        "from": 0,
        "sort": []
      }
